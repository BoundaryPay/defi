// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/access/Ownable.sol";

contract BoundaryPayStake is Ownable {
    uint public rewardRate;
	uint public endStake;
	uint public lockDownTime;
	uint private _totalDeposit;
	uint private _totalReturn;
    mapping(address => uint) private _balances;
	address private _admin;

    modifier onlyAdmin {
        require(msg.sender == _admin);
        _;
    }
	
    constructor(uint _rewardRate,uint _endStake,uint _lockDownTime, address _adminitrator) {
		rewardRate = _rewardRate;
		endStake = _endStake;
		lockDownTime = _lockDownTime;
		_admin = _adminitrator;
	}

	function takeInvest() public payable onlyAdmin {
		require(payable(msg.sender).send(address(this).balance));
	}

	function putInvest() public payable onlyAdmin {
		require(msg.value >= _totalDeposit*rewardRate/1e18 + _totalDeposit, "Value below expected");
		_totalReturn = msg.value;
	}


	function stake() public payable {
		require (block.timestamp < endStake, "Staking has been ended");
		_totalDeposit += msg.value;
		_balances[msg.sender] += msg.value;
	}

	function unstakeAndHarvest() public payable {
		require (block.timestamp > endStake+lockDownTime, "Unstaking not started");
		require(payable(msg.sender).send(_balances[msg.sender]+_balances[msg.sender]*rewardRate/1e18));
	}


	function takeProfit() public payable onlyOwner {
		require(_totalDeposit*rewardRate/1e18 + _totalDeposit < _totalReturn, "not enough profit");
		uint profit = _totalReturn - _totalDeposit*rewardRate/1e18 - _totalDeposit;
		require(payable(msg.sender).send(profit));
	}
	
	function totalSupply() public view onlyOwner returns (uint) {
		return _totalDeposit;
	}
	
	function totalReturn() public view onlyOwner returns (uint) {
		return _totalReturn;
	}
}
