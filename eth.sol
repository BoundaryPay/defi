// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract stocking  {
    mapping(address => uint256) public investAmount;
    address public owner;
    bool public investAvailable;
    bool public rewardAvailable;
    uint256 public totalAmount;
    uint public minRate;
    uint public rate;
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    modifier isInvestAvailable() {
        require(investAvailable, "Invest ended");
        _;
    }
    modifier isRewardAvailable() {
        require(rewardAvailable, "Can't take invest yet");
        _;
    }
    
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        minRate = 1e17;
        rate = 2e17;
        investAvailable = true;
        rewardAvailable = false;
    }
    function invest() isInvestAvailable public payable {
        require(msg.value>0, "Some user not take reward");
        investAmount[msg.sender] = investAmount[msg.sender]+msg.value;
        totalAmount +=msg.value;
    }
    function endInvest()onlyOwner isInvestAvailable public{
        investAvailable = false;
    }
    function resetInvestCycle(uint min,uint max)onlyOwner public{
        require(totalAmount<=0, "Some user not take reward");
        require(min<max,"wrong rate");
        investAvailable = true;
        rewardAvailable = false;
        minRate = min;
        rate = max;
    }
    function takeOutInvest() isRewardAvailable public payable{
        require(investAmount[msg.sender]>0, "you don't have any reward");
        payable(msg.sender).transfer(investAmount[msg.sender]+investAmount[msg.sender]*rate/1e18);
        totalAmount-=investAmount[msg.sender];
        investAmount[msg.sender] = 0;
            
        
    }
    
    function putInvest(address target) onlyOwner public{
        require(totalAmount>0,"no inverst yet");
        payable(target).transfer(totalAmount);
        investAvailable = false;
    }
    function withdraw() onlyOwner public{
        require(address(this).balance>totalAmount+totalAmount*rate/1e18,"not enought balance");
        payable(msg.sender).transfer(address(this).balance-totalAmount-totalAmount*rate/1e18);
    }
    function startReward() public payable{
        require(_calculateMinReward(totalAmount) < msg.value, "value is not enough");
        require(!investAvailable,"invest not end yet");
        if(msg.value<_calculateReward(totalAmount)){
            rate = ((msg.value-totalAmount)*1e18/totalAmount);
        }
        
        rewardAvailable = true;
    }
    
    function _calculateReward(uint256 amount) private view returns(uint256){
        return amount+amount*rate/1e18;
    }
    function _calculateMinReward(uint256 amount) private view returns(uint256){
        return amount+amount*minRate/1e18;
    }
}