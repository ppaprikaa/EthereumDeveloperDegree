const hre = require("hardhat");

const contractAddress = "0xfA4DF9E8fC45E0C8f219eB7CbDa64fDccD95F124";

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const nftContract = await hre.ethers.deployContract("CryptoDevs", [contractAddress]);

  await nftContract.waitForDeployment();

  console.log("NFT Contract Address:", nftContract.target);

  await sleep(30 * 1000); // 30s = 30 * 1000 milliseconds

  await hre.run("verify:verify", {
    address: nftContract.target,
    constructorArguments: [contractAddress],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });