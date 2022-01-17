// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <0.9.0;

import "@chainlink/contracts/src/v0.7/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.7/vendor/SafeMathChainlink.sol";


contract Event {

    using SafeMathChainlink for uint256;

    event NewEvent(string name, uint price, uint _peoplecount);
    event NewSpectator(string tag);

    address public owner;
    address public chairperson;
    uint public amount_price;
    uint public remaining = 1 days;

    AggregatorV3Interface public priceFeed; 


    struct ProposalEvent {
        string title;
        uint price;
        uint peoplecount;
        uint collect; 
        uint remain;
    }

    struct Spectator {
        string tag;
        uint32 countevent;
        bool created;
    }


    ProposalEvent[] public proposal;


    mapping (address => Spectator) spectator;
    mapping (uint => address) ownerEvent;
    mapping (address => uint) pendingReturns;

    
    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }


    function addEvent(string memory _title, uint _price, uint _peoplecount) 
        public 
    {
        proposal.push(ProposalEvent({
            title: _title,
            price: _price, 
            peoplecount: _peoplecount,
            collect: 0,
            remain: remaining
            })
        );
        uint256 eventId = proposal.length - 1;
        ownerEvent[eventId] = msg.sender;
        emit NewEvent(_title, _price, _peoplecount);
    }


    function verifySpectatorAccount(address _spectator) internal view {
        require(
            !spectator[_spectator].created,
            "Address account already exist"
        );
    }

    function addSpectator(string memory _tag) public {
        chairperson = msg.sender;
        verifySpectatorAccount(chairperson);
        spectator[chairperson].tag = _tag;
        spectator[chairperson].countevent++;
        spectator[chairperson].created = true;
        emit NewSpectator(_tag);
    }


    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    // 1000000000
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // mimimumUSD
        uint256 mimimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (mimimumUSD * precision) / price;
    }



    function withdraw() external {
        amount_price = pendingReturns[msg.sender];
    }
}
