pragma solidity ^0.4.22;

contract Manager{
    struct MBalance{
        uint256 BTCBalance;
        uint256 RSKBalance;
    }
    MBalance public balance;
    address public protocal;
    
    constructor(address _protocal) public{
        balance = MBalance(0,0);
        protocal = _protocal;
    }
    
    function addBTCBalance (uint256 amount) public {
        balance.BTCBalance += amount;
    }
    
    function addRSKBalance (uint256 amount) public {
        balance.RSKBalance += amount;
    }
    //一种很拙劣的模拟
    
    function punish () public{
        //do punishment
        balance.BTCBalance = 0;
        balance.RSKBalance = 0;
    }
    
    function() public{
        //callback
    }
    
    function pay(uint256 amount,uint8 kind) public {
        if(protocal.call(bytes4(keccak256("receive(uint256 amount,uint8 kind)")),amount,kind) == false){
            require(false);
        }
    }
    
    function get(uint256 amount,uint8 kind) public{
        if(protocal.call(bytes4(keccak256("give(uint256 amount,uint8 kind)")),amount,kind) == false){
            require(false);
        }
    }
    
    function deliver() public{
        if(protocal.call(bytes4(keccak256("deliver()"))) == false){
            require(false);
        }
    }
    
    function acceptPayment() public{
        if(protocal.call(bytes4(keccak256("acceptPayment()"))) == false){
            require(false);
        }
    }
}