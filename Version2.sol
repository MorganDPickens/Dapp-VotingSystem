// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Candidate {
        uint8 id;
        bytes32 name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public hasVoted;

    uint public candidatesCount = 0;
    uint public startTime;
    uint public endTime;

    event VotedEvent(uint indexed _candidateId);

    constructor(uint _durationInMinutes) {
        startTime = block.timestamp;
        endTime = startTime + _durationInMinutes * 1 minutes;

        addCandidate("Candidate 1");
        addCandidate("Candidate 2");
    }

    function addCandidate(bytes32 _name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate({
            id: uint8(candidatesCount),
            name: keccak256(abi.encodePacked(_name)),
            voteCount: 0
        });
    }

    function vote(uint _candidateId) public {
        require(!hasVoted[msg.sender], "You have already voted");
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "Voting is not allowed at this time"
        );
        require(
            _candidateId > 0 && _candidateId <= candidatesCount,
            "Invalid candidate id"
        );

        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        emit VotedEvent(_candidateId);
    }

    function getAllCandidates() public view returns (Candidate[] memory) {
        Candidate[] memory allCandidates = new Candidate[](candidatesCount);
        for (uint i = 1; i <= candidatesCount; i++) {
            allCandidates[i - 1] = candidates[i];
        }
        return allCandidates;
    }

    function getwinner() public view returns (bytes32) {
        require(block.timestamp > endTime, "Voting is still in progress");

        uint maxVote = 0;
        uint leaderCandidateId = 0;

        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > maxVote) {
                maxVote = candidates[i].voteCount;
                leaderCandidateId = i;
            }
        }

        if (leaderCandidateId == 0) {
            return "No votes casted yet";
        } else {
            return candidates[leaderCandidateId].name;
        }
    }
}
