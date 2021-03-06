pragma solidity ^0.4.17;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ProjectList {

    using SafeMath for uint;

    address[] public projects;

    function createProject(string _description, uint _minInvest, uint _maxInvest, uint _goal) public {
        address newProject = new Project(_description, _minInvest, _maxInvest, _goal, msg.sender);
        projects.push(newProject);
    }

    function getProjects() public view returns(address[]) {
        return projects;
    }
    
}


contract Project {

    using SafeMath for uint;

    struct Payment {
        string description;
        uint amount;
        address receiver;
        bool completed;
        // address[] voters;
        mapping(address => bool) voters;
        uint voterCount;
    }

    address public owner;
    string public description;
    uint public minInvest;
    uint public maxInvest;
    uint public goal;
    // address[] public investors;
    uint public investorCount;
    mapping(address => uint) public investors;
    Payment[] public payments;

    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }


    constructor(string _description, uint _minInvest, uint _maxInvest, uint _goal, address _owner) public {
        // owner = msg.sender;
        description = _description;
        minInvest = _minInvest;
        maxInvest = _maxInvest;
        goal = _goal;
        owner = _owner;
    }


    function contribute() public payable {
        require(msg.value >= minInvest);
        require(msg.value <= maxInvest);

        uint newBalance = 0;
        newBalance = address(this).balance.add(msg.value);
        require(newBalance <= goal);

        // investors.push(msg.sender);
        investors[msg.sender] = msg.value;
        investorCount += 1;
    }

    function createPayment(string _description, uint _amount, address _receiver) ownerOnly public {
        require(address(this).balance >= _amount);
    
        Payment memory newPayment = Payment({
            description: _description,
            amount: _amount,
            receiver: _receiver,
            completed: false,
            // voters: new address[](0)
            voterCount: 0
        });

        payments.push(newPayment);
    }

    function approvePayment(uint index) public {
        Payment storage payment = payments[index];

        // must be investor to vote
        // bool isInvestor = false;
        // for (uint i = 0; i < investors.length; i++) {
        //     isInvestor = investors[i] == msg.sender;
        //     if (isInvestor) {
        //         break;
        //     }
        // }
        // require(isInvestor);
        require(investors[msg.sender] > 0);

        // can not vote twice
        // bool hasVoted = false;
        // for (uint j = 0; j < payment.voters.length; j++) {
        //     hasVoted = payment.voters[j] == msg.sender;
        //     if (hasVoted) {
        //         break;
        //     }
        // }
        // require(!hasVoted);

        // payment.voters.push(msg.sender);
        require(!payment.voters[msg.sender]);

        payment.voters[msg.sender] = true;
        payment.voterCount += 1;
    }

    function doPayment(uint index) ownerOnly public {

        Payment storage payment = payments[index];

        require(!payment.completed);
        require(address(this).balance >= payment.amount);
        // require(payment.voters.length > (investors.length / 2));
        require(payment.voterCount > (investorCount / 2));

        payment.receiver.transfer(payment.amount);
        payment.completed = true;
    }
}