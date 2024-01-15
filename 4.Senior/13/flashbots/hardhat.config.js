require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

module.exports = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: process.env.QUICKNODE_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};

