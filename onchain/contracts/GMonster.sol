// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// import {console2} from "forge-std/console2.sol";

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
                            ERRORS
//////////////////////////////////////////////////////////////*/
/*//////////////////////////////////////////////////////////////
                            EVENTS
//////////////////////////////////////////////////////////////*/

//TODO calculate success and fail term count

contract GMonster {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint public DEPOSIT = 0.069 ether;
    uint public CHALLENGE_COUNT = 21;
    uint public LOSTABLE_CHALLENGE_COUNT = 3;
    uint public LOST_FEE_RATE = 20; //20%
    uint public CHALLENGE_TIME_PERIOD = 3 hours;

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
        require(msg.value == DEPOSIT, "GMonster: Invalid deposit amount");
        require(
            challenges[msg.sender].deposit == 0,
            "GMonster: Already deposited"
        );
        require(
            _initialChallengeTime > block.timestamp,
            "GMonster: Invalid initial challenge time"
        );
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
        require(_challenge.deposit >= DEPOSIT, "GMonster: Not deposited");
        require(
            _challenge.suceededChallengeCount < CHALLENGE_COUNT,
            "GMonster: Challenge already finished"
        );
        require(
            block.timestamp >
                _challenge.lastChallengeTime + CHALLENGE_TIME_PERIOD,
            "GMonster: Challenge duplicated"
        );

        (
            uint _lostChallengeCount,
            bool _isChallengePeriod
        ) = _getLostChallengeCount(_challenge, block.timestamp);
        require(!_isChallengePeriod, "GMonster: Challenge period");
        require(
            _lostChallengeCount <= LOSTABLE_CHALLENGE_COUNT,
            "GMonster: Lost too many challenges"
        );

        //Judge continuous or not
        uint8 _continuousSuceededCount = _challenge.continuousSuceededCount;
        if (
            block.timestamp <
            _challenge.lastChallengeTime + 1 days + CHALLENGE_TIME_PERIOD
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

    //TODO
    function withdraw() public returns (uint) {
        Challenge memory _challenge = challenges[msg.sender];
        require(_challenge.deposit >= DEPOSIT, "GMonster: Not deposited");
        require(
            _challenge.suceededChallengeCount >=
                CHALLENGE_COUNT - LOSTABLE_CHALLENGE_COUNT,
            "GMonster: Challenge not finished"
        );
        require(
            block.timestamp >
                _challenge.initialChallengeTime +
                    ((CHALLENGE_COUNT - 1) * 1 days),
            "GMonster: Challenge not finished"
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

        payable(msg.sender).transfer(_deposited);

        //Return for reChallenge
        return _initialChallengeTime;
    }

    function reChallenge() external {
        uint _initialChallengeTime = withdraw();
        //Set initial on after 21 days
        deposit(_initialChallengeTime + (CHALLENGE_COUNT * 1 days));
    }

    function rob(address _challenger) external {
        //TODO: Anyone who are joined the challenge can rob the deposit of the challenger who lost the challenge
    }

    /*//////////////////////////////////////////////////////////////
                             EXTERNAL VIEW
    //////////////////////////////////////////////////////////////*/
    function judgeFailOrNot(
        address _challenger,
        uint _timestamp
    ) public view returns (bool) {
        Challenge memory _challenge = challenges[_challenger];
        if (_challenge.deposit < DEPOSIT) return false;

        (uint _lostChallengeCount, ) = _getLostChallengeCount(
            _challenge,
            _timestamp
        );
        if (_lostChallengeCount > LOSTABLE_CHALLENGE_COUNT) return true;

        return false;
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
        returns (uint8 lostChallengeCount_, bool isChallengePeriod_)
    {
        uint8 _counter;
        for (uint8 i = _challenge.suceededChallengeCount; i < 21; i++) {
            uint _pastDays = i * 1 days;
            if (
                _timestamp <
                _challenge.initialChallengeTime +
                    _pastDays -
                    CHALLENGE_TIME_PERIOD
            ) {
                //Todays challenge is not started yet
                _counter = i;
                break;
            } else if (
                _timestamp <= _challenge.initialChallengeTime + _pastDays
            ) {
                //Challenging period
                if (
                    _timestamp <
                    _challenge.lastChallengeTime + CHALLENGE_TIME_PERIOD
                ) {
                    //Already challenged
                    _counter = i + 1;
                } else {
                    isChallengePeriod_ = true;
                    _counter = i;
                }

                break;
            }
        }

        //SuceededChallengeCount is updated
        lostChallengeCount_ = _counter - (_challenge.suceededChallengeCount);
    }
}
