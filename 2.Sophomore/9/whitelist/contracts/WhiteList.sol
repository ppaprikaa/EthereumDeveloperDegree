// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract WhiteList {
    uint8 public maxWhiteListAddresses;
    mapping (address => bool) public whiteListAddresses;
    uint8 public numWhiteListAddresses;

    constructor(uint8 _maxWhiteListAddresses) {
        maxWhiteListAddresses = _maxWhiteListAddresses;
    }

    function addAddrToWhiteList() public {
        require(!whiteListAddresses[msg.sender], "Sender has already been whitelisted.");
        require(numWhiteListAddresses < maxWhiteListAddresses, "limit of addresses reached");
        whiteListAddresses[msg.sender] = true;
        numWhiteListAddresses++;
    }
}
