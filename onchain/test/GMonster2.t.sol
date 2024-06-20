// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import {BaseTest, console2} from "./BaseTest.sol";
import {GMonsterMock} from "../contracts/GMonsterMock.sol";
import {Challenge, Season, GMonster} from "../contracts/GMonster.sol";

contract GMonster2Test is BaseTest {
    GMonsterMock internal gmon;
    uint internal constant NINE_JST = 1718323200; // 2024-06-14 9:00 AM in GMT+9
    uint internal constant DEPOSIT = 0.002 ether;
    uint internal constant SEASON_START_TIME = NINE_JST - 6 hours;
    uint internal seasonEndTime = SEASON_START_TIME + (21 * 1 days);

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        _setUp();
        gmon = new GMonsterMock(SEASON_START_TIME);
    }

    function test_deposit_Fail1() external {
        vm.warp(NINE_JST + 1);
        vm.expectRevert(bytes(gmon.ERR_DEPOSIT_SEASON()));
        gmon.deposit{value: DEPOSIT}(NINE_JST);
    }

    function test_deposit_Fail2() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.expectRevert(bytes(gmon.ERR_DEPOSIT_DUPLICATE()));
        gmon.deposit{value: DEPOSIT}(NINE_JST);
    }

    function test_deposit_Fail3() external {
        vm.expectRevert(bytes(gmon.ERR_DEPOSIT_AMOUNT()));
        gmon.deposit{value: 0.1 ether}(NINE_JST);
    }

    function test_deposit_Fail4() external {
        vm.expectRevert(bytes(gmon.ERR_DEPOSIT_INITIALTIME()));
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
        assertEq(address(gmon).balance, DEPOSIT);
        assertEq(gmon.maxChallengerCount(), 1);
        assertEq(gmon.challengerAddresses(0), address(this));
    }

    function test_challenge_Fail1() external {
        vm.warp(NINE_JST);
        vm.expectRevert(bytes(gmon.ERR_CHALLENGE_NOT_DEPOSITED()));
        gmon.challenge();
    }

    function test_challenge_Fail2() external {
        vm.expectRevert(bytes(gmon.ERR_CHALLENGE_OUTOFSEASON()));
        gmon.challenge();
        vm.warp(NINE_JST + (100 * 1 days));
        vm.expectRevert(bytes(gmon.ERR_CHALLENGE_OUTOFSEASON()));
        gmon.challenge();
    }

    function test_challenge_Fail3() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.warp(NINE_JST);
        gmon.challenge();
        vm.expectRevert(bytes(gmon.ERR_CHALLENGE_DEPULICATED()));
        gmon.challenge();
    }

    function test_challenge_Fail4() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.warp(NINE_JST + 4 days);
        vm.expectRevert(bytes(gmon.ERR_CHALLENGE_FAILED()));
        gmon.challenge();
    }

    function test_challenge_Fail5() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.warp(NINE_JST);
        gmon.challenge();
        vm.warp(NINE_JST + 20 hours);
        vm.expectRevert(bytes(gmon.ERR_CHALLENGE_OUTOFSPAN()));
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

    function test_fixSeason_Fail1() external {
        vm.expectRevert(bytes(gmon.ERR_FIX1()));
        gmon.fixSeason();
    }

    function test_fixSeason_Fail2() external {
        vm.warp(seasonEndTime + 1);
        gmon.fixSeason();
        vm.expectRevert(bytes(gmon.ERR_FIX2()));
        gmon.fixSeason();
    }

    function test_fixSeason_Success1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.warp(seasonEndTime + 1);
        gmon.fixSeason();
        (, , bool _isSeasonFixed, uint _fixedBalance) = gmon.season();
        assertEq(_isSeasonFixed, true);
        assertEq(_fixedBalance, DEPOSIT);
    }

    function test_withdraw_Fail0() external {
        vm.expectRevert(bytes(gmon.ERR_WITHDRAW5()));
        gmon.withdraw();
    }

    function test_withdraw_Fail1() external {
        vm.warp(seasonEndTime + 1);
        gmon.fixSeason();
        vm.expectRevert(bytes(gmon.ERR_WITHDRAW1()));
        gmon.withdraw();
    }

    function test_withdraw_Fail2() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.warp(seasonEndTime + 1);
        gmon.fixSeason();
        vm.expectRevert(bytes(gmon.ERR_WITHDRAW2()));
        gmon.withdraw();
    }

    function test_withdraw_Success1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        assertEq(address(gmon).balance, DEPOSIT);
        for (uint8 i = 0; i < 21; i++) {
            vm.warp(NINE_JST - 1 hours + (i * 1 days));
            gmon.challenge();
        }
        vm.warp(seasonEndTime + 1);
        gmon.fixSeason();
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

    function test_fixFail_Fail1() external {
        vm.expectRevert(bytes(gmon.ERR_FIXFAIL_SEASON()));
        gmon.fixFail(address(this));
    }

    function test_fixFail_Fail2() external {
        vm.warp(seasonEndTime + 1);
        gmon.fixSeason();
        vm.expectRevert(bytes(gmon.ERR_FIXFAIL_FIXED()));
        gmon.fixFail(address(this));
    }

    function test_fixFail_Fail3() external {
        vm.warp(NINE_JST);
        vm.expectRevert(bytes(gmon.ERR_FIXFAIL1()));
        gmon.fixFail(address(this));
    }

    function test_fixFail_Fail4() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        vm.warp(NINE_JST);
        vm.expectRevert(bytes(gmon.ERR_FIXFAIL2()));
        gmon.fixFail(address(this));
    }

    function test_fixFail_Success1() external {
        gmon.deposit{value: DEPOSIT}(NINE_JST);
        //Alice will fix owner's fail
        vm.startPrank(alice);
        gmon.deposit{value: DEPOSIT}(NINE_JST + 4 days);
        vm.stopPrank();

        vm.warp(NINE_JST + 3 days + 1);
        assertEq(gmon.judgeFailOrNot(address(this)), true);

        //fixFail
        vm.startPrank(alice);
        uint _oldAliceBal = alice.balance;
        gmon.fixFail(address(this));
        vm.stopPrank();

        //Assertions
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
        assertEq(alice.balance, _oldAliceBal + gmon.FIX_FAIL_FEE());
        assertEq(gmon.fixFailedCount(), 1);
    }
}
