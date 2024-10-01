// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract VoteSystem{
    // Define usage of dependency
    using Strings for string;

    // Errors used during execution
    error NotOwnerError();
    error TimestampNotInRange(uint256 blockTimestamp, uint256 _timestamp);
    error AddressNotFound(address _address);
    error AddressAlreadyVoted(address _address);

    // Owner address
    address payable public owner;
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
    address[] private whitelist;
    // Addresses that have voted
    mapping (address => bool) voteChecklist;


    // Contract constructor
    constructor(string[] memory _proposalNames, address[] memory _whitelist) {
        owner = payable(msg.sender);
        whitelist = _whitelist;
        for (uint256 i = 0; i < _proposalNames.length; i++) {
            proposals.push(Proposal({
                name: _proposalNames[i],
                votesCount: 0
            }));
        }
        STARTTIME = block.timestamp;
    }

    // Modifier that checks if sender is the owner
    modifier onlyOwner(){
        if (msg.sender != owner){
            revert NotOwnerError();
        } 
        _;
    }

    // Modifier that checks if sender is whitelisted
    modifier onlyWhitelisted(){
        if (-1 == getAddressIndexOnWhitelist(msg.sender)){
            revert AddressNotFound(msg.sender);
        }
        _;
    }

    // Modifier that checks if sender has voted
    modifier hasntVoted(){
        if (voteChecklist[msg.sender] == true){
            revert AddressAlreadyVoted(msg.sender);
        }
        _;
    }

    // Modifier that checks if time at transaction is valid
    modifier isValidTime(){
        if (block.timestamp > STARTTIME + MAXTIME || block.timestamp < STARTTIME){
            revert TimestampNotInRange(block.timestamp,STARTTIME);
        }
        _;
    }

    // Function to vote for a "Proposal"
    function vote(uint256 _index) external onlyWhitelisted hasntVoted isValidTime{
        Proposal storage choice = proposals[_index];
        choice.votesCount += 1;
        voteChecklist[msg.sender] = true;
    }

    // Function to get the index in array "whitelist" of an address, returns -1 if not found
    function getAddressIndexOnWhitelist(address _address) public view returns (int256 _index){
        _index = -1;
        for (uint256 i = 0; i < whitelist.length; i++) {
            if(whitelist[i] == _address){
                _index = int(i);
                break;
            }
        }
        return _index;
    }

    // Function to get the index of a "Proposal" in "proposals" using "name", returns -1 if not found
    function getProposalIndex(string memory _name) public view returns (int256 _index){
        _index = -1;
        for (uint256 i = 0; i < proposals.length; i++) {
            string memory find = proposals[i].name;
            if(find.equal(_name)){
                _index = int(i);
                break;
            }
        }
        return _index;
    }

    // Function to change owner of contract
    function changeOwner(address _address) external onlyOwner{
        owner = payable(_address);
    }

    // Function to add a new address to "whitelist"
    function addWhitelisted(address _address) external onlyOwner isValidTime{
        whitelist.push(_address);
    }

    // Function to add a new "Proposal" to "proposals"
    function addProposal(string memory _name) external onlyOwner isValidTime{
        proposals.push(Proposal(_name,0));
    }

    // Function to get current time
    function checkTime() public view returns (uint){
        return block.timestamp;
    }

    // Used to withdraw Ether stored in contract to Owner
    function withdraw() public {
        // Get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // Send all Ether to owner
        (bool success,) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }
}