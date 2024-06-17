// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.24 <0.9.0;

import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";

contract BaseTest is Test {
    address internal alice = address(1);
    address internal bob = address(2);
    address internal charlie = address(3);

    /// @dev A function invoked before each test case is run.
    function _setUp() public virtual {
        deal(alice, 10 ether);
        deal(bob, 10 ether);
        deal(charlie, 10 ether);
    }

    receive() external payable {
        console2.log("recieve: ", msg.value);
    }
}
