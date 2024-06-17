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
        gmon = new GMonsterMock();
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
}
