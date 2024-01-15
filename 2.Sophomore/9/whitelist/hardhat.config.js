require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config({path: ".env"})

/** @type import('hardhat/config').HardhatUserConfig */

const QUICKNODE_URL = process.env.RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY

module.exports = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: QUICKNODE_URL,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  }
};
