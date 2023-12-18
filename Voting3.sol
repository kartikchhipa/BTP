// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.22;

contract Voting{

    struct Voter{
        bool voted;
        uint[] votes;
        bool registered;
    }

    struct Candidate{
        bytes32 name;
        bytes32 position;
        bytes32 party;
        bool registered;  
        uint32 voteCount; 
    }

    struct Position{
        bytes32 name;
        uint32[] candidates;
        uint32 voteCount;
        bool registered;
    }

    Candidate[] private candidates;
    mapping (bytes32 => uint256) private candidateMap;
    Position[] private positions;
    mapping (bytes32 => uint256) private positionMap;
    
    address public admin;

    // map the kekka256 hash of the tuple (voter address, voter id) to the voter struct 
    mapping (bytes32 => Voter) public voters; 

    
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
        positions.push(Position("", new uint32[](0), 0, false));
        candidates.push(Candidate("", "", "", false, 0));
    }

    function changeState(Phase x) onlyAdmin public{
        require(uint(x) == (uint(state) + 1));
        state = x;
    }

    function voterRegistration(bytes32 _aadhaar) public onlyAdmin validPhase(Phase.RegPhase){
        // person should not be registered before
        bytes32 hash = keccak256(abi.encodePacked(_aadhaar));
        // convert hash to uint256
        require(!voters[hash].registered);
        voters[hash].registered = true;
        voters[hash].voted = false;
    }

    function addPosition(bytes32 _name) onlyAdmin validPhase(Phase.InitPhase) public{
        require(!positions[positionMap[_name]].registered, "Position already exists");
        positions.push(Position(_name, new uint32[](0), 0, true));
        positionMap[_name] = positions.length - 1;
    }

    function candidateRegistration(bytes32 _name, bytes32 _party, bytes32 _position,bytes32 _aadhaar) public onlyAdmin validPhase(Phase.RegPhase){
        // person should not be registered before and position should exist 
        bytes32 hash = keccak256(abi.encodePacked(_aadhaar));
        require(!candidates[candidateMap[hash]].registered, "Candidate already registered");
        require(positions[positionMap[_position]].registered, "Position does not exist");
        candidates.push(Candidate(_name, _position, _party, true, 0));
        candidateMap[hash] = candidates.length - 1;
        positions[positionMap[_position]].candidates.push(uint32(candidates.length - 1));
    }

    function vote(bytes32 _aadhaar, uint32[] memory _votes) validPhase(Phase.VotePhase) public{
        // person should be registered and not voted before
        bytes32 hash = keccak256(abi.encodePacked(_aadhaar));
        require(voters[hash].registered, "Voter not registered");
        require(!voters[hash].voted, "Voter already voted");
        voters[hash].voted = true;
        voters[hash].votes = _votes;
        for(uint i = 0; i < _votes.length; i++){
            candidates[_votes[i]].voteCount++;
            positions[positionMap[candidates[_votes[i]].position]].voteCount++;
        }
    }

}

