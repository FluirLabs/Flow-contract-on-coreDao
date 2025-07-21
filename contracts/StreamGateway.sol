// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IWETH} from "./interfaces/IWETH.sol";
import {IStream} from "./interfaces/IStream.sol";
import {Struct} from "./libraries/Struct.sol";

contract FlowEntry is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IWETH internal immutable WETH;
    IStream internal immutable STREAM;
    
    // Fixed auto-withdrawal fee set to 0.005 ETH (5000000000000000 wei)
    uint256 private constant AUTO_WITHDRAW_FEE_FOR_ONCE = 5000000000000000; // 0.005 ETH

    constructor(address weth, IStream stream) ReentrancyGuard() Ownable() {
        WETH = IWETH(weth);    
        STREAM = stream;
        IWETH(weth).approve(address(stream), type(uint256).max);
    }

    function bulkInitializeFlowETH(
        Struct.initializeStreamParams[] calldata inputParams
    ) external payable nonReentrant {
        uint256 totalDeposit = 0;
        uint256 totalAutoWithdrawFee = 0;
        uint256 feeRate = STREAM.tokenFeeRate(address(WETH));
        address feeRecipient = STREAM.feeRecipient();
        
        for (uint256 i = 0; i < inputParams.length; i++) {
            Struct.initializeStreamParams calldata params = inputParams[i];
            require(
                params.tokenAddress == address(0x00),
                "tokenAddress must be WETH"
            );
            
            uint256 autoWithdrawFee = 0;
            if (params.autoWithdraw) {
                autoWithdrawFee =
                    AUTO_WITHDRAW_FEE_FOR_ONCE *
                    ((params.stopTime - params.startTime) /
                        params.autoWithdrawInterval +
                        1);
                totalAutoWithdrawFee += autoWithdrawFee;
            }
            totalDeposit += params.deposit;
            WETH.deposit{value: params.deposit}();

            Struct.initializeStreamParams memory createParams = Struct
                .initializeStreamParams({
                    sender: params.sender,
                    recipient: params.recipient,
                    deposit: params.deposit,
                    tokenAddress: address(WETH),
                    startTime: params.startTime,
                    stopTime: params.stopTime,
                    interval: params.interval,
                    cliffAmount: params.cliffAmount,
                    cliffTime: params.cliffTime,
                    autoWithdrawInterval: params.autoWithdrawInterval,
                    autoWithdraw: params.autoWithdraw,
                    pauseable: params.pauseable,
                    closeable: params.closeable,
                    recipientModifiable: params.recipientModifiable
                });

            STREAM.initializeFlow{value: autoWithdrawFee}(createParams);

            if (params.cliffTime <= block.timestamp && params.cliffAmount > 0) {
                uint256 fee = (params.cliffAmount * feeRate) / 10000;
                WETH.withdraw(params.cliffAmount);
                _safeTransferETH(params.recipient, params.cliffAmount - fee);
                _safeTransferETH(feeRecipient, fee);
            }
        }

        if (msg.value > totalDeposit + totalAutoWithdrawFee)
            _safeTransferETH(
                msg.sender,
                msg.value - totalDeposit - totalAutoWithdrawFee
            );
    }

    function initializeFlowETH(
        Struct.initializeStreamParams calldata inputParams
    ) external payable nonReentrant {
        require(
            inputParams.tokenAddress == address(0x00),
            "tokenAddress must be ZERO ADDRESS"
        );
        
        uint256 autoWithdrawFee = 0;
        if (inputParams.autoWithdraw) {
            autoWithdrawFee =
                AUTO_WITHDRAW_FEE_FOR_ONCE *
                ((inputParams.stopTime - inputParams.startTime) /
                    inputParams.autoWithdrawInterval +
                    1);
        }

        WETH.deposit{value: inputParams.deposit}();

        Struct.initializeStreamParams memory createParams = Struct
            .initializeStreamParams({
                sender: inputParams.sender,
                recipient: inputParams.recipient,
                deposit: inputParams.deposit,
                tokenAddress: address(WETH),
                startTime: inputParams.startTime,
                stopTime: inputParams.stopTime,
                interval: inputParams.interval,
                cliffAmount: inputParams.cliffAmount,
                cliffTime: inputParams.cliffTime,
                autoWithdrawInterval: inputParams.autoWithdrawInterval,
                autoWithdraw: inputParams.autoWithdraw,
                pauseable: inputParams.pauseable,
                closeable: inputParams.closeable,
                recipientModifiable: inputParams.recipientModifiable
            });

        STREAM.initializeFlow{value: autoWithdrawFee}(createParams);

        if (
            inputParams.cliffTime <= block.timestamp &&
            inputParams.cliffAmount > 0
        ) {
            uint256 feeRate = STREAM.tokenFeeRate(address(WETH));
            address feeRecipient = STREAM.feeRecipient();
            uint256 fee = (inputParams.cliffAmount * feeRate) / 10000;
            WETH.withdraw(inputParams.cliffAmount);
            _safeTransferETH(
                inputParams.recipient,
                inputParams.cliffAmount - fee
            );
            _safeTransferETH(feeRecipient, fee);
        }

        if (msg.value > inputParams.deposit + autoWithdrawFee) {
            _safeTransferETH(
                msg.sender,
                msg.value - inputParams.deposit - autoWithdrawFee
            );
        }
    }

    function bulkProlongFlowETH(
        uint256[] calldata streamIds,
        uint256[] calldata newStopTimes
    ) external payable nonReentrant {
        require(
            streamIds.length == newStopTimes.length,
            "array length not equal"
        );

        uint256 totalDeposit = 0;
        uint256 totalAutoWithdrawFee = 0;
        
        for (uint256 i = 0; i < streamIds.length; i++) {
            Struct.Stream memory stream = STREAM.getStream(streamIds[i]);
            uint256 duration = newStopTimes[i] - stream.stopTime;
            uint256 delta = duration / stream.interval;
            require(
                delta * stream.interval == duration,
                "stop time not multiple of interval"
            );

            uint256 newDeposit = delta * stream.ratePerInterval;
            totalDeposit += newDeposit;

            uint256 autoWithdrawFee = 0;
            if (stream.autoWithdraw) {
                autoWithdrawFee =
                    AUTO_WITHDRAW_FEE_FOR_ONCE *
                    (duration / stream.autoWithdrawInterval + 1);
                totalAutoWithdrawFee += autoWithdrawFee;
            }

            WETH.deposit{value: newDeposit}();
            STREAM.prolongFlow{value: autoWithdrawFee}(
                streamIds[i],
                newStopTimes[i]
            );
        }

        if (msg.value > totalDeposit + totalAutoWithdrawFee)
            _safeTransferETH(
                msg.sender,
                msg.value - totalDeposit - totalAutoWithdrawFee
            );
    }

    function prolongFlowETH(
        uint256 streamId,
        uint256 newStopTime
    ) external payable nonReentrant {
        Struct.Stream memory stream = STREAM.getStream(streamId);

        uint256 duration = newStopTime - stream.stopTime;
        uint256 delta = duration / stream.interval;
        require(
            delta * stream.interval == duration,
            "stop time not multiple of interval"
        );

        /* new deposit*/
        uint256 newDeposit = delta * stream.ratePerInterval;

        /* auto withdraw fee */
        uint256 autoWithdrawFee = 0;
        if (stream.autoWithdraw) {
            autoWithdrawFee =
                AUTO_WITHDRAW_FEE_FOR_ONCE *
                (duration / stream.autoWithdrawInterval + 1);
        }

        WETH.deposit{value: newDeposit}();
        STREAM.prolongFlow{value: autoWithdrawFee}(streamId, newStopTime);

        if (msg.value > newDeposit + autoWithdrawFee)
            _safeTransferETH(
                msg.sender,
                msg.value - newDeposit - autoWithdrawFee
            );
    }

    function bulkClaimFromFlowETH(
        uint256[] calldata streamIds
    ) external nonReentrant {
        uint256 feeRate = STREAM.tokenFeeRate(address(WETH));
        address feeRecipient = STREAM.feeRecipient();
        for (uint256 i = 0; i < streamIds.length; i++) {
            Struct.Stream memory stream = STREAM.getStream(streamIds[i]);

            uint256 balance = STREAM.availableFunds(streamIds[i], stream.recipient);

            STREAM.claimFromFlow(streamIds[i]);
            if (balance > 0) {
                uint256 fee = (balance * feeRate) / 10000;
                WETH.withdraw(balance);
                _safeTransferETH(stream.recipient, balance - fee);
                _safeTransferETH(feeRecipient, fee);
            }
        }
    }

    function claimFromFlowETH(uint256 streamId) external nonReentrant {
        Struct.Stream memory stream = STREAM.getStream(streamId);

        uint256 balance = STREAM.availableFunds(streamId, stream.recipient);

        STREAM.claimFromFlow(streamId);
        if (balance > 0) {
            uint256 feeRate = STREAM.tokenFeeRate(address(WETH));
            uint256 fee = (balance * feeRate) / 10000;
            address feeRecipient = STREAM.feeRecipient();
            WETH.withdraw(balance);
            _safeTransferETH(stream.recipient, balance - fee);
            _safeTransferETH(feeRecipient, fee);
        }
    }

    function bulkTerminateFlowETH(
        uint256[] calldata streamIds
    ) external nonReentrant {
        uint256 feeRate = STREAM.tokenFeeRate(address(WETH));
        address feeRecipient = STREAM.feeRecipient();
        for (uint256 i = 0; i < streamIds.length; i++) {
            Struct.Stream memory stream = STREAM.getStream(streamIds[i]);

            uint256 senderBalance = STREAM.availableFunds(
                streamIds[i],
                stream.sender
            );
            uint256 recipientBalance = STREAM.availableFunds(
                streamIds[i],
                stream.recipient
            );

            STREAM.terminateFlow(streamIds[i]);
            WETH.withdraw(senderBalance + recipientBalance);
            if (senderBalance > 0) {
                _safeTransferETH(stream.sender, senderBalance);
            }
            if (recipientBalance > 0) {
                uint256 fee = (recipientBalance * feeRate) / 10000;
                _safeTransferETH(stream.recipient, recipientBalance - fee);
                _safeTransferETH(feeRecipient, fee);
            }
        }
    }

    function terminateFlowETH(uint256 streamId) external nonReentrant {
        Struct.Stream memory stream = STREAM.getStream(streamId);

        uint256 senderBalance = STREAM.availableFunds(streamId, stream.sender);
        uint256 recipientBalance = STREAM.availableFunds(streamId, stream.recipient);

        STREAM.terminateFlow(streamId);
        WETH.withdraw(senderBalance + recipientBalance);
        if (senderBalance > 0) {
            _safeTransferETH(stream.sender, senderBalance);
        }
        if (recipientBalance > 0) {
            uint256 feeRate = STREAM.tokenFeeRate(address(WETH));
            uint256 fee = (recipientBalance * feeRate) / 10000;
            address feeRecipient = STREAM.feeRecipient();
            _safeTransferETH(stream.recipient, recipientBalance - fee);
            _safeTransferETH(feeRecipient, fee);
        }
    }

    function bulkHaltFlowETH(
        uint256[] calldata streamIds
    ) external nonReentrant {
        uint256 feeRate = STREAM.tokenFeeRate(address(WETH));
        address feeRecipient = STREAM.feeRecipient();
        for (uint256 i = 0; i < streamIds.length; i++) {
            Struct.Stream memory stream = STREAM.getStream(streamIds[i]);

            uint256 balance = STREAM.availableFunds(streamIds[i], stream.recipient);

            STREAM.haltFlow(streamIds[i]);
            if (balance > 0) {
                uint256 fee = (balance * feeRate) / 10000;
                WETH.withdraw(balance);
                _safeTransferETH(stream.recipient, balance - fee);
                _safeTransferETH(feeRecipient, fee);
            }
        }
    }

    function haltFlowETH(uint256 streamId) public nonReentrant {
        Struct.Stream memory stream = STREAM.getStream(streamId);

        uint256 balance = STREAM.availableFunds(streamId, stream.recipient);

        STREAM.haltFlow(streamId);
        if (balance > 0) {
            uint256 feeRate = STREAM.tokenFeeRate(address(WETH));
            uint256 fee = (balance * feeRate) / 10000;
            address feeRecipient = STREAM.feeRecipient();
            WETH.withdraw(balance);
            _safeTransferETH(stream.recipient, balance - fee);
            _safeTransferETH(feeRecipient, fee);
        }
    }

    /**
     * @notice Get the fixed auto-withdrawal fee
     * @return The fixed auto-withdrawal fee of 0.005 ETH
     */
    function getAutoWithdrawFee() external pure returns (uint256) {
        return AUTO_WITHDRAW_FEE_FOR_ONCE;
    }

    /**
    * @dev transfer ETH to an address, revert if it fails.
    * @param to recipient of the transfer
    * @param value the amount to send
    */
    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "ETH_TRANSFER_FAILED");
    }

    /**
    * @dev transfer ERC20 from the utility contract, for ERC20 recovery in case of stuck tokens due
    * direct transfers to the contract address.
    * @param token token to transfer
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function emergencyTokenTransfer(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).safeTransfer(to, amount);
    }

    /**
    * @dev transfer native Ether from the utility contract, for native Ether recovery in case of stuck Ether
    * due to selfdestructs or ether transfers to the pre-computed contract address before deployment.
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function emergencyEtherTransfer(
        address to,
        uint256 amount
    ) external onlyOwner {
        _safeTransferETH(to, amount);
    }

    /**
    * @dev Get WETH address used by WrappedTokenGatewayV3
    */
    function getWETHAddress() external view returns (address) {
        return address(WETH);
    }

    /**
    * @dev Only WETH contract is allowed to transfer ETH here. Prevent other addresses to send Ether to this contract.
    */
    receive() external payable {
        require(
            msg.sender == address(WETH) || msg.sender == address(STREAM),
            "Receive not allowed"
        );
    }

    /**
    * @dev Revert fallback calls
    */
    fallback() external payable {
        revert("Fallback not allowed");
    }
}