// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
contract stocking  {
    mapping(address => uint256) public investAmount;
    address public owner;
    bool public investAvailable;
    bool public rewardAvailable;
    uint256 public totalAmount;
    uint public minRate;
    uint public rate;
    IERC20 public usdt;
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
    constructor(address usdtAddress) {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        minRate = 1e17;
        rate = 2e17;
        investAvailable = true;
        rewardAvailable = false;
        usdt = IERC20(usdtAddress);
    }
    
    function invest(uint _amount) isInvestAvailable public  {
        require(_amount>0, "Some user not take reward");
        transferIn(msg.sender,_amount);
        investAmount[msg.sender] = investAmount[msg.sender]+_amount;
        totalAmount +=_amount;
        
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
    function takeOutInvest() isRewardAvailable public {
        require(investAmount[msg.sender]>0, "you don't have any reward");
        transferOut(msg.sender,investAmount[msg.sender]+investAmount[msg.sender]*rate/1e18);
        totalAmount-=investAmount[msg.sender];
        investAmount[msg.sender] = 0;
    }
    function putInvest(address target) onlyOwner public{
        require(totalAmount>0,"no inverst yet");
        transferOut(target,totalAmount);
        investAvailable = false;
    }
    function withdraw() onlyOwner public{
        require(usdt.balanceOf(address(this))>totalAmount+totalAmount*rate/1e18,"not enought balance");
        transferOut(msg.sender,usdt.balanceOf(address(this))-totalAmount-totalAmount*rate/1e18);
        
    }
    function startReward(uint _amount) public {
        require(_calculateMinReward(totalAmount) < _amount, "value is not enough");
        require(!investAvailable,"invest not end yet");
        transferIn(msg.sender,_amount);
        if(_amount<_calculateReward(totalAmount)){
            rate = ((_amount-totalAmount)*1e18/totalAmount);
        }
        rewardAvailable = true;
    }
    function _calculateReward(uint256 amount) private view returns(uint256){
        return amount+amount*rate/1e18;
    }
    function _calculateMinReward(uint256 amount) private view returns(uint256){
        return amount+amount*minRate/1e18;
    }
    function  transferOut(address toAddr, uint amount)  private{
        usdt.transfer( toAddr, amount);
    }
    function  transferIn(address fromAddr, uint amount)  private {
        usdt.transferFrom(fromAddr,address(this), amount);
    }
}









