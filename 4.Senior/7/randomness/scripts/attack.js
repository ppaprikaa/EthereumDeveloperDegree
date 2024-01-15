const { expect } = require("chai");
const hre = require("hardhat");

describe("Attack", () => {
  it("Should be able to guess the exact number", async () => {
    const gameContract = await hre.ethers.deployContract("Game", [], {
      value: hre.ethers.parseEther("0.1"),
    });

    await gameContract.waitForDeployment();

    const attackContract = await hre.ethers.deployContract("Attack", [
      gameContract.target,
    ]);

    await attackContract.waitForDeployment();

    const txn = await attackContract.attack();
    await txn.wait();

    expect(await gameContract.getBalance()).to.equal(BigInt("0"));
  });
});
