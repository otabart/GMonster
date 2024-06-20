// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {GMonster, Challenge} from "./GMonster.sol";

// import {console2} from "forge-std/console2.sol";

contract GMonsterMock is GMonster {
    constructor(uint _seasonStartTimestamp) GMonster(_seasonStartTimestamp) {}

    function getLostCountAndIsSpan(
        Challenge memory _challenge,
        uint _timestamp
    ) public view returns (uint, bool) {
        return _getLostCountAndIsSpan(_challenge, _timestamp);
    }

    function judgeFailOrNot(
        Challenge memory _challenge,
        uint _timestamp
    ) public view returns (bool) {
        return _judgeFailOrNot(_challenge, _timestamp);
    }
}
