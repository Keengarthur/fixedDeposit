//  SPDX-License-Identifier: GPL-3.0;

pragma solidity ^0.8.4;

contract FixedDeposit{

    // maps all the user of this savings platform
    mapping(address => Depositor) public depositor;

    // the address of the bank implementing this contract
    address payable bank;

    // keeps track of the savings fee
    uint256 fee;
    
    
    // the depositor information
    struct Depositor{
        uint256 deposit;
        uint lockedTime;
        bool paidFee;
    }

    // sets the bank as the deployer of this contract
    constructor(){
    bank = payable(msg.sender);
    }

    // ensures only the bank can run certain functions
    modifier onlyBank(){
    require(msg.sender == bank);
    _;
    }

    // the function that helps pay the savings fee
    function payFee() external payable{
        require(msg.value >= 1 wei,'saving costs 1 wei');
         fee += msg.value;
        depositor[msg.sender].paidFee = true;
    }

    // function to save 
    function save(uint months) external payable{
        require(depositor[msg.sender].paidFee,'you need to pay the savings fee of 1 wei');
        uint time = months * 2628002;
        depositor[msg.sender] = Depositor({
            deposit:msg.value,
            lockedTime: block.timestamp + time,
            paidFee:true

        });
    }


    // function to withdraw deposited fundes after the savings time
    function withdraw(address depositorAccount) external {
        require(block.timestamp >= depositor[msg.sender].lockedTime);
        uint amount = depositor[msg.sender].deposit;
        payable(depositorAccount).transfer(amount);
        
    }

    // withdraws the fees paid to use the contract
    function collectFee() external onlyBank{
    bank.transfer(fee);
    }
}