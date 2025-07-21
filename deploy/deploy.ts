import { ethers } from "hardhat";
const { parseEther, formatEther } = require("ethers");
import {
  getDeployedContract,
  getDeployedContractWithDefaultName,
  getWethAddress,
} from "../scripts/utils/env";
import "dotenv/config";
require("dotenv").config();

const deployFunction = async function (hre) {
  try {
    console.log("Starting deployment process...");

    const { deployments, getNamedAccounts } = hre;
    const { deploy } = deployments;

    // Get deployer account
    const { deployer } = await getNamedAccounts();
    if (!deployer) {
      throw new Error("No deployer account found");
    }
    console.log("Deployer account:", deployer);

    // Get current block number
    const blockNumber = await hre.ethers.provider.getBlockNumber();
    console.log("Current block number:", blockNumber);

    // Get WETH address
    let wethAddress = await getWethAddress();
    if (!wethAddress) {
      throw new Error("WETH address not found");
    }
    console.log("WETH Address:", wethAddress);

    // Deploy Stream contract
    console.log("Deploying Stream contract...");
    const stream = await deploy("Stream", {
      from: deployer,
      args: [
        deployer, // owner_
        wethAddress, // weth_
        deployer, // feeRecipient_
        deployer, // autoWithdrawAccount_
        // Removed autoWithdrawFee argument - it's now fixed at 0.005 ETH in the contract
      ],
      autoMine: true,
      deterministicDeployment: true,
      log: true,
    });

    if (!stream.address) {
      throw new Error("Stream contract deployment failed");
    }
    console.log(`Stream deployed to: ${stream.address}`);
    console.log("Newly deployed:", stream.newlyDeployed);

    // Get Stream implementation
    const streamImpl = await getDeployedContractWithDefaultName("Stream");
    console.log("Stream implementation address:", streamImpl.address);

    // Deploy FlowEntry
    console.log("Deploying FlowEntry...");
    const FlowEntry = await deploy("FlowEntry", {
      from: deployer,
      args: [wethAddress, stream.address],
      autoMine: true,
      deterministicDeployment: true,
      log: true,
    });

    if (!FlowEntry.address) {
      throw new Error("FlowEntry deployment failed");
    }
    console.log(`FlowEntry deployed to: ${FlowEntry.address}`);
    console.log("Newly deployed:", FlowEntry.newlyDeployed);

    // Get FlowEntry implementation
    const FlowEntryImpl = await getDeployedContractWithDefaultName("FlowEntry");
    console.log("FlowEntry implementation address:", FlowEntryImpl.address);

    // Initialize Stream contract
    console.log("Initializing Stream contract...");
    const streamContract = await ethers.getContractAt(
      "Stream",
      stream.address // Fixed: use the deployed stream address
    );
    const tx2 = await streamContract.configureGateway(FlowEntry.address);
    console.log("Waiting for setGateway transaction...");

    const receipt = await tx2.wait();
    if (!receipt) {
      throw new Error("Failed to get transaction receipt");
    }
    console.log(`Stream setGateway tx: ${receipt.hash}`);

    console.log("Deployment completed successfully!");
    console.log("Summary:");
    console.log(`- Stream contract: ${stream.address}`);
    console.log(`- FlowEntry contract: ${FlowEntry.address}`);
    console.log(
      `- Fixed auto-withdrawal fee: 0.005 ETH (hardcoded in contract)`
    );
  } catch (error) {
    console.error("Deployment failed with error:", error);
    throw error;
  }
};

deployFunction.tags = ["stream"];

module.exports = deployFunction;
