// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Lottery {

    struct Person {
        uint personId;
        address addr;
        uint remainingTokens;
    }

    struct Item {
        uint itemId;
        uint[] itemTokens;
    }

    mapping(address => Person) tokenDetails; // διεύθυνση παίκτη
    Person [] public bidders;
    Item [] public items; 
    address[] public winners; // πίνακας νικητών 
    address public beneficiary; // ιδιοκτήτης του smart contract
    uint bidderCount = 0; // πλήθος των εγγεγραμένων παικτών

    constructor(uint itemsNumber) payable{
        beneficiary = msg.sender;
        uint[] memory emptyArray;
        for (uint m = 0; m < itemsNumber; m++){
            items.push(Item({itemId:m, itemTokens:emptyArray}));
            winners.push(address(0)); 
        }
    }

    modifier hasMoney {
        require(msg.value <= 0.005 ether);
        _;
    }

    function isRegistered() internal view returns (bool){

    }

    function register() public payable hasMoney{ // εγγραφή παίκτη
        require(msg.sender != beneficiary);
        bidders.push(Person({personId:bidderCount, addr:msg.sender, remainingTokens:5}));
        require(!isRegistered());
        tokenDetails[msg.sender] = bidders[bidderCount];
        bidderCount++;
    }

    modifier isValid(uint _itemId) {
        bool flag = false;
        for (uint id = 0; id < items.length; id++) { 
            if(items[id].itemId == _itemId){
                flag = true;
            }
        }
        require(flag == true);
        _;
    }

    function bid (uint _itemId, uint _count) public payable isValid(_itemId){ // Ποντάρει _count λαχεία στο αντικείμενο _itemId
        require(tokenDetails[msg.sender].remainingTokens >= _count);

        for (uint y = 0; y < _count; y++) {
            items[_itemId].itemTokens.push(tokenDetails[msg.sender].personId);
            tokenDetails[msg.sender].remainingTokens--;
        }
    }

    modifier onlyOwner {
        require(msg.sender == beneficiary);
        _;
    }

    function generateRandomNumber(uint256 min, uint256 max) internal view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, msg.sender))) % (max - min + 1) + min;
        return random;
    }

    function revealWinners() public payable onlyOwner {
        uint temp = 0;
        uint lgth = items.length;
        for (uint id = 0; id<lgth; id++) {
            if(items[id].itemTokens.length > 0 && winners[id] == address(0)){
                temp = generateRandomNumber(0, items[id].itemTokens.length-1);
                winners[id] = (findAddress(items[id].itemTokens[temp]));
            }
        }
    }

    function findAddress(uint id) internal view returns(address){
        for(uint k =0; k<bidders.length; k++){
            if(bidders[k].personId == id){
                return bidders[k].addr;
            }
        }
        return address(0);
    }
}
