import hre, { deployments } from "hardhat";
import { ethers } from "hardhat"; // Use this import instead
import { config } from "dotenv";
config({ path: "../.env" });

export const getAddress = (name: string) => {
  const configName = name.toUpperCase() + "_" + hre.network.name.toUpperCase();
  const address = process.env[configName];
  console.log("Get address for %s: %s", configName, address);
  return address || "";
};

export const getWethAddress = async () => {
  if (hre.network.name == "hardhat") {
    const { deployments, getNamedAccounts } = hre;
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();
    await deploy("WETH9", {
      from: deployer,
    }).then((res) => {
      console.log("WETH deployed to: %s, %s", res.address, res.newlyDeployed);
    });
    return (await deployments.get("WETH9")).address;
  } else {
    const wethAddress = getAddress("weth");
    // Return the fallback address if wethAddress is empty
    return wethAddress || "0x1401b4FF86A31737a75513039435131578704a25";
  }
};

export const getDeployedContractWithDefaultName = async (
  contractName: string
) => {
  return await getDeployedContract(contractName, contractName);
};

export const getDeployedContract = async (
  contractName: string,
  deployName: string
) => {
  let deployedAddr = (await deployments.get(deployName)).address;
  return await ethers.getContractAt(contractName, deployedAddr);
};
