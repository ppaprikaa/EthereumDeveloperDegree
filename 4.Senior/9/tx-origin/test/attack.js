const { expect } = require("chai");
const hre = require("hardhat");

describe("tx.origin", () => {
  it("Attack.sol will be able to change the owner of Good.sol", async () => {
    const [_, address1] = await hre.ethers.getSigners();

    const GoodContract = await hre.ethers.getContractFactory("Good");
    const goodContract = await GoodContract.connect(address1).deploy();
    await goodContract.waitForDeployment();

    const attackContract = await hre.ethers.deployContract("Attack", [
      goodContract.target,
    ]);

    await attackContract.waitForDeployment();

    const txn = await attackContract.connect(address1).attack();
    await txn.wait();

    expect(await goodContract.owner()).to.equal(attackContract.target);
  });
});
