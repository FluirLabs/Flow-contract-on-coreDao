import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import * as dotenv from "dotenv";
import {ethers} from "hardhat";
dotenv.config();

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  console.log("Deploying MockUSDC contract...");
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  console.log(`Deployer address: ${deployer}`);
  console.log("block number:", await hre.ethers.provider.getBlockNumber());

  const mockUSDC = await deploy("MockUSDC", {
    from: deployer,
    args: [],
    log: true,
    autoMine: true,
    deterministicDeployment:true,
  });

  console.log(`Deployed MockUSDC contract to address: ${mockUSDC.address}, ${mockUSDC.newlyDeployed}`);

};

deployFunction.tags = ["MockUSDC"];

module.exports = deployFunction;