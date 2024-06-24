// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import {BaseTest, console2} from "./BaseTest.sol";
import {GMonsterNFTMock} from "../contracts/GMonsterNFTMock.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract GMonsterNFTTest is BaseTest {
    using Base64 for string;

    GMonsterNFTMock internal nft;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        _setUp();
        nft = new GMonsterNFTMock();
    }

    function test_mint() external {
        nft.mint(alice);
        assertEq(nft.balanceOf(alice), 1);

        console2.log(nft.tokenURI(1));
    }
}
