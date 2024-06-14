// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import {BaseTest, console2} from "./BaseTest.sol";

contract MockTest is BaseTest {
    Mock internal mock;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        _setUp();
        mock = new Mock();
    }

    function test_increment_Success() external {
        mock.increment();
        assertEq(mock.counter(), 1);
    }
}
