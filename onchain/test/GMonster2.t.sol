// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import {BaseTest, console2} from "./BaseTest.sol";
import {GMonsterMock} from "../contracts/GMonsterMock.sol";
import {Challenge, GMonster} from "../contracts/GMonster.sol";

contract GMonster2Test is BaseTest {
    GMonsterMock internal gmon;
    uint internal NINE_JST = 1718323200; // 2024-06-14 9:00 AM in GMT+9
    uint internal DEPOSIT = 0.069 ether;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        _setUp();
        gmon = new GMonsterMock(NINE_JST);
    }

    function test_deposit_Fail1() external {
        vm.expectRevert(bytes(gmon.ERROR_DEPOSIT1()));
        gmon.deposit{value: 0.1 ether}(NINE_JST);
    }

    function test_deposit_Fail2() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.expectRevert(bytes(gmon.ERROR_DEPOSIT2()));
        gmon.deposit{value: DEPOSIT}(NINE_JST);
    }

    function test_deposit_Fail3() external {
        vm.warp(NINE_JST);
        vm.expectRevert(bytes(gmon.ERROR_DEPOSIT3()));
        gmon.deposit{value: DEPOSIT}(10);
    }

    function test_deposit_Success1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        (
            uint _deposit,
            uint _initialChallengeTime,
            uint _lastChallengeTime,
            uint8 _suceededChallengeCount,
            uint8 _continuousSuceededCount
        ) = gmon.challenges(address(this));
        assertEq(_deposit, DEPOSIT);
        assertEq(_initialChallengeTime, NINE_JST);
        assertEq(_lastChallengeTime, 0);
        assertEq(_suceededChallengeCount, 0);
        assertEq(_continuousSuceededCount, 0);
    }

    function test_challenge_Fail1() external {
        vm.expectRevert(bytes(gmon.ERROR_CHALLENGE1()));
        gmon.challenge();
    }

    function test_challenge_Fail2() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        for (uint8 i = 0; i < 21; i++) {
            vm.warp(NINE_JST - 1 hours + (i * 1 days));
            gmon.challenge();
        }
        vm.expectRevert(bytes(gmon.ERROR_CHALLENGE2()));
        gmon.challenge();
    }

    function test_challenge_Fail3() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.warp(NINE_JST);
        gmon.challenge();
        vm.expectRevert(bytes(gmon.ERROR_CHALLENGE3()));
        gmon.challenge();
    }

    function test_challenge_Fail4() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.warp(NINE_JST + 4 days);
        vm.expectRevert(bytes(gmon.ERROR_CHALLENGE4()));
        gmon.challenge();
    }

    function test_challenge_Fail5() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.warp(NINE_JST);
        gmon.challenge();
        vm.warp(NINE_JST + 20 hours);
        vm.expectRevert(bytes(gmon.ERROR_CHALLENGE5()));
        gmon.challenge();
    }

    function test_challenge_Success1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.warp(NINE_JST - 10);
        gmon.challenge();
        (
            uint _deposit,
            uint _initialChallengeTime,
            uint _lastChallengeTime,
            uint8 _suceededChallengeCount,
            uint8 _continuousSuceededCount
        ) = gmon.challenges(address(this));
        assertEq(_deposit, DEPOSIT);
        assertEq(_initialChallengeTime, NINE_JST);
        assertEq(_lastChallengeTime, NINE_JST - 10);
        assertEq(_suceededChallengeCount, 1);
        assertEq(_continuousSuceededCount, 1);
    }

    function test_challenge_Success2() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        for (uint8 i = 0; i < 5; i++) {
            vm.warp(NINE_JST - 1 hours + (i * 1 days));
            gmon.challenge();
        }
        (
            ,
            ,
            ,
            uint8 _suceededChallengeCount,
            uint8 _continuousSuceededCount
        ) = gmon.challenges(address(this));
        assertEq(_suceededChallengeCount, 5);
        assertEq(_continuousSuceededCount, 5);
    }

    function test_challenge_Success3() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        for (uint8 i = 0; i < 5; i++) {
            vm.warp(NINE_JST - 1 hours + (i * 1 days));
            gmon.challenge();
        }
        //skip i = 5
        for (uint8 i = 6; i < 10; i++) {
            vm.warp(NINE_JST - 1 hours + (i * 1 days));
            gmon.challenge();
        }
        (
            ,
            ,
            ,
            uint8 _suceededChallengeCount,
            uint8 _continuousSuceededCount
        ) = gmon.challenges(address(this));
        assertEq(_suceededChallengeCount, 9);
        assertEq(_continuousSuceededCount, 4);
    }

    function test_withdraw_Fail1() external {
        vm.expectRevert(bytes(gmon.ERROR_WITHDRAW1()));
        gmon.withdraw();
    }

    function test_withdraw_Fail2() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.expectRevert(bytes(gmon.ERROR_WITHDRAW2()));
        gmon.withdraw();
    }

    function test_withdraw_Fail3() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        for (uint8 i = 0; i < 19; i++) {
            vm.warp(NINE_JST - 1 hours + (i * 1 days));
            gmon.challenge();
        }
        vm.expectRevert(bytes(gmon.ERROR_WITHDRAW3()));
        gmon.withdraw();
    }

    function test_withdraw_Success1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        assertEq(address(gmon).balance, DEPOSIT);
        for (uint8 i = 0; i < 21; i++) {
            vm.warp(NINE_JST - 1 hours + (i * 1 days));
            gmon.challenge();
        }
        vm.warp(NINE_JST + (20 * 1 days) + 1);
        gmon.withdraw();
        assertEq(address(gmon).balance, 0);

        (
            uint _deposit,
            uint _initialChallengeTime,
            uint _lastChallengeTime,
            uint8 _suceededChallengeCount,
            uint8 _continuousSuceededCount
        ) = gmon.challenges(address(this));
        assertEq(_deposit, 0);
        assertEq(_initialChallengeTime, 0);
        assertEq(_lastChallengeTime, 0);
        assertEq(_suceededChallengeCount, 0);
        assertEq(_continuousSuceededCount, 0);
    }
}
