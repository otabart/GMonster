// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {console2} from "forge-std/console2.sol";

/*//////////////////////////////////////////////////////////////
                            STRUCTS
//////////////////////////////////////////////////////////////*/

struct Challenge {
    uint deposit;
    uint initialChallengeTime;
    uint lastChallengeTime;
    uint8 suceededChallengeCount;
    uint8 continuousSuceededCount;
}

/*//////////////////////////////////////////////////////////////
                            EVENTS
//////////////////////////////////////////////////////////////*/

//TODO calculate success and fail term count

contract GMonster {
    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    string public constant ERROR_DEPOSIT1 = "GMonster: Invalid deposit amount";
    string public constant ERROR_DEPOSIT2 = "GMonster: Already deposited";
    string public constant ERROR_DEPOSIT3 =
        "GMonster: Invalid initial challenge time";
    string public constant ERROR_CHALLENGE1 = "GMonster: Not deposited";
    string public constant ERROR_CHALLENGE2 =
        "GMonster: Challenge already finished";
    string public constant ERROR_CHALLENGE3 = "GMonster: Challenge duplicated";
    string public constant ERROR_CHALLENGE4 = "GMonster: Out challenge span";
    string public constant ERROR_CHALLENGE5 =
        "GMonster: Challenge already failed";
    string public constant ERROR_WITHDRAW1 = "GMonster: Not deposited";
    string public constant ERROR_WITHDRAW2 =
        "GMonster: Challenge count not enough";
    string public constant ERROR_WITHDRAW3 =
        "GMonster: Challenge span not finished";
    string public constant ERROR_WITHDRAW4 = "GMonster: Transfer failed";
    string public constant ERROR_ROB1 = "GMonster: Not participated";
    string public constant ERROR_ROB2 = "GMonster: Not robable";
    string public constant ERROR_ROB3 = "GMonster: Transfer failed";

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/
    uint public constant DEPOSIT = 0.069 ether;
    uint public constant CHALLENGE_COUNT = 21;
    uint public constant LOSTABLE_CHALLENGE_COUNT = 3;
    uint public constant LOST_FEE_RATE = 20; //20%
    uint public constant CHALLENGE_TIME_SPAN = 3 hours;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    mapping(address => Challenge) public challenges;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /*//////////////////////////////////////////////////////////////
                            OWNER UPDATE
    //////////////////////////////////////////////////////////////*/
    /*//////////////////////////////////////////////////////////////
                            EXTERNAL UPDATE
    //////////////////////////////////////////////////////////////*/

    function deposit(uint _initialChallengeTime) public payable {
        require(msg.value == DEPOSIT, ERROR_DEPOSIT1);
        console2.log(
            "challenges[msg.sender].deposit",
            challenges[msg.sender].deposit
        );
        require(challenges[msg.sender].deposit == 0, ERROR_DEPOSIT2);
        require(_initialChallengeTime > block.timestamp, ERROR_DEPOSIT3);
        challenges[msg.sender] = Challenge({
            deposit: msg.value,
            initialChallengeTime: _initialChallengeTime,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });
    }

    function challenge() external {
        Challenge memory _challenge = challenges[msg.sender];
        //Validations
        require(_challenge.deposit >= DEPOSIT, ERROR_CHALLENGE1);
        require(
            _challenge.suceededChallengeCount < CHALLENGE_COUNT,
            ERROR_CHALLENGE2
        );
        //Today's challenge is already done
        require(
            block.timestamp >
                _challenge.lastChallengeTime + CHALLENGE_TIME_SPAN,
            ERROR_CHALLENGE3
        );

        (
            uint _lostChallengeCount,
            bool _isChallengeSpan
        ) = _getLostChallengeCount(_challenge, block.timestamp);
        require(_isChallengeSpan, ERROR_CHALLENGE4);
        require(
            _lostChallengeCount <= LOSTABLE_CHALLENGE_COUNT,
            ERROR_CHALLENGE5
        );

        //Judge continuous or not
        uint8 _continuousSuceededCount = _challenge.continuousSuceededCount;
        if (
            block.timestamp <
            _challenge.lastChallengeTime + 1 days + CHALLENGE_TIME_SPAN
        ) {
            _continuousSuceededCount += 1;
        }

        challenges[msg.sender] = Challenge({
            deposit: _challenge.deposit,
            initialChallengeTime: _challenge.initialChallengeTime,
            lastChallengeTime: block.timestamp,
            suceededChallengeCount: _challenge.suceededChallengeCount + 1,
            continuousSuceededCount: _continuousSuceededCount
        });
    }

    function withdraw() public returns (uint) {
        Challenge memory _challenge = challenges[msg.sender];
        require(_challenge.deposit >= DEPOSIT, ERROR_WITHDRAW1);
        require(
            _challenge.suceededChallengeCount >=
                CHALLENGE_COUNT - LOSTABLE_CHALLENGE_COUNT,
            ERROR_WITHDRAW2
        );
        require(
            block.timestamp >
                _challenge.initialChallengeTime +
                    ((CHALLENGE_COUNT - 1) * 1 days),
            ERROR_WITHDRAW3
        );

        //Store memory to use later
        uint _deposited = _challenge.deposit;
        uint _initialChallengeTime = _challenge.initialChallengeTime;

        challenges[msg.sender] = Challenge({
            deposit: 0,
            initialChallengeTime: 0,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });

        (bool success, ) = msg.sender.call{value: _deposited}("");
        require(success, ERROR_WITHDRAW4);

        //Return for reChallenge
        return _initialChallengeTime;
    }

    // TODO reChallenge
    // function reChallenge() external {
    //     uint _initialChallengeTime = withdraw();
    //     //Set initial on after 21 days
    //     deposit(_initialChallengeTime + (CHALLENGE_COUNT * 1 days));
    // }

    function rob(address _target) external payable {
        Challenge memory _robberChallenge = challenges[msg.sender];
        //Validations
        require(_robberChallenge.deposit >= DEPOSIT, ERROR_ROB1);

        Challenge memory _targetChallenge = challenges[_target];
        require(_judgeFailOrNot(_targetChallenge, block.timestamp), ERROR_ROB2);

        //Store memory to use later
        uint _deposited = _targetChallenge.deposit;

        challenges[_target] = Challenge({
            deposit: 0,
            initialChallengeTime: 0,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });

        // payable(msg.sender).transfer(_deposited);
        (bool success, ) = msg.sender.call{value: _deposited}("");
        require(success, ERROR_ROB3);

        //TODO event
    }

    /*//////////////////////////////////////////////////////////////
                             EXTERNAL VIEW
    //////////////////////////////////////////////////////////////*/
    function robbable(address _challenger) public view returns (bool) {
        Challenge memory _challenge = challenges[_challenger];
        return _judgeFailOrNot(_challenge, block.timestamp);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL UPDATE
    //////////////////////////////////////////////////////////////*/
    /*//////////////////////////////////////////////////////////////
                             INTERNAL VIEW
    //////////////////////////////////////////////////////////////*/
    function _getLostChallengeCount(
        Challenge memory _challenge,
        uint _timestamp
    )
        internal
        view
        virtual
        returns (uint8 lostChallengeCount_, bool isChallengeSpan_)
    {
        uint8 _counter;
        for (uint8 i = _challenge.suceededChallengeCount; i < 21; i++) {
            uint _pastDays = i * 1 days;
            if (
                _timestamp <
                _challenge.initialChallengeTime +
                    _pastDays -
                    CHALLENGE_TIME_SPAN
            ) {
                //Todays challenge is not started yet
                _counter = i;
                break;
            } else if (
                _timestamp <= _challenge.initialChallengeTime + _pastDays
            ) {
                //Challenging span
                if (
                    _timestamp <
                    _challenge.lastChallengeTime + CHALLENGE_TIME_SPAN
                ) {
                    //Already challenged
                    _counter = i + 1;
                } else {
                    isChallengeSpan_ = true;
                    _counter = i;
                }

                break;
            }
        }

        //SuceededChallengeCount is updated
        lostChallengeCount_ = _counter - (_challenge.suceededChallengeCount);
    }

    //If failed, return true
    function _judgeFailOrNot(
        Challenge memory _challenge,
        uint _timestamp
    ) internal view returns (bool) {
        console2.log("Deposit: %d", _challenge.deposit);
        if (_challenge.deposit < DEPOSIT) return false;

        (uint _lostChallengeCount, ) = _getLostChallengeCount(
            _challenge,
            _timestamp
        );
        console2.log("LostChallengeCount: %d", _lostChallengeCount);
        if (_lostChallengeCount > LOSTABLE_CHALLENGE_COUNT) return true;

        return false;
    }
}
