// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.22;

contract Voting{

    struct Voter{
        bool voted;
        bytes32[] votes;
        bool registered;
    }

    struct Candidate{
        bytes32 name;
        uint32 voteCount;
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

    mapping(bytes32 => Voter) public voters;

    mapping(bytes32 => Candidate) public candidates;

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
        require(!voters[hash].registered);
        voters[hash].registered = true;
        voters[hash].voted = false;
    }

    function candidateRegistration(bytes32 _name, bytes32 _aadhaar, bytes32 _party, bytes32 _position) public onlyAdmin validPhase(Phase.RegPhase){
        bytes32 hash = keccak256(abi.encodePacked(_aadhaar));
        require(!candidates[hash].registered);
        candidates[hash].registered = true;
        candidates[hash].name = _name;
        candidates[hash].party = _party;
        candidates[hash].position = _position;
        candidates[hash].voteCount = 0;
    }



    function addPosition(bytes32 _name) public onlyAdmin validPhase(Phase.InitPhase){
        positions.push(Position(_name, new bytes32[](0), 0));
    }

    function addCandidate(bytes32 _hash) public onlyAdmin validPhase(Phase.InitPhase){
        require(candidates[_hash].registered);
        candidates[_hash].registered = false;
        for(uint i = 0; i < positions.length; i++){
            if(positions[i].name == candidates[_hash].position){
                positions[i].candidates.push(_hash);
                positions[i].numCandidates++;
                break;
            }
        }
    }
    
}

