// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IStream} from "./interfaces/IStream.sol";
import {Struct} from "./libraries/Struct.sol";
import {CreateLogic} from "./libraries/CreateLogic.sol";
import {WithdrawLogic} from "./libraries/WithdrawLogic.sol";
import {ExtendLogic} from "./libraries/ExtendLogic.sol";

contract Stream is
    IStream,
    ReentrancyGuard,
    Ownable
{
    using SafeERC20 for IERC20;

    /*** Storage Properties ***/
    address public WETH;
    address public GATEWAY;

    /**
     * @notice Counter for new stream ids.
     */
    uint256 public nextStreamId;

    address private _feeRecipient;
    address private _autoWithdrawAccount;
    
    // Fixed auto-withdrawal fee set to 0.005 ETH (5000000000000000 wei)
    uint256 private constant _autoWithdrawFeeForOnce = 5000000000000000; // 0.005 ETH

    mapping(address => bool) private _tokenAllowed;
    mapping(address => uint256) private _tokenFeeRate;

    /**
     * @notice The stream objects identifiable by their unsigned integer ids.
     */
    mapping(uint256 => Struct.Stream) private _streams;

    /* ============ MODIFIERS ============ */
    /**
     * @dev Throws if the provided id does not point to a valid stream.
     */
    modifier streamExists(uint256 streamId) {
        require(_streams[streamId].isEntity, "flow does not exist");
        _;
    }

    /* ============ Events ============ */

    /**
     * @notice Emits when a stream is successfully closed and tokens are transferred back on a pro rata basis.
     */
    event CloseStream(
        uint256 indexed streamId,
        address indexed operator,
        uint256 senderBalance,
        uint256 recipientBalance
    );

    /**
     * @notice Emits when a stream is successfully paused.
     */
    event PauseStream(
        uint256 indexed streamId,
        address indexed operator,
        uint256 recipientBalance
    );

    /**
     * @notice Emits when a stream is successfully resumed.
     */
    event ResumeStream(
        uint256 indexed streamId,
        address indexed operator,
        uint256 duration
    );

    /**
     * @notice Emits when the recipient of a stream is successfully changed.
     */
    event SetNewRecipient(
        uint256 indexed streamId,
        address indexed operator,
        address indexed newRecipient
    );

    /**
     * @notice Emits when a token is successfully registered.
     */
    event TokenRegister(address indexed tokenAddress, uint256 feeRate);

    /* =========== Constructor ============ */

    constructor(
        address owner_,
        address weth_,
        address feeRecipient_, 
        address autoWithdrawAccount_
        // Removed autoWithdrawFeeForOnce_ parameter since it's now fixed
    ) Ownable() 
    ReentrancyGuard()  {
        _transferOwnership(owner_);
        WETH = weth_;
        _feeRecipient = feeRecipient_;
        _autoWithdrawAccount = autoWithdrawAccount_;
        // _autoWithdrawFeeForOnce is now a constant
        nextStreamId = 100000;
    }

    /* =========== View Functions  ============ */

    function tokenFeeRate(
        address tokenAddress
    ) external view override returns (uint256) {
        require(_tokenAllowed[tokenAddress], "asset not registered");
        return _tokenFeeRate[tokenAddress];
    }

    function autoWithdrawFeeForOnce() external pure override returns (uint256) {
        return _autoWithdrawFeeForOnce;
    }

    function autoWithdrawAccount() external view override returns (address) {
        return _autoWithdrawAccount;
    }

    function feeRecipient() external view override returns (address) {
        return _feeRecipient;
    }

    /**
     * @notice Returns the stream with all its properties.
     * @dev Throws if the id does not point to a valid stream.
     * @param streamId The id of the stream to query.
     */
    function getStream(
        uint256 streamId
    )
        external
        view
        override
        streamExists(streamId)
        returns (Struct.Stream memory)
    {
        return _streams[streamId];
    }

    /**
     * @notice Returns either the delta in intervals between `block.timestamp` and `startTime` or
     *  between `stopTime` and `startTime, whichever is smaller. If `block.timestamp` is before
     *  `startTime`, it returns 0.
     * @dev Throws if the id does not point to a valid stream.
     * @param streamId The id of the stream for which to query the delta.
     * @return delta The time delta in intervals.
     */
    function timeElapsed(
        uint256 streamId
    ) public view streamExists(streamId) returns (uint256 delta) {
        Struct.Stream memory stream = _streams[streamId];
        if (
            block.timestamp <
            stream.lastWithdrawTime + stream.pauseInfo.accPauseTime
        ) {
            return 0;
        }

        if (block.timestamp > stream.stopTime) {
            return
                (stream.stopTime -
                    stream.lastWithdrawTime -
                    stream.pauseInfo.accPauseTime) / stream.interval;
        } else {
            return
                (block.timestamp -
                    stream.lastWithdrawTime -
                    stream.pauseInfo.accPauseTime) / stream.interval;
        }
    }

    /**
     * @notice Returns the available funds for the given stream id and address.
     * @dev Throws if the id does not point to a valid stream.
     * @param streamId The id of the stream for which to query the balance.
     * @param who The address for which to query the balance.
     * @return balance The total funds allocated to `who` as uint256.
     */
    function availableFunds(
        uint256 streamId,
        address who
    ) public view streamExists(streamId) returns (uint256 balance) {
        Struct.Stream memory stream = _streams[streamId];

        uint256 delta = timeElapsed(streamId);
        uint256 recipientBalance = delta * stream.ratePerInterval;
        if (
            stream.cliffInfo.cliffDone == false &&
            stream.cliffInfo.cliffTime <= block.timestamp
        ) {
            recipientBalance += stream.cliffInfo.cliffAmount;
        }

        if (who == stream.recipient) {
            return recipientBalance;
        } else if (who == stream.sender) {
            uint256 senderBalance = stream.remainingBalance - recipientBalance;
            return senderBalance;
        }
        return 0;
    }

    /* =========== Public Effects & Interactions Functions  ============ */

    function bulkCreateFlow(
        Struct.initializeStreamParams[] calldata createParams
    ) external payable nonReentrant {
        uint256 senderValue = msg.value;
        for (uint256 i = 0; i < createParams.length; i++) {
            require(
                _tokenAllowed[createParams[i].tokenAddress],
                "asset not registered"
            );

            uint256 autoWithdrawFee = CreateLogic.create(
                nextStreamId,
                senderValue,
                Struct.GlobalParams({
                    weth:WETH,
                    gateway: GATEWAY,
                    feeRecipient: _feeRecipient,
                    autoWithdrawAccount: _autoWithdrawAccount,
                    autoWithdrawFeeForOnce: _autoWithdrawFeeForOnce,
                    tokenFeeRate: _tokenFeeRate[createParams[i].tokenAddress]
                }),
                createParams[i],
                _streams
            );

            senderValue -= autoWithdrawFee;

            /* Increment the next stream id. */
            nextStreamId = nextStreamId + 1;
        }

        /* reback the gas fee */
        payable(msg.sender).transfer(senderValue);
    }

    function initializeFlow(
        Struct.initializeStreamParams calldata createParams
    ) external payable nonReentrant {
        require(
            _tokenAllowed[createParams.tokenAddress],
            "asset not registered"
        );

        uint256 gasUsed = CreateLogic.create(
            nextStreamId,
            msg.value,
            Struct.GlobalParams({
                weth:WETH,
                gateway: GATEWAY,
                feeRecipient: _feeRecipient,
                autoWithdrawAccount: _autoWithdrawAccount,
                autoWithdrawFeeForOnce: _autoWithdrawFeeForOnce,
                tokenFeeRate: _tokenFeeRate[createParams.tokenAddress]
            }),
            createParams,
            _streams
        );

        /* Increment the next stream id. */
        nextStreamId = nextStreamId + 1;

        /* reback the gas fee */
        payable(msg.sender).transfer(msg.value - gasUsed);
    }

    function bulkExtendFlow(
        uint256[] calldata streamIds,
        uint256[] calldata stopTime
    ) external payable nonReentrant {
        uint256 senderValue = msg.value;
        require(streamIds.length == stopTime.length, "arrays length mismatch");
        for (uint256 i = 0; i < streamIds.length; i++) {
            Struct.Stream storage stream = _streams[streamIds[i]];
            require(stream.isEntity, "flow does not exist");
            uint256 gasUsed = ExtendLogic.extend(
                streamIds[i],
                stopTime[i],
                senderValue,
                Struct.GlobalParams({
                    weth:WETH,
                    gateway: GATEWAY,
                    feeRecipient: _feeRecipient,
                    autoWithdrawAccount: _autoWithdrawAccount,
                    autoWithdrawFeeForOnce: _autoWithdrawFeeForOnce,
                    tokenFeeRate: _tokenFeeRate[stream.tokenAddress]
                }),
                stream
            );

            senderValue -= gasUsed;
        }

        /* reback the gas fee */
        payable(msg.sender).transfer(senderValue);
    }

    function prolongFlow(
        uint256 streamId,
        uint256 stopTime
    ) external payable nonReentrant streamExists(streamId) {
        Struct.Stream storage stream = _streams[streamId];

        uint256 gasUsed = ExtendLogic.extend(
            streamId,
            stopTime,
            msg.value,
            Struct.GlobalParams({
                weth:WETH,
                gateway: GATEWAY,
                feeRecipient: _feeRecipient,
                autoWithdrawAccount: _autoWithdrawAccount,
                autoWithdrawFeeForOnce: _autoWithdrawFeeForOnce,
                tokenFeeRate: _tokenFeeRate[stream.tokenAddress]
            }),
            stream
        );

        /* reback the gas fee */
        payable(msg.sender).transfer(msg.value - gasUsed);
    }

    function bulkClaimFromFlow(uint256[] calldata streamIds) external {
        for (uint256 i = 0; i < streamIds.length; i++) {
            claimFromFlow(streamIds[i]);
        }
    }

    /**
     * @notice Withdraws from the contract to the recipient's account.
     * @param streamId The id of the stream to withdraw tokens from.
     */
    function claimFromFlow(
        uint256 streamId
    ) public streamExists(streamId) {
        Struct.Stream storage stream = _streams[streamId];

        uint256 delta = timeElapsed(streamId);
        uint256 balance = availableFunds(streamId, stream.recipient);

        require(balance > 0, "no funds available for claim");

        WithdrawLogic.withdraw(
            streamId,
            delta,
            balance,
            Struct.GlobalParams({
                weth:WETH,
                gateway: GATEWAY,
                feeRecipient: _feeRecipient,
                autoWithdrawAccount: _autoWithdrawAccount,
                autoWithdrawFeeForOnce: _autoWithdrawFeeForOnce,
                tokenFeeRate: _tokenFeeRate[stream.tokenAddress]
            }),
            stream
        );
    }

    function bulkTerminateFlow(uint256[] calldata streamIds) external {
        for (uint256 i = 0; i < streamIds.length; i++) {
            terminateFlow(streamIds[i]);
        }
    }

    /**
     * @notice close the stream and transfers the tokens back on a pro rata basis.
     * @dev Throws if the id does not point to a valid stream.
     *  Throws if the caller is not the sender or the recipient of the stream.
     *  Throws if there is a token transfer failure.
     * @param streamId The id of the stream to close.
     */
    function terminateFlow(
        uint256 streamId
    ) public streamExists(streamId) {
        Struct.Stream memory stream = _streams[streamId];
        require(stream.closed == false, "flow is already terminated");

        uint256 delta = timeElapsed(streamId);
        uint256 senderBalance = availableFunds(streamId, stream.sender);
        uint256 recipientBalance = availableFunds(streamId, stream.recipient);

        if (WETH == stream.tokenAddress && msg.sender == stream.onBehalfOf) {
            if (tx.origin == stream.sender) {
                require(
                    stream.featureInfo.closeable == Struct.Capability.Both ||
                        stream.featureInfo.closeable ==
                        Struct.Capability.Sender,
                    "initiator is not authorized to terminate the flow"
                );
            } else if (tx.origin == stream.recipient) {
                require(
                    stream.featureInfo.closeable == Struct.Capability.Both ||
                        stream.featureInfo.closeable ==
                        Struct.Capability.Recipient,
                    "beneficiary is not authorized to terminate the flow"
                );
            } else {
                revert("not authorized to terminate the flow");
            }

            IERC20(stream.tokenAddress).safeTransfer(
                stream.onBehalfOf,
                _streams[streamId].remainingBalance
            );
        } else {
            if (msg.sender == stream.sender) {
                require(
                    stream.featureInfo.closeable == Struct.Capability.Both ||
                        stream.featureInfo.closeable ==
                        Struct.Capability.Sender,
                    "initiator is not authorized to terminate the flow"
                );
            } else if (msg.sender == stream.recipient) {
                require(
                    stream.featureInfo.closeable == Struct.Capability.Both ||
                        stream.featureInfo.closeable ==
                        Struct.Capability.Recipient,
                    "beneficiary is not authorized to terminate the flow"
                );
            } else {
                revert("not authorized to terminate the flow");
            }

            if (recipientBalance > 0) {
                uint256 recipientBalanceFee = (recipientBalance *
                    _tokenFeeRate[stream.tokenAddress]) / 10000;
                IERC20(stream.tokenAddress).safeTransfer(
                    _feeRecipient,
                    recipientBalanceFee
                );
                IERC20(stream.tokenAddress).safeTransfer(
                    stream.recipient,
                    recipientBalance - recipientBalanceFee
                );
            }
            if (senderBalance > 0) {
                IERC20(stream.tokenAddress).safeTransfer(
                    stream.sender,
                    senderBalance
                );
            }
        }

        /* send cliff */
        if (stream.cliffInfo.cliffDone == false) {
            _streams[streamId].cliffInfo.cliffDone = true;
        }

        if (delta > 0) {
            _streams[streamId].lastWithdrawTime +=
                stream.interval *
                delta +
                stream.pauseInfo.accPauseTime;
            _streams[streamId].pauseInfo.accPauseTime = 0;
        }

        _streams[streamId].closed = true;
        _streams[streamId].remainingBalance = 0;

        emit CloseStream(streamId, msg.sender, senderBalance, recipientBalance);
    }

    function bulkHaltFlow(uint256[] calldata streamIds) external {
        for (uint256 i = 0; i < streamIds.length; i++) {
            haltFlow(streamIds[i]);
        }
    }

    function haltFlow(
        uint256 streamId
    ) public streamExists(streamId) {
        Struct.Stream storage stream = _streams[streamId];
        /* check the status of this stream */
        require(stream.pauseInfo.isPaused == false, "flow is already halted");
        require(stream.closed == false, "flow is terminated");
        require(stream.stopTime > block.timestamp, "flow has expired");

        /* check the permission */
        if (WETH == stream.tokenAddress && msg.sender == stream.onBehalfOf) {
            if (tx.origin == stream.sender) {
                require(
                    stream.featureInfo.pauseable == Struct.Capability.Both ||
                        stream.featureInfo.pauseable ==
                        Struct.Capability.Sender,
                    "initiator is not authorized to halt the flow"
                );
                stream.pauseInfo.pauseBy = stream.sender;
            } else if (tx.origin == stream.recipient) {
                require(
                    stream.featureInfo.pauseable == Struct.Capability.Both ||
                        stream.featureInfo.pauseable ==
                        Struct.Capability.Recipient,
                    "beneficiary is not authorized to halt the flow"
                );
                stream.pauseInfo.pauseBy = stream.recipient;
            } else {
                revert("not authorized to halt the flow");
            }
        } else {
            if (msg.sender == stream.sender) {
                require(
                    stream.featureInfo.pauseable == Struct.Capability.Both ||
                        stream.featureInfo.pauseable ==
                        Struct.Capability.Sender,
                    "initiator is not authorized to halt the flow"
                );
                stream.pauseInfo.pauseBy = stream.sender;
            } else if (msg.sender == stream.recipient) {
                require(
                    stream.featureInfo.pauseable == Struct.Capability.Both ||
                        stream.featureInfo.pauseable ==
                        Struct.Capability.Recipient,
                    "beneficiary is not authorized to halt the flow"
                );
                stream.pauseInfo.pauseBy = stream.recipient;
            } else {
                revert("not authorized to halt the flow");
            }
        }

        /* withdraw the remaining balance */
        uint256 balance = availableFunds(streamId, stream.recipient);
        if (balance > 0) {
            WithdrawLogic.withdraw(
                streamId,
                timeElapsed(streamId),
                balance,
                Struct.GlobalParams({
                    weth:WETH,
                    gateway: GATEWAY,
                    feeRecipient: _feeRecipient,
                    autoWithdrawAccount: _autoWithdrawAccount,
                    autoWithdrawFeeForOnce: _autoWithdrawFeeForOnce,
                    tokenFeeRate: _tokenFeeRate[stream.tokenAddress]
                }),
                stream
            );
        }

        /* pause the stream */
        stream.pauseInfo.pauseAt = block.timestamp;
        stream.pauseInfo.isPaused = true;

        /* emit event */
        emit PauseStream(streamId, stream.pauseInfo.pauseBy, balance);
    }

    function bulkRestartFlow(uint256[] calldata streamIds) external {
        for (uint256 i = 0; i < streamIds.length; i++) {
            restartFlow(streamIds[i]);
        }
    }

    function restartFlow(
        uint256 streamId
    ) public streamExists(streamId) {
        Struct.Stream storage stream = _streams[streamId];
        /* check the status of this stream */
        require(stream.pauseInfo.isPaused == true, "flow is not halted");
        require(stream.closed == false, "flow is terminated");
        require(
            stream.pauseInfo.pauseBy == msg.sender || owner() == msg.sender,
            "only the one who halted the flow can restart it"
        );

        /* resume the stream */
        uint256 duration = 0;
        if (block.timestamp > stream.startTime) {
            if (stream.pauseInfo.pauseAt > stream.startTime) {
                duration = block.timestamp - stream.pauseInfo.pauseAt;
            } else {
                duration = block.timestamp - stream.startTime;
            }
        }

        stream.pauseInfo.isPaused = false;
        stream.pauseInfo.pauseAt = 0;
        stream.pauseInfo.pauseBy = address(0x00);
        stream.pauseInfo.accPauseTime += duration;
        stream.stopTime += duration;

        /* emit event */
        emit ResumeStream(streamId, msg.sender, duration);
    }

    function bulkUpdateBeneficiary(
        uint256[] calldata streamIds,
        address[] calldata newRecipient
    ) external {
        require(streamIds.length == newRecipient.length, "arrays length mismatch");

        for (uint256 i = 0; i < streamIds.length; i++) {
            updateBeneficiary(streamIds[i], newRecipient[i]);
        }
    }

    function updateBeneficiary(
        uint256 streamId,
        address newRecipient
    ) public override streamExists(streamId) {
        Struct.Stream storage stream = _streams[streamId];
        require(stream.closed == false, "flow is terminated");
        require(stream.pauseInfo.isPaused == false, "flow is halted");

        /* check the permission */
        if (msg.sender == stream.sender) {
            require(
                stream.featureInfo.recipientModifiable ==
                    Struct.Capability.Both ||
                    stream.featureInfo.recipientModifiable ==
                    Struct.Capability.Sender,
                "initiator is not authorized to change the beneficiary"
            );
        } else if (msg.sender == stream.recipient) {
            require(
                stream.featureInfo.recipientModifiable ==
                    Struct.Capability.Both ||
                    stream.featureInfo.recipientModifiable ==
                    Struct.Capability.Recipient,
                "beneficiary is not authorized to change the beneficiary"
            );
        } else {
            revert("not authorized to change the beneficiary");
        }

        stream.recipient = newRecipient;

        /* emit event */
        emit SetNewRecipient(streamId, msg.sender, newRecipient);
    }

    function registerAsset(
        address tokenAddress,
        uint256 feeRate
    ) public onlyOwner {
        _tokenAllowed[tokenAddress] = true;
        _tokenFeeRate[tokenAddress] = feeRate;

        /* emit event */
        emit TokenRegister(tokenAddress, feeRate);
    }

    function bulkRegisterAsset(
        address[] calldata tokenAddresses,
        uint256[] calldata feeRates
    ) external onlyOwner {
        require(tokenAddresses.length == feeRates.length, "arrays length mismatch");

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            registerAsset(tokenAddresses[i], feeRates[i]);
        }
    }

    function updateFeeCollector(address newFeeRecipient) external onlyOwner {
        _feeRecipient = newFeeRecipient;
    }

    function updateAutoClaimAccount(
        address newAutoWithdrawAccount
    ) external onlyOwner {
        _autoWithdrawAccount = newAutoWithdrawAccount;
    }

    // Note: setAutoWithdrawFee function removed since fee is now fixed
    // function setAutoWithdrawFee(uint256 newAutoWithdrawFee) external onlyOwner {
    //     _autoWithdrawFeeForOnce = newAutoWithdrawFee;
    // }

    function configureGateway(address gateway) external onlyOwner {
        GATEWAY = gateway;
    }
}