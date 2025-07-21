// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {MockUSDC} from "../contracts/MockUSDC.sol";
import {WETH9} from "../contracts/mocks/WETH9.sol";
import {Stream} from "../contracts/Stream.sol";
import {Struct} from "../contracts/libraries/Struct.sol";

contract StreamTest is Test {
    Stream stream;
    MockUSDC usdc;

    function setUp() public {
        // Initialize contracts
        stream = new Stream(
            address(this),           // owner (deployer)
            address(0xabc),         // wethAddress 
            address(this),          // autoWithdrawAccount (deployer)
            address(this)           // feeRecipient (deployer)
        );
        usdc = new MockUSDC();
        
        // Register the token
        stream.registerAsset(address(usdc), 1);
    }
    
    receive() external payable { }

    function createStream() public {
        uint256 start = block.timestamp + 1; // Start in the future
        uint256 duration = 1000; // Duration in seconds
        uint256 deposit = 100e18; // Reduced deposit amount
        
        Struct.initializeStreamParams memory createParams = Struct
            .initializeStreamParams({
                sender: address(this),
                recipient: 0xD44B6Fcb1A698c8A56D9Ca5f62AEbB738BB09368,
                deposit: deposit, 
                tokenAddress: address(usdc),
                startTime: start,
                stopTime: start + duration,
                interval: 100,
                cliffAmount: 10e18,
                cliffTime: 0,
                autoWithdrawInterval: 0,
                autoWithdraw: false,
                pauseable: Struct.Capability.Sender,
                closeable: Struct.Capability.Sender,
                recipientModifiable: Struct.Capability.Sender
            });
        
        usdc.approve(address(stream), type(uint256).max);
        stream.initializeFlow{value: 0.005 ether}(createParams);
    }

    function testCreateStream() public {
        uint256 start = block.timestamp + 1; // Start in future
        Struct.initializeStreamParams memory createParams = Struct
            .initializeStreamParams({
                sender: address(this),
                recipient: 0xD44B6Fcb1A698c8A56D9Ca5f62AEbB738BB09368,
                deposit: 100e18,
                tokenAddress: address(usdc),
                startTime: start,
                stopTime: start + 10 days,
                interval: 1 days,
                cliffAmount: 20e18,
                cliffTime: 0,
                autoWithdrawInterval: 0,
                autoWithdraw: false,
                pauseable: Struct.Capability.None,
                closeable: Struct.Capability.None,
                recipientModifiable: Struct.Capability.None
            });
        
        usdc.approve(address(stream), type(uint256).max);
        stream.initializeFlow{value: 0.005 ether}(createParams);
        Struct.Stream memory streamObj = stream.getStream(stream.nextStreamId()-1);

        // Frontend Values Output
        console2.log("=== FRONTEND VALUES ===");
        console2.log("Stream ID:", stream.nextStreamId()-1);
        console2.log("Stream Contract Address:", address(stream));
        console2.log("USDC Token Address:", address(usdc));
        console2.log("Sender Address:", streamObj.sender);
        console2.log("Recipient Address:", streamObj.recipient);
        console2.log("Deposit Amount (wei):", streamObj.deposit);
        console2.log("Start Time (timestamp):", streamObj.startTime);
        console2.log("Stop Time (timestamp):", streamObj.stopTime);
        console2.log("Interval (seconds):", streamObj.interval);
        console2.log("Rate Per Interval (wei):", streamObj.ratePerInterval);
        console2.log("Cliff Amount (wei):", streamObj.cliffInfo.cliffAmount);
        console2.log("Is Active:", streamObj.isEntity);
        console2.log("Is Closed:", streamObj.closed);
        console2.log("=======================");

        assertGt(stream.nextStreamId(), 100000);
        assertGt(streamObj.deposit, 0);
        assertGt(streamObj.startTime, 0);
        assertGt(streamObj.stopTime, 0);
        assertFalse(streamObj.tokenAddress == address(0));
        assertFalse(streamObj.recipient == address(0));
    }

    function testProlongFlow() public {
        createStream();
        uint256 streamID = stream.nextStreamId() - 1;
        
        // Get current stream info
        Struct.Stream memory streamObj = stream.getStream(streamID);
        
        // Calculate new stop time that's a multiple of interval
        uint256 additionalTime = 25 days;
        uint256 newStopTime = streamObj.stopTime + additionalTime;
        newStopTime = ((newStopTime + streamObj.interval - 1) / streamObj.interval) * streamObj.interval;

        stream.prolongFlow{value: 0.005 ether}(streamID, newStopTime);

        Struct.Stream memory updatedStreamObj = stream.getStream(streamID);
        assertEq(updatedStreamObj.stopTime, newStopTime);
    }

    function testClaimFromFlow() public {
        createStream();
        uint256 streamID = stream.nextStreamId() - 1;
        
        // Warp to after the stream has started and some time has passed
        Struct.Stream memory streamObj = stream.getStream(streamID);
        vm.warp(streamObj.startTime + 200); // Move past start time + some interval
        
        stream.claimFromFlow(streamID);
        Struct.Stream memory updatedStreamObj = stream.getStream(streamID);

        assertTrue(updatedStreamObj.cliffInfo.cliffDone);
    }

    function testTerminateFlow() public {
        createStream();
        uint256 streamID = stream.nextStreamId() - 1;

        // Warp to after stream starts
        vm.warp(stream.getStream(streamID).startTime + 1);
        
        stream.terminateFlow(streamID);
        Struct.Stream memory streamObj = stream.getStream(streamID);

        assertTrue(streamObj.closed);
    }

    function testHaltFlow() public {
        createStream();
        uint256 streamID = stream.nextStreamId() - 1;
        
        // Warp to after stream starts but before it ends
        Struct.Stream memory streamObj = stream.getStream(streamID);
        vm.warp(streamObj.startTime + 100);
        
        stream.haltFlow(streamID);
        Struct.Stream memory pausedStreamObj = stream.getStream(streamID);

        // Frontend Values for Pause State
        console2.log("=== PAUSE STATE VALUES ===");
        console2.log("Stream ID:", streamID);
        console2.log("Is Paused:", pausedStreamObj.pauseInfo.isPaused);
        console2.log("Paused At (timestamp):", pausedStreamObj.pauseInfo.pauseAt);
        console2.log("Paused By Address:", pausedStreamObj.pauseInfo.pauseBy);
        console2.log("Total Paused Time:", pausedStreamObj.pauseInfo.accPauseTime);
        console2.log("============================");

        assertTrue(pausedStreamObj.pauseInfo.isPaused);
    }  

    function testRestartFlow() public {
        createStream();
        uint256 streamID = stream.nextStreamId() - 1;
        
        // Warp to after stream starts but before it ends
        Struct.Stream memory streamObj = stream.getStream(streamID);
        vm.warp(streamObj.startTime + 100);
        
        // First pause the stream
        stream.haltFlow(streamID);
        
        console2.log("Stream is paused at", stream.getStream(streamID).pauseInfo.pauseAt);

        // Then try to restart it
        stream.restartFlow(streamID);
        
        Struct.Stream memory restartedStreamObj = stream.getStream(streamID);
        assertEq(restartedStreamObj.pauseInfo.pauseAt, 0);
        assertFalse(restartedStreamObj.pauseInfo.isPaused);
        console2.log("stream is unpaused so paused at = ", restartedStreamObj.pauseInfo.pauseAt);
    }
    function testUpdateBeneficiary() public {
        createStream();

        uint256 streamID = stream.nextStreamId() - 1;

        stream.updateBeneficiary(streamID, address(45));

        assertEq(stream.getStream(streamID).recipient, address(45));
    }

    function testRegisterAsset() public {
        stream.registerAsset(address(usdc), 95);

        assertEq(stream.tokenFeeRate(address(usdc)), 95);
    }

    function testUpdateFeeCollector() public {
        stream.updateFeeCollector(address(9952));
        assertTrue(address(9952) == stream.feeRecipient());
    }

    function testUpdateFeeCollectorNotOwner() public {
        vm.expectRevert();
        vm.prank(address(0xabc));
        stream.updateFeeCollector(address(9952));
    }

    function testUpdateAutoClaimAccount() public {
        stream.updateAutoClaimAccount(address(0xabc));
        assertTrue(address(0xabc) == stream.autoWithdrawAccount());
    }

    function testUpdateAutoClaimAccountNotOwner() public {
        vm.expectRevert();
        vm.prank(address(0xabc));
        stream.updateAutoClaimAccount(address(0xabc));
    }

    function testConfigureGateway() public {
        stream.configureGateway(address(0xabc));
        assertTrue(address(0xabc) == stream.GATEWAY());
    }

    function testNotOwnerConfigureGateway() public {
        vm.expectRevert();
        vm.prank(address(0xabc));
        stream.configureGateway(address(0));
    }
}