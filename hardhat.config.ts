import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-verify";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          evmVersion: "paris",
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },

  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    "core-testnet": {
      url: "https://rpc.test2.btcs.network",
      accounts: [""],
      chainId: 1114,
    },
    "core-mainnet": {
      url: "https://rpc.coredao.org",
      accounts: [""],
      chainId: 1116,
    },
    "taiko-hekla": {
      url: "https://rpc.hekla.taiko.xyz",
      accounts: [""],
      chainId: 167009,
      gas: 5000000,
    },
  },

  etherscan: {
    apiKey: {
      "core-testnet": "b24e0e0773d940b782c3284b7cbefa35",
      "core-mainnet": "",
      "taiko-hekla": "",
    },
    customChains: [
      {
        network: "core-testnet", // Fixed: should match the network name
        chainId: 1114,
        urls: {
          apiURL: "https://api.test2.btcs.network/api",
          browserURL: "https://scan.test2.btcs.network/",
        },
      },
      {
        network: "core-mainnet",
        chainId: 1116,
        urls: {
          apiURL: "https://openapi.coredao.org/api",
          browserURL: "https://scan.coredao.org/",
        },
      },
      {
        network: "taiko-hekla",
        chainId: 167009,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/testnet/evm/167009/etherscan",
          browserURL: "https://hekla.taikoexplorer.com",
        },
      },
    ],
  },
  sourcify: {
    enabled: false,
    apiUrl: "https://server-verify.hashscan.io",
    browserUrl: "https://repository-verify.hashscan.io",
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};

export default config;
