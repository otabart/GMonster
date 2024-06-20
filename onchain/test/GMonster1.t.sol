// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import {BaseTest, console2} from "./BaseTest.sol";
import {GMonsterMock} from "../contracts/GMonsterMock.sol";
import {Challenge, GMonster} from "../contracts/GMonster.sol";

contract GMonster1Test is BaseTest {
    GMonsterMock internal gmon;
    uint internal NINE_JST = 1718323200; // 2024-06-14 9:00 AM in GMT+9

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        _setUp();
        gmon = new GMonsterMock(NINE_JST);
    }

    function test_getLostCountAndIsSpan_Success0() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });
        uint _timestamp = NINE_JST;
        (uint _lostChallengeCount, ) = gmon.getLostCountAndIsSpan(
            _challenge,
            _timestamp
        );
        assertEq(_lostChallengeCount, 0);
        assertEq(gmon.judgeFailOrNot(_challenge, _timestamp), false);
    }

    function test_getLostCountAndIsSpan_Success1() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 1,
            continuousSuceededCount: 0
        });
        uint _timestamp = NINE_JST + 1 days;
        (uint _lostChallengeCount, ) = gmon.getLostCountAndIsSpan(
            _challenge,
            _timestamp
        );
        assertEq(_lostChallengeCount, 0);
        assertEq(gmon.judgeFailOrNot(_challenge, _timestamp), false);
    }

    function test_getLostCountAndIsSpan_Success2() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });
        uint _timestamp = NINE_JST + 3 days;
        (uint _lostChallengeCount, ) = gmon.getLostCountAndIsSpan(
            _challenge,
            _timestamp
        );
        assertEq(_lostChallengeCount, 3);
        assertEq(gmon.judgeFailOrNot(_challenge, _timestamp), false);
    }

    function test_getLostCountAndIsSpan_Success3() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 1,
            continuousSuceededCount: 0
        });
        uint _timestamp = NINE_JST + 3 days;
        (uint _lostChallengeCount, ) = gmon.getLostCountAndIsSpan(
            _challenge,
            _timestamp
        );
        assertEq(_lostChallengeCount, 2);
        assertEq(gmon.judgeFailOrNot(_challenge, _timestamp), false);
    }

    function test_getLostCountAndIsSpan_Success4() external view {
        //Todays challenge is suceeded
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: NINE_JST + 3 days - 1,
            suceededChallengeCount: 1,
            continuousSuceededCount: 0
        });
        uint _timestamp = NINE_JST + 3 days;
        (uint _lostChallengeCount, ) = gmon.getLostCountAndIsSpan(
            _challenge,
            _timestamp
        );
        assertEq(_lostChallengeCount, 3);
        assertEq(gmon.judgeFailOrNot(_challenge, _timestamp), false);
    }

    function test_getLostCountAndIsSpan_Success5() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 1,
            continuousSuceededCount: 0
        });
        uint _timestamp = NINE_JST + 3 days + 1; // missed 4th day
        (uint _lostChallengeCount, ) = gmon.getLostCountAndIsSpan(
            _challenge,
            _timestamp
        );
        assertEq(_lostChallengeCount, 3);
        assertEq(gmon.judgeFailOrNot(_challenge, _timestamp), false);
    }

    function test_getLostCountAndIsSpan_Fail1() external view {
        Challenge memory _challenge = Challenge({
            deposit: gmon.DEPOSIT(),
            initialChallengeTime: NINE_JST,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });
        uint _timestamp = NINE_JST + 3 days + 1; // missed 4th day
        (uint _lostChallengeCount, ) = gmon.getLostCountAndIsSpan(
            _challenge,
            _timestamp
        );
        assertEq(_lostChallengeCount, 4);
        assertEq(gmon.judgeFailOrNot(_challenge, _timestamp), true);
    }
}
