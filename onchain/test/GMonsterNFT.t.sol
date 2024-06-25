// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import {BaseTest, console2} from "./BaseTest.sol";
import {GMonsterNFT} from "../contracts/GMonsterNFT.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract GMonsterNFTTest is BaseTest {
    using Base64 for string;
    uint internal NINE_JST = 1718323200; // 2024-06-14 9:00 AM in GMT+9

    GMonsterNFT internal nft;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        _setUp();
        nft = new GMonsterNFT(address(this));
    }

    function test_mint() external {
        vm.warp(NINE_JST + 1 hours + 1 days);
        nft.mint(alice, NINE_JST);
        assertEq(nft.balanceOf(alice), 1);

        // console2.log(nft.tokenURI(1));
    }
}
