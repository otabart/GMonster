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

    //Two persons
    function test_senario_Success2() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        //Alice
        vm.prank(alice);
        gmon.deposit{value: DEPOSIT}(NINE_JST + 1 days);

        vm.warp(NINE_JST - 1 hours);
        gmon.challenge();

        for (uint8 i = 0; i < 20; i++) {
            vm.warp(NINE_JST - 1 hours + 1 days + (i * 1 days));
            gmon.challenge();
            vm.prank(alice);
            gmon.challenge();
        }

        //Alice missed one challenge

        assertEq(address(gmon).balance, DEPOSIT * 2);
        vm.warp(NINE_JST + 20 * 1 days + 1);
        gmon.withdraw();
        assertEq(address(gmon).balance, DEPOSIT);
        vm.warp(NINE_JST + 21 * 1 days + 1);
        vm.prank(alice);
        gmon.withdraw();
        assertEq(address(gmon).balance, 0);
    }

    function test_senario_Fail1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        assertEq(address(gmon).balance, DEPOSIT);
        //Not robbable
        vm.warp(NINE_JST + 3 days);
        assertEq(gmon.robbable(address(this)), false);
        //Robbable
        vm.warp(NINE_JST + 3 days + 1);
        assertEq(gmon.robbable(address(this)), true);
        //Alice rob
        vm.startPrank(alice);
        gmon.deposit{value: DEPOSIT}(NINE_JST + 4 days);
        uint _oldAliceBal = alice.balance;
        gmon.rob(address(this));
        vm.stopPrank();
        assertEq(alice.balance, _oldAliceBal + DEPOSIT);
    }
}
