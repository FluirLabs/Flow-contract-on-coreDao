// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {Struct} from "../libraries/Struct.sol";

interface IStream {
    function tokenFeeRate(address tokenAddress) external view returns (uint256);

    function autoWithdrawFeeForOnce() external view returns (uint256);

    function autoWithdrawAccount() external view returns (address);

    function feeRecipient() external view returns (address);

    function availableFunds(uint256 streamId, address who) external view returns (uint256 balance);

    function getStream(uint256 streamId) external view returns (Struct.Stream memory);

    function initializeFlow(Struct.initializeStreamParams calldata createParams) external payable;

    function prolongFlow(uint256 streamId, uint256 stopTime) external payable;

    function claimFromFlow(uint256 streamId) external;

    function terminateFlow(uint256 streamId) external;

    function haltFlow(uint256 streamId) external;

    function restartFlow(uint256 streamId) external;

    function updateBeneficiary(uint256 streamId, address newRecipient) external;
}