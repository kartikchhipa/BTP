// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.23;

contract Voting{

    struct Voter{
        bool voted;
        bytes32[] votes;
        bool registered;
    }

    struct Candidates{
        bytes32 name;
        uint8 voteCount;
        bytes32 party;
        bool registered;
        bytes32 position;
    }

    struct Position{
        bytes32 name;
        bytes32[] candidates;
        uint8 numCandidates;
    }

    address public admin;

    // map the kekka256 hash of the tuple (voter address, voter id) to the voter struct 
    Voter[] public voters;

    // map the kekka256 hash of the tuple (candidate name, candidate party) to the candidate struct
    Candidates[] public candidates;

    Position[] public positions;

    enum Phase{
        InitPhase,
        RegPhase,
        VotePhase,
        DonePhase
    }

    Phase public state;

    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }

    modifier validPhase(Phase x){
        require(state == x);
        _;
    }

    constructor(){
        admin = msg.sender;
        state = Phase.InitPhase;
    }

    function changeState(Phase x) onlyAdmin public{
        require(uint(x) == (uint(state) + 1));
        state = x;
    }

    function voterRegistration(bytes32 _aadhaar) public onlyAdmin validPhase(Phase.RegPhase){
        // person should not be registered before
        bytes32 hash = keccak256(abi.encodePacked(_aadhaar));
        // convert hash to uint256
        uint256 hashInt = uint256(hash);
        require(!voters[hashInt].registered);
        voters[hashInt].registered = true;
        voters[hashInt].voted = false;
    }

    function candidateRegistration(bytes32 _name, bytes32 _aadhaar, bytes32 _party, bytes32 _position) public onlyAdmin validPhase(Phase.RegPhase){
        bytes32 hash = keccak256(abi.encodePacked(_aadhaar));
        // convert hash to uint256
        uint256 hashInt = uint256(hash);
        require(!candidates[hashInt].registered);
        candidates[hashInt].registered = true;
        candidates[hashInt].name = _name;
        candidates[hashInt].party = _party;
        candidates[hashInt].position = _position;
        candidates[hashInt].voteCount = 0;
    }

    function addPosition(bytes32 _name) public onlyAdmin validPhase(Phase.InitPhase){
        positions.push(Position(_name, new bytes32[](0), 0));
    }
}

