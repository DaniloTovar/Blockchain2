// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract VoteSystem{
    // Define usage of dependency
    using Strings for string;

    // Owner address
    address public owner;
    // Time limit until closure of votes
    uint256 public constant MAXTIME = 3 days;
    // Starting time, when contract is deployed
    uint256 public immutable STARTTIME;

    // Structure of a proposal
    struct Proposal{
        string name;
        int40 votesCount; 
    }

    // List of "Proposal"
    Proposal[] public proposals;

    // List of addresses that can vote
    mapping (address => bool) public whitelist;
    // Addresses that have voted
    mapping (address => bool) public voteChecklist;


    // Contract constructor
    constructor() {
        owner = msg.sender;
        STARTTIME = block.timestamp;
    }

    // Modifier that checks if sender is the owner
    modifier onlyOwner(){
        require(msg.sender == owner, "Sender is not Owner");
        _;
    }

    // Modifier that checks if sender is whitelisted
    modifier onlyWhitelisted(){
        require(false != whitelist[msg.sender], "Sender not whitelisted");
        _;
    }

    // Modifier that checks if sender has voted
    modifier hasntVoted(){
        require(voteChecklist[msg.sender] != true, "Sender has already voted");
        _;
    }

    // Modifier that checks if time at transaction is valid
    modifier isValidTime(){
        require(block.timestamp < STARTTIME + MAXTIME, "3 days of voting already passed");
        _;
    }

    // Function to vote for a "Proposal"
    function vote(uint256 _index) external onlyWhitelisted hasntVoted isValidTime{
        Proposal storage choice = proposals[_index];
        choice.votesCount += 1;
        voteChecklist[msg.sender] = true;
    }

    // Function to change owner of contract
    function changeOwner(address _address) external onlyOwner{
        owner = _address;
    }

    // Function to add a new address to "whitelist"
    function addWhitelisted(address _address) external onlyOwner isValidTime{
        whitelist[_address] = true;
    }

    // Function to add a new "Proposal" to "proposals"
    function addProposal(string memory _name) external onlyOwner isValidTime{
        proposals.push(Proposal(_name,0));
    }
}