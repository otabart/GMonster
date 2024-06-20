// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
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
struct Season{
    uint  seasonStartTimestamp;
    uint  seasonEndTimestamp;
    bool  isSeasonFixed;
    uint  fixedBalance;
}

/*//////////////////////////////////////////////////////////////
                            EVENTS
//////////////////////////////////////////////////////////////*/

event Deposited(
    address indexed challenger,
    uint deposit,
    uint initialChallengeTime
);
event Challenged(address indexed challenger, uint challengeTime);
event Fixed(address indexed robber, address indexed target);
event Withdrawn(address indexed challenger, uint withdrawAmount);

contract GMonster is Ownable{
    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    string public constant ERR_DEPOSIT_AMOUNT = "GMonster: Invalid deposit amount";
    string public constant ERR_DEPOSIT_DUPLICATE = "GMonster: Already deposited";
    string public constant ERR_DEPOSIT_SEASON =
        "GMonster: Season already started";
    string public constant ERR_DEPOSIT_INITIALTIME = "GMonster: Initial time invalid";
    string public constant ERR_CHALLENGE_NOT_DEPOSITED = "GMonster: Not deposited";
    string public constant ERR_CHALLENGE_DEPULICATED = "GMonster: Challenge duplicated";
    string public constant ERR_CHALLENGE_FAILED =
        "GMonster: Challenge already failed";
    string public constant ERR_CHALLENGE_OUTOFSPAN = "GMonster: Out challenge span";
    string public constant ERR_CHALLENGE_OUTOFSEASON = "GMonster: Out of season";
    string public constant ERR_WITHDRAW1 = "GMonster: Not deposited";
    string public constant ERR_WITHDRAW2 =
        "GMonster: Challenge count not enough";
    string public constant ERR_WITHDRAW4 = "GMonster: Transfer failed";
    string public constant ERR_WITHDRAW5 = "GMonster: Season not fixed";
    string public constant ERR_FIXFAIL1 = "GMonster: Not participated";
    string public constant ERR_FIXFAIL2 = "GMonster: Not robable";
    string public constant ERR_FIXFAIL3 = "GMonster: Transfer failed";
    string public constant ERR_FIXFAIL_SEASON = "GMonster: Season not started";
    string public constant ERR_FIXFAIL_FIXED = "GMonster: Season already fixed";
    string public constant ERR_FIX1 = "GMonster: Season not ended";
    string public constant ERR_FIX2 = "GMonster: Already fixed";

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/
    uint public constant DEPOSIT = 0.002 ether;
    uint public constant FIX_FAIL_FEE = 0.0002 ether; //10%
    uint public constant CHALLENGE_COUNT = 21;
    uint public constant LOSTABLE_CHALLENGE_COUNT = 3;
    uint public constant CHALLENGE_TIME_SPAN = 3 hours;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    Season public season;
    mapping(address => Challenge) public challenges;
    mapping(uint8 => address) public challengerAddresses;
    uint8 public maxChallengerCount;
    uint8 public fixFailedCount;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(uint _seasonStartTimestamp) Ownable(msg.sender) {
        setSeason(_seasonStartTimestamp);
    }
    /*//////////////////////////////////////////////////////////////
                            OWNER UPDATE
    //////////////////////////////////////////////////////////////*/
    function setSeason(uint _seasonStartTimestamp) public onlyOwner{
        season.seasonStartTimestamp = _seasonStartTimestamp;
        season.seasonEndTimestamp = _seasonStartTimestamp + (CHALLENGE_COUNT * 1 days);
    }

    function fixSeason() public onlyOwner {
        require(block.timestamp > season.seasonEndTimestamp, ERR_FIX1);
        require(!season.isSeasonFixed, ERR_FIX2);
        season.isSeasonFixed = true;
        season.fixedBalance = address(this).balance;
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL UPDATE
    //////////////////////////////////////////////////////////////*/
    function deposit(uint _initialChallengeTime) public payable {
        //Validations
        require(block.timestamp < season.seasonStartTimestamp, ERR_DEPOSIT_SEASON);
        require(_initialChallengeTime >= season.seasonStartTimestamp, ERR_DEPOSIT_INITIALTIME);
        require(msg.value == DEPOSIT, ERR_DEPOSIT_AMOUNT);
        require(challenges[msg.sender].deposit == 0, ERR_DEPOSIT_DUPLICATE);

        challenges[msg.sender] = Challenge({
            deposit: msg.value,
            initialChallengeTime: _initialChallengeTime,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });

        //Increment challengerAddresses
        challengerAddresses[maxChallengerCount] = msg.sender;
        maxChallengerCount += 1;

        emit Deposited(msg.sender, msg.value, _initialChallengeTime);
    }

    function challenge() external {
        //Validations
        require(block.timestamp >= season.seasonStartTimestamp, ERR_CHALLENGE_OUTOFSEASON);
        require(block.timestamp <= season.seasonEndTimestamp, ERR_CHALLENGE_OUTOFSEASON);
        Challenge memory _challenge = challenges[msg.sender];
        require(_challenge.deposit >= DEPOSIT, ERR_CHALLENGE_NOT_DEPOSITED);
        //Today's challenge is already done
        require(
            block.timestamp >
                _challenge.lastChallengeTime + CHALLENGE_TIME_SPAN,
            ERR_CHALLENGE_DEPULICATED
        );
        (
            uint _lostChallengeCount,
            bool _isChallengeSpan
        ) = _getLostCountAndIsSpan(_challenge, block.timestamp);
        require(
            _lostChallengeCount <= LOSTABLE_CHALLENGE_COUNT,
            ERR_CHALLENGE_FAILED
        );
        require(_isChallengeSpan, ERR_CHALLENGE_OUTOFSPAN);

        //Judge continuous or not
        uint8 _continuousSuceededCount = _challenge.continuousSuceededCount;
        if (
            block.timestamp <
            _challenge.lastChallengeTime + 1 days + CHALLENGE_TIME_SPAN
        ) {
            _continuousSuceededCount += 1;
        }else{
            _continuousSuceededCount = 1;        
        }

        challenges[msg.sender] = Challenge({
            deposit: _challenge.deposit,
            initialChallengeTime: _challenge.initialChallengeTime,
            lastChallengeTime: block.timestamp,
            suceededChallengeCount: _challenge.suceededChallengeCount + 1,
            continuousSuceededCount: _continuousSuceededCount
        });
        emit Challenged(msg.sender, block.timestamp);
    }

    function withdraw() external {
        //Validations
        require(season.isSeasonFixed, ERR_WITHDRAW5);
        Challenge memory _challenge = challenges[msg.sender];
        require(_challenge.deposit >= DEPOSIT, ERR_WITHDRAW1);
        require(
            _challenge.suceededChallengeCount >=
                CHALLENGE_COUNT - LOSTABLE_CHALLENGE_COUNT,
            ERR_WITHDRAW2
        );

        challenges[msg.sender] = Challenge({
            deposit: 0,
            initialChallengeTime: 0,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });

        uint _withdrawAmount = season.fixedBalance / (maxChallengerCount - fixFailedCount);
        (bool success, ) = msg.sender.call{value: _withdrawAmount}("");
        require(success, ERR_WITHDRAW4);

        emit Withdrawn(msg.sender, _withdrawAmount);
    }

    function fixFail(address _target) external payable {
        require(block.timestamp >= season.seasonStartTimestamp, ERR_FIXFAIL_SEASON);
        require(!season.isSeasonFixed, ERR_FIXFAIL_FIXED);
        Challenge memory _robberChallenge = challenges[msg.sender];
        //Validations
        require(_robberChallenge.deposit >= DEPOSIT, ERR_FIXFAIL1);

        Challenge memory _targetChallenge = challenges[_target];
        require(_judgeFailOrNot(_targetChallenge, block.timestamp), ERR_FIXFAIL2);

        challenges[_target] = Challenge({
            deposit: 0,
            initialChallengeTime: 0,
            lastChallengeTime: 0,
            suceededChallengeCount: 0,
            continuousSuceededCount: 0
        });

        (bool success, ) = msg.sender.call{value: FIX_FAIL_FEE}("");
        require(success, ERR_FIXFAIL3);

        fixFailedCount++;
        emit Fixed(msg.sender, _target);
    }

    /*//////////////////////////////////////////////////////////////
                             EXTERNAL VIEW
    //////////////////////////////////////////////////////////////*/
    function judgeFailOrNot(address _challenger) external view returns (bool) {
        Challenge memory _challenge = challenges[_challenger];
        return _judgeFailOrNot(_challenge, block.timestamp);
    }

    function getLostCount(address _challenger) external view returns (uint) {
        Challenge memory _challenge = challenges[_challenger];
        (uint _lostChallengeCount, ) = _getLostCountAndIsSpan(
            _challenge,
            block.timestamp
        );
        return _lostChallengeCount;
    }

    function isChallengeSpan(address _challenger) external view returns (bool) {
        Challenge memory _challenge = challenges[_challenger];
        (, bool _isChallengeSpan) = _getLostCountAndIsSpan(
            _challenge,
            block.timestamp
        );
        return _isChallengeSpan;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL UPDATE
    //////////////////////////////////////////////////////////////*/
    /*//////////////////////////////////////////////////////////////
                             INTERNAL VIEW
    //////////////////////////////////////////////////////////////*/
    function _getLostCountAndIsSpan(
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
        if (_challenge.deposit < DEPOSIT) return false;

        (uint _lostChallengeCount, ) = _getLostCountAndIsSpan(
            _challenge,
            _timestamp
        );
        if (_lostChallengeCount > LOSTABLE_CHALLENGE_COUNT) return true;

        return false;
    }
}
