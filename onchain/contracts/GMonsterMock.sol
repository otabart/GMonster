// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {GMonster, Challenge} from "./GMonster.sol";

// import {console2} from "forge-std/console2.sol";

contract GMonsterMock is GMonster {
    function getLostChallengeCount(
        Challenge memory _challenge,
        uint _timestamp
    ) public view returns (uint, bool) {
        return _getLostChallengeCount(_challenge, _timestamp);
    }
}
