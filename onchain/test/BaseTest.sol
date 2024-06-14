// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.24 <0.9.0;

import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";

contract BaseTest is Test {
    /// @dev A function invoked before each test case is run.
    function _setUp() public virtual {}
}
