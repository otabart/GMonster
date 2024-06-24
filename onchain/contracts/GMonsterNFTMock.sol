// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {GMonsterNFT} from "./GMonsterNFT.sol";

// import {console2} from "forge-std/console2.sol";

contract GMonsterNFTMock is GMonsterNFT {
    constructor(
        uint _seasonStartTimestamp
    ) GMonsterNFT(_seasonStartTimestamp) {}

    function mint(address to) external {
        _mint(to);
    }
}
