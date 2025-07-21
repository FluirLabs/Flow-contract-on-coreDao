// Save as scripts/registerAdditionalToken.js
const { ethers } = require("hardhat");

async function main() {
  console.log("Starting token registration process...");

  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deployer account:", deployer.address);

  // Contract addresses
  const streamAddress = "0xeE245CF7b6995f0b05197477BC63b34FD0ED7727";
  const additionalTokenAddress = "0xaBfC1162999DAEa5962c64537aEC40388d6980cD";

  console.log("Stream contract address:", streamAddress);
  console.log("Additional token address:", additionalTokenAddress);

  try {
    // 1. Connect to the Stream contract
    const stream = await ethers.getContractAt("Stream", streamAddress);
    console.log("Stream contract connected successfully");

    // 2. Check contract ownership
    const owner = await stream.owner();
    console.log("Contract owner:", owner);
    console.log(
      "Is deployer the owner?",
      owner.toLowerCase() === deployer.address.toLowerCase()
    );

    if (owner.toLowerCase() !== deployer.address.toLowerCase()) {
      console.log("Warning: You are not the owner of the Stream contract");
    }

    // 3. Check if token is already registered
    let isRegistered;
    try {
      const feeRate = await stream.tokenFeeRate(additionalTokenAddress);
      isRegistered = feeRate > 0;
      console.log(
        "Token registration status:",
        isRegistered ? "Registered" : "Not registered"
      );
    } catch (error) {
      console.log(
        "Token not registered yet (error checking status):",
        error.message
      );
      isRegistered = false;
    }

    // 4. Attempt registration if needed
    if (!isRegistered) {
      console.log("\nAttempting to register token...");
      try {
        // Estimate gas
        const gasEstimate = await stream.registerAsset.estimateGas(
          additionalTokenAddress,
          100
        );
        console.log("Gas estimate:", gasEstimate.toString());

        // Send transaction
        const tx = await stream.registerAsset(additionalTokenAddress, 100, {
          gasLimit: gasEstimate * 2n,
        });

        console.log("Transaction sent:", tx.hash);
        const receipt = await tx.wait();
        console.log("Transaction confirmed in block:", receipt.blockNumber);

        // Verify registration
        const feeRate = await stream.tokenFeeRate(additionalTokenAddress);
        console.log(
          "Token successfully registered with fee rate:",
          feeRate.toString(),
          "bps"
        );
      } catch (error) {
        console.error("Registration failed:", error);
        if (error.reason) console.error("Revert reason:", error.reason);
        if (error.data) {
          try {
            const decoded = stream.interface.parseError(error.data);
            console.error("Decoded error:", decoded);
          } catch (e) {
            console.error("Could not decode error data");
          }
        }
      }
    } else {
      console.log("Token is already registered");
    }
  } catch (error) {
    console.error("Error in main execution:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Script failed:", error);
    process.exit(1);
  });
