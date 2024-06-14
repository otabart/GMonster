// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import {BaseTest, console2} from "./BaseTest.sol";
import {GMonsterMock} from "../contracts/GMonsterMock.sol";
import {Challenge, GMonster} from "../contracts/GMonster.sol";

contract GMonsterTest is BaseTest {
    GMonsterMock internal gmon;
    uint internal NINE_JST = 1718323200; // 2024-06-14 9:00 AM in GMT+9

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        _setUp();
        gmon = new GMonsterMock();
    }

    function test_getLostChallengeCount_Success0() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });
        (uint _lostChallengeCount, ) = gmon.getLostChallengeCount(
            _challenge,
            NINE_JST
        );
        assertEq(_lostChallengeCount, 0);
    }

    function test_getLostChallengeCount_Success1() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 1,
            continuousSuceededCount: 0
        });
        (uint _lostChallengeCount, ) = gmon.getLostChallengeCount(
            _challenge,
            NINE_JST + 1 days
        );
        assertEq(_lostChallengeCount, 0);
    }

    function test_getLostChallengeCount_Success2() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });
        (uint _lostChallengeCount, ) = gmon.getLostChallengeCount(
            _challenge,
            NINE_JST + 3 days
        );
        assertEq(_lostChallengeCount, 3);
    }

    function test_getLostChallengeCount_Success3() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 1,
            continuousSuceededCount: 0
        });
        (uint _lostChallengeCount, ) = gmon.getLostChallengeCount(
            _challenge,
            NINE_JST + 3 days
        );
        assertEq(_lostChallengeCount, 2);
    }

    function test_getLostChallengeCount_Success4() external view {
        //Todays challenge is suceeded
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: NINE_JST + 3 days - 1,
            suceededChallengeCount: 1,
            continuousSuceededCount: 0
        });
        (uint _lostChallengeCount, ) = gmon.getLostChallengeCount(
            _challenge,
            NINE_JST + 3 days
        );
        assertEq(_lostChallengeCount, 3);
    }

    function test_getLostChallengeCount_Success5() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 1,
            continuousSuceededCount: 0
        });
        (uint _lostChallengeCount, ) = gmon.getLostChallengeCount(
            _challenge,
            NINE_JST + 3 days + 1
        );
        assertEq(_lostChallengeCount, 3);
    }
}
