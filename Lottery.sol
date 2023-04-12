pragma solidity ^0.8.18;
// SPDX-License-Identifier: MIT

contract Lottery {

    // η δομή των παικτών
    struct Person {
        uint personId;
        address addr;
        uint remainingTokens;
    }

    //η δομή των αντικειμένων
    struct Item {
        uint itemId;
        uint[] itemTokens;
    }
    
    enum Stage {Init, Reg, Bid, Done} //τα στάδια εκτέλεσης της κλήρωσης
    Stage internal stage; //μεταβλητή stage τύπου Stage για τα στάδια εκτέλεσης
    uint lotteries = 1; //πλήθος λαχειοφόρων
    mapping(address => Person) tokenDetails; // διεύθυνση παίκτη
    Person [] internal bidders; //δυναμικός πίνακας παικτών
    Item [] internal items; //δυναμικός πίνακας αντικειμένων
    address[] internal winners; //δυναμικός πίνακας νικητών 
    address internal beneficiary; // ιδιοκτήτης του smart contract
    uint bidderCount = 0; // πλήθος των εγγεγραμένων παικτών
    event Winner(address winnerAddr, uint itemId, uint lotteriesCount); //συμβάν Winner για καταγραφή διεύθυνσης νικητή, αριθμό του αντικειμένου και αριθμό λαχειοφόρου

    //constructor
    constructor(uint itemsNumber) payable{
        //αρχικοποίηση
        beneficiary = msg.sender;
        uint[] memory emptyArray;
        for (uint m = 0; m < itemsNumber; m++){
            items.push(Item({itemId:m, itemTokens:emptyArray}));
            winners.push(address(0)); 
        }
        stage = Stage.Init;
    }

    //modifier για έλεγχο ποσού πληρωμής
    modifier hasMoney {
        require(msg.value >= 0.005 ether,"Not enough ethers");
        _;
    }

    //modifier για έλεγχο αριθμού αντικειμένου
    modifier isValid(uint _itemId) {
        bool flag = false;
        for (uint id = 0; id < items.length; id++) { 
            if(items[id].itemId == _itemId){
                flag = true;
            }
        }
        require(flag == true, "There is no item with this ID");
        _;
    }

    //modifier για έλεγχο πρόσβασης ιδιοκτήτη του smart contract
    modifier onlyOwner {
        require(msg.sender == beneficiary, "You are not the owner");
        _;
    }

    //συνάρτηση για έλεγχο αν είναι ήδη εγγεγραμμένος ο παίκτης
    function isRegistered() internal view returns (bool){
        bool flag = false;
        for (uint i = 0; i < bidderCount; i++){
            if(bidders[i].addr == msg.sender ){
                flag = true;
            }
        } 
        return flag;
    }

    //συνάρτηση εγγραφής νέου παίκτης
    function register() public payable hasMoney{
        require(stage == Stage.Reg,"Not in reg stage");
        require(msg.sender != beneficiary,"You are the beneficiary");
        bidders.push(Person({personId:bidderCount, addr:msg.sender, remainingTokens:5}));
        require(!isRegistered(), "You have already registered");
        tokenDetails[msg.sender] = bidders[bidderCount];
        bidderCount++;
    }

    // συνάρτηση για ποντάρισμα _count λαχείων στο αντικείμενο _itemId
    function bid (uint _itemId, uint _count) public payable isValid(_itemId){ 
        require(stage == Stage.Bid,"Not in bid stage");
        require(tokenDetails[msg.sender].remainingTokens >= _count, "Not enough tokens");

        for (uint y = 0; y < _count; y++) {
            items[_itemId].itemTokens.push(tokenDetails[msg.sender].personId);
            tokenDetails[msg.sender].remainingTokens--;
        }
    }

    //συνάρτηση παραγωγής τυχαίου αριθμού
    function generateRandomNumber(uint256 min, uint256 max) internal view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, msg.sender))) % (max - min + 1) + min;
        return random;
    }

    //συνάρτηση εύρεσης νικητή για κάθε αντικείμενο
    function revealWinners() public payable onlyOwner {
        require(stage == Stage.Done,"Not in done stage");
        uint temp = 0;
        uint lgth = items.length;
        for (uint id = 0; id<lgth; id++) {
            if(items[id].itemTokens.length > 0 && winners[id] == address(0)){
                temp = generateRandomNumber(0, items[id].itemTokens.length-1);
                winners[id] = (findAddress(items[id].itemTokens[temp]));
                emit Winner(winners[id], id, lotteries);
            }
        }
    }

    //συνάρτηση εύρεσης διεύθυνσης παίκτη από το id του
    function findAddress(uint id) internal view returns(address){
        for(uint k =0; k<bidders.length; k++){
            if(bidders[k].personId == id){
                return bidders[k].addr;
            }
        }
        return address(0);
    }

    //συνάρτηση ανάληψης των ether που βρίσκονται στο pool του contract
    function withdraw() public payable onlyOwner{
        address payable recipient = payable(beneficiary);
        recipient.transfer(address(this).balance);
    }

    //συνάρτηση επανεκκίνησης του συμβολαίου
    function reset(uint numberOfItems) public payable onlyOwner{
        for(uint k =0; k<bidders.length; k++){
            delete tokenDetails[bidders[k].addr];
        }
        lotteries++;
        delete bidders;
        delete items;
        delete winners;
        bidderCount = 0;
        stage = Stage.Init;
        uint[] memory emptyArray;
        for (uint m = 0; m < numberOfItems; m++){
            items.push(Item({itemId:m, itemTokens:emptyArray}));
            winners.push(address(0)); 
        }
    }

    //συνάρτηση μετακίνησης της εκτέλεσης σε επόμενο στάδιο από ιδιοκτήτη
    function advanceState() public payable onlyOwner{
        if(stage == Stage.Init){
            stage = Stage.Reg;
        }else if(stage == Stage.Reg){
            stage = Stage.Bid;
        }else if(stage == Stage.Bid){
            stage = Stage.Done;
        }
    }
}
