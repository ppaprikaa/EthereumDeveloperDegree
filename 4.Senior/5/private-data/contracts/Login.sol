// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Login {
    bytes32 private username;
    bytes32 private password;

    constructor(bytes32 _username, bytes32 _password) {
        username = _username;
        password = _password;
    }
}
