// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import {BaseTest, console2} from "./BaseTest.sol";
import {GMonsterMock} from "../contracts/GMonsterMock.sol";
import {Challenge, GMonster} from "../contracts/GMonster.sol";

contract GMonster3SenarioTest is BaseTest {
    GMonsterMock internal gmon;
    uint internal NINE_JST = 1718323200; // 2024-06-14 9:00 AM in GMT+9
    uint internal DEPOSIT = 0.002 ether;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        _setUp();
        gmon = new GMonsterMock(NINE_JST - 6 hours);
    }

    //No miss
    function test_senario_Success1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        assertEq(address(gmon).balance, DEPOSIT);
        for (uint8 i = 0; i < 21; i++) {
            // console2.log("i: ", i);
            vm.warp(NINE_JST - 1 hours + (i * 1 days));
            gmon.challenge();
        }
        vm.warp(NINE_JST - 1 hours + 21 * 1 days + 1 days);
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
        vm.warp(NINE_JST + 22 * 1 days);
        assertEq(address(gmon).balance, DEPOSIT * 2);
        gmon.withdraw();
        assertEq(address(gmon).balance, DEPOSIT);
        vm.prank(alice);
        gmon.withdraw();
        assertEq(address(gmon).balance, 0);
    }

    //Three persons challenge but one failed
    function test_senario_Success3() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        //Alice
        vm.prank(alice);
        gmon.deposit{value: DEPOSIT}(NINE_JST + 1 days);
        //Bob
        vm.prank(bob);
        gmon.deposit{value: DEPOSIT}(NINE_JST + 6 hours);

        // address(this)
        for (uint8 i = 0; i < 21; i++) {
            vm.warp(NINE_JST - 1 hours + (i * 1 days));
            gmon.challenge();
        }

        //Alice
        for (uint8 i = 0; i < 20; i++) {
            vm.warp(NINE_JST + 1 days - 1 hours + (i * 1 days));
            vm.prank(alice);
            gmon.challenge();
        }

        //Bob failed
        for (uint8 i = 0; i < 10; i++) {
            vm.warp(NINE_JST + 6 hours - 1 hours + (i * 1 days));
            vm.prank(bob);
            gmon.challenge();
        }

        vm.warp(NINE_JST + 21 * 1 days);

        bool isBobFailed = gmon.judgeFailOrNot(address(this));
        console2.log("isBobFailed: ", isBobFailed);

        //Fix fail to Bob
        (, , , , uint fixedBalance1) = gmon.season();
        assertEq(fixedBalance1, 0);
        gmon.fixFail(bob);
        (, , , , uint fixedBalance2) = gmon.season();
        assertEq(fixedBalance2, DEPOSIT * 3 - gmon.FIX_FAIL_FEE());
    }

    function test_senario_Fail1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.startPrank(alice);
        gmon.deposit{value: DEPOSIT}(NINE_JST + 4 days);
        vm.stopPrank();
        assertEq(address(gmon).balance, DEPOSIT * 2);

        //Not robbable
        vm.warp(NINE_JST + 3 days);
        assertEq(gmon.judgeFailOrNot(address(this)), false);
        //Robbable
        vm.warp(NINE_JST + 3 days + 1);
        assertEq(gmon.judgeFailOrNot(address(this)), true);
        //Alice rob
        uint _oldAliceBal = alice.balance;
        vm.startPrank(alice);
        gmon.fixFail(address(this));
        vm.stopPrank();
        assertEq(alice.balance, _oldAliceBal + gmon.FIX_FAIL_FEE());
    }
}
