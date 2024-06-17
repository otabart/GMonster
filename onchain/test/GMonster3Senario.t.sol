// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import {BaseTest, console2} from "./BaseTest.sol";
import {GMonsterMock} from "../contracts/GMonsterMock.sol";
import {Challenge, GMonster} from "../contracts/GMonster.sol";

contract GMonster3SenarioTest is BaseTest {
    GMonsterMock internal gmon;
    uint internal NINE_JST = 1718323200; // 2024-06-14 9:00 AM in GMT+9
    uint internal DEPOSIT = 0.069 ether;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        _setUp();
        gmon = new GMonsterMock();
    }

    //No miss
    function test_senario_Success1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        assertEq(address(gmon).balance, DEPOSIT);
        for (uint8 i = 0; i < 21; i++) {
            console2.log("i: ", i);
            vm.warp(NINE_JST - 1 hours + (i * 1 days));
            gmon.challenge();
        }
        vm.warp(NINE_JST - 1 hours + 21 * 1 days);
        gmon.withdraw();
        assertEq(address(gmon).balance, 0);
    }

    //TODO assert balance
    function test_senario_Fail1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        assertEq(address(gmon).balance, DEPOSIT);
        vm.warp(NINE_JST + 3 days);
        assertEq(gmon.robbable(address(this)), false);
        vm.warp(NINE_JST + 3 days + 1);
        assertEq(gmon.robbable(address(this)), true);
        vm.startPrank(alice);
        gmon.deposit{value: DEPOSIT}(NINE_JST + 4 days);
        gmon.rob(address(this));
        vm.stopPrank();
    }

    function test_transfer() external {
        TransferMock mock = new TransferMock();
        vm.startPrank(alice);
        console2.log(alice.balance);
        address(mock).call{value: 2 ether}("");
        console2.log(alice.balance);
        mock.transfer(1 ether);
        console2.log(alice.balance);
        vm.stopPrank();
    }
}

contract TransferMock {
    function transfer(uint _value) public {
        (bool success, ) = msg.sender.call{value: _value}("");
        require(success, "Transfer failed.");
    }

    function transfer2(uint _value) public {
        payable(msg.sender).transfer(_value);
        (bool success, ) = msg.sender.call{value: _value}("");
        require(success, "Transfer failed.");
    }

    receive() external payable {}
}
