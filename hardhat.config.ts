import "@matterlabs/hardhat-zksync";
import { HardhatUserConfig } from "hardhat/config";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
  },
  zksolc: {
    version: "1.5.15",
    compilerSource: "binary",
    settings: {
      evmVersion: "paris",
      optimizer: {
        enabled: true,
        mode: "3",
      },
    },
  },
  networks: {
    abstractTestnet: {
      url: process.env.ABSTRACT_RPC_URL || "https://api.testnet.abs.xyz",
      ethNetwork: "sepolia",
      zksync: true,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      verifyURL: "https://api-explorer-verify.testnet.abs.xyz/contract_verification",
    },
  },
};

export default config;
