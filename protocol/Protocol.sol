pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2;
//import "https://github.com/pipermerriam/ethereum-datetime/contracts";
import "https://github.com/pipermerriam/ethereum-datetime/contracts/DateTime.sol";
//import "https://github.com/pipermerriam/ethereum-datetime/contracts/api.sol";
//import "https://github.com/pipermerriam/ethereum-datetime/tree/master/contracts/DateTime.sol";

contract Protocol is DateTime{
    struct items{
        address Investor;
        address Manager;
        uint8 paymentToken;//0 represent BTC,1 represent RSK
        uint8 deliverToken;
        uint256 paymentRequired;//total paymentToken required
        uint256 deliverRequired;//total deliverToken required
        bool paymentAlready;//if payment is done
        bool deliverAlready;//if deliver is done
        uint64 paymentLimit;//deadline of payment
        uint64 deliverLimit;//deadline of deliver
    }
    struct PBalance{
        uint256 BTCBalance;
        uint256 RSKBalance;
    }
    PBalance balance;
    mapping (address => items) public InvestorInfo;
    mapping (address => items) public ManagerInfo;

    bool mark1;
    bool mark2;
    bool mark3;
    bool mark4;
    

    
    constructor() public {
        balance = PBalance(0,0);
    }
    function receive(uint256 amount,uint8 kind) public payable returns (bool){
        if(kind == 0){
            if(msg.sender.call(bytes4(keccak256("addBTCBalance(uint256 amount)")),-amount) == false){
                require(false);   
            }
            balance.BTCBalance += amount;
            return true;
        }
        if(kind == 1){
            if(msg.sender.call(bytes4(keccak256("addRSKBalance(uint256 amount)")),-amount) == false){
                require(false);
            }
            balance.RSKBalance += amount;
            return true;
        }
        return false;
        
    }
    function give(uint256 amount,uint8 kind) public payable returns (bool){
        if(kind == 0){
            if(balance.BTCBalance < amount) return false;
            balance.BTCBalance += -amount;
            if(msg.sender.call(bytes4(keccak256("addBTCBalance(uint256 amount)")),amount) == false){
                require(false);
            }
            return true;
        }
        if(kind == 1){
            if(balance.RSKBalance < amount) return false;
            balance.RSKBalance += -amount;
            if(msg.sender.call(bytes4(keccak256("addRSKBalance(uint256 amount)")),amount) == false){
                require(false);
            }
            return true;
        }
        return false;
    }
    function createProtocol(items temp) public{
        InvestorInfo[temp.Investor] = temp;
        ManagerInfo[temp.Manager] = temp;
        /*InvestorItem = InvestorInfo[temp.Investor];
        ManagerItem = InvestorInfo[temp.Investor];*/
    }
    function createtime(uint16 year,uint8 month,uint8 day,uint8 hour,uint8 minute,uint8 second) public pure returns (uint64){
        return uint64(toTimestamp(year,month,day,hour,minute,second));
    }
    
    /*function st (address inv) public{
        InvestorInfo[inv].paymentAlready = true;
    }
    
    function at (address inv,address man) public view returns (bool a,bool b,bool c,bool d){
        a =  InvestorInfo[inv].paymentAlready;
        b = ManagerInfo[man].paymentAlready;
        c = InvestorItem.paymentAlready;
        d = ManagerItem.paymentAlready;
        
    }*/
    
    function payment() public payable returns (bool){//caller:Investor
        if(InvestorInfo[msg.sender].paymentAlready == true) return false;//只允许转账一次
        if(now < InvestorInfo[msg.sender].paymentLimit){
            uint256 preBTC = balance.BTCBalance;
            uint256 preRSK = balance.RSKBalance;
            if(msg.sender.call(bytes4(keccak256("pay(uint256 amount,uint8 kind)")),InvestorInfo[msg.sender].paymentRequired,InvestorInfo[msg.sender].paymentToken) == false){
                require(false);
            }
            if(preBTC == balance.BTCBalance && preRSK == balance.RSKBalance){
                return false;//转账失败
            }
            InvestorInfo[msg.sender].paymentAlready = true;
            address temp = InvestorInfo[msg.sender].Manager;
            ManagerInfo[temp].paymentAlready = true;
            return true;
        }
        return false;
    }
    function acceptPayment() public payable returns (bool){//caller:Manager
        if(now >= ManagerInfo[msg.sender].paymentLimit){
            if(ManagerInfo[msg.sender].paymentAlready == true){
                if(msg.sender.call(bytes4(keccak256("get(uint256 amount,uint8 kind)")),ManagerInfo[msg.sender].paymentRequired,ManagerInfo[msg.sender].paymentToken) == false){
                    require(false);
                }
                return true;
            }
            else{
                if(ManagerInfo[msg.sender].Investor.call(bytes4(keccak256("punish"))) == false){
                    require(false);
                }
                return false;
            }
        }
        else return false;
    }
    function deliver() public payable returns (bool){//caller:Manager
        if(ManagerInfo[msg.sender].deliverAlready == true) return false;
        if(now < ManagerInfo[msg.sender].deliverLimit){
            uint256 preBTC = balance.BTCBalance;
            uint256 preRSK = balance.RSKBalance;
            if(msg.sender.call(bytes4(keccak256("pay(uint256 amount,uint8 kind)")),ManagerInfo[msg.sender].deliverRequired,ManagerInfo[msg.sender].deliverToken) == false){
                require(false);
            }
            if(preBTC == balance.BTCBalance && preRSK == balance.RSKBalance){
                return false;
            }
            ManagerInfo[msg.sender].deliverAlready = true;
            address temp = ManagerInfo[msg.sender].Investor;
            InvestorInfo[temp].deliverAlready = true;
            return true;
        }
        return false;
    }
    function acceptDeliver() public payable returns (bool){//caller:Investor
        if(now >= InvestorInfo[msg.sender].deliverLimit){
            if(InvestorInfo[msg.sender].deliverAlready == true){
                if(msg.sender.call(bytes4(keccak256("get(uint256 amount,uint8 kind)")),InvestorInfo[msg.sender].deliverRequired,InvestorInfo[msg.sender].deliverToken) == false){
                    require(false);
                }
                return true;
            }
            else{
                if(InvestorInfo[msg.sender].Manager.call(bytes4(keccak256("punish"))) == false){
                    require(false);
                }
                return false;
            }
        }
        else return false;
    }
    
}