pragma solidity >=0.5.9;

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
    Person [4] bidders; // πίνακας 4 παικτών

    Item [3] public items; // πίνακας 3 αντικειμένων
    address[3] public winners; // πίνακας νικητών - η τιμή 0 δηλώνει πως δεν υπάρχει νικητής
    address public beneficiary; // ο πρόεδρος του συλλόγου και ιδιοκτήτης του smart contract

    uint bidderCount = 0; // πλήθος των εγγεγραμένων παικτών

    constructor() public payable{ //constructor
        // Αρχικοποίηση του προέδρου με τη διεύθυνση του κατόχου του έξυπνου συμβολαίου
        beneficiary = msg.sender;
        uint[] memory emptyArray;
        items[0] = Item({itemId:0, itemTokens:emptyArray}); // το πρώτο αντικείμενο
        items[1] = Item({itemId:1, itemTokens:emptyArray});
        items[2] = Item({itemId:2, itemTokens:emptyArray});
    }

    function register() public payable{ // εγγραφή παίκτη

        bidders[bidderCount].personId = bidderCount;

        // Αρχικοποίηση της διεύθυνσης του παίκτη
        bidders[bidderCount].addr = msg.sender;

        bidders[bidderCount].remainingTokens = 5; // μόνο 5 λαχεία
        tokenDetails[msg.sender] = bidders[bidderCount];
        bidderCount++;
    }

    function bid(uint _itemId, uint _count) public payable { // Ποντάρει _count λαχεία στο αντικείμενο _itemId
        bool flag = false;
        require(msg.value > _count);

        for (uint id = 0; id < items.length; id++) { 
            if(items[id].itemId == _itemId){
                flag = true;
            }

        }
        require(flag == true);
      
        /*
        Ενημέρωση του υπολοίπου λαχείων του παίκτη
        */
        /*
        Ενημέρωση της κληρωτίδας του _itemId με εισαγωγή των _count λαχείων που ποντάρει ο παίκτης
        */
    }

    modifier onlyOwner {
        require(msg.sender == beneficiary);
        _;
    }

    function revealWinners() public onlyOwner { // θα υλοποιήσετε modifier με το όνομα onlyOwner
        /*
        Για κάθε αντικείμενο που έχει περισσότερα από 0 λαχεία στην κάλπη του
        επιλέξτε τυχαία έναν νικητή από όσους έχουν τοποθετήσει το λαχείο τους
        */
        for (uint id = 0; id < 3; id++) { // Εδώ για 3 μόνο αντικείμενα
        // παραγωγή τυχαίου αριθμού
        // ανάκτηση του αριθμού παίκτη που είχε αυτό το λαχείο
        // ενημέρωση του πίνακα winners με τη διεύθυνση του νικητή
        }
    }
}
