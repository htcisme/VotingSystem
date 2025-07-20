// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    struct Candidate {
        string name;
        uint256 votes;
    }

    Candidate[] public candidates;

    mapping(address => bool) public isRegisteredVoter;
    mapping(address => bool) public hasVoted;

    event Voted(address voter, uint candidateId);

    constructor() Ownable(msg.sender) {}

    function registerCandidate(string memory _name) public onlyOwner {
        for (uint i = 0; i < candidates.length; i++) {
            require(
                keccak256(abi.encodePacked(candidates[i].name)) != keccak256(abi.encodePacked(_name)),
                "Candidate already registered"
            );
        }
        candidates.push(Candidate(_name, 0));
    }

    function registerVoter() public {
        require(!isRegisteredVoter[msg.sender], "Already registered");
        isRegisteredVoter[msg.sender] = true;
    }

    function vote(string memory _name) public {
        require(isRegisteredVoter[msg.sender], "Not registered voter");
        require(!hasVoted[msg.sender], "Already voted");

        for (uint i = 0; i < candidates.length; i++) {
            if (keccak256(abi.encodePacked(candidates[i].name)) == keccak256(abi.encodePacked(_name))) {
                candidates[i].votes++;
                hasVoted[msg.sender] = true;
                emit Voted(msg.sender, i);
                return;
            }
        }

        revert("Candidate not found");
    }

    function getVotes(string memory _name) public view returns (uint256) {
        for (uint i = 0; i < candidates.length; i++) {
            if (keccak256(abi.encodePacked(candidates[i].name)) == keccak256(abi.encodePacked(_name))) {
                return candidates[i].votes;
            }
        }
        revert("Candidate not found");
    }

    function getWinner() public view returns (string memory) {
        string memory winnerName;
        uint256 maxVotes = 0;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].votes > maxVotes) {
                maxVotes = candidates[i].votes;
                winnerName = candidates[i].name;
            }
        }

        require(maxVotes > 0, "No votes cast yet");
        return winnerName;
    }
}

