const { expect } = require("chai");
const hre = require("hardhat");

describe("Malicious External Contract", () => {
  it("Should change the owner of the Good Contract", async () => {
    const maliciousContract = await hre.ethers.deployContract("Malicious", []);
    await maliciousContract.waitForDeployment();

    const goodContract = await hre.ethers.deployContract(
      "Good",
      [maliciousContract.target],
      {
        value: hre.ethers.parseEther("3"),
      }
    );

    await goodContract.waitForDeployment();

    const [_, address1] = await hre.ethers.getSigners();

    const txn = await goodContract.connect(address1).addUserToList();
    await txn.wait();

    const eligible = await goodContract.connect(address1).isUserEligible();
    expect(eligible).to.equal(false);
  });
});
