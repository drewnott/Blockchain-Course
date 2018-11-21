pragma solidity ^0.4.24;

import './ERC721.sol';

contract CryptoBallers is ERC721
{
    struct Baller
    {
        string name;
        uint level;
        uint offenseSkill;
        uint defenseSkill;
        uint winCount;
        uint lossCount;
    }

    address owner;
    Baller[] public ballers;

    // Mapping for if address has claimed their free baller
    mapping(address => bool) claimedFreeBaller;

    // Fee for buying a baller
    uint ballerFee = 0.10 ether;

    /**
    * @dev Ensures ownership of the specified token ID
    * @param _tokenId uint256 ID of the token to check
    */
    modifier onlyOwnerOf(uint256 _tokenId)
    {
        // TODO add your code
        require(msg.sender == ownerOf(_tokenId), "Caller does not own this token");
        _;
    }

    /**
    * @dev Ensures ownership of contract
    */
    modifier onlyOwner()
    {
        // TODO add your code
        require(owner == msg.sender, "Not the owner of this contract");
        _;
    }

    /**
    * @dev Ensures baller has level above specified level
    * @param _level uint level that the baller needs to be above
    * @param _ballerId uint ID of the Baller to check
    */
    modifier aboveLevel(uint _level, uint _ballerId)
    {
        require(_exists(_ballerId));
        require(ballers[_ballerId].level > _level, "Baller below required level");
        _; 
    }

    constructor() public
    {
        owner = msg.sender;
    }

    /**
    * @dev Allows user to claim first free baller, ensure no address can claim more than one
    */
    function claimFreeBaller() public
    {
        // TODO add your code
        require(claimedFreeBaller[msg.sender] == false, "Already claimed free baller");
        
        _createBaller("Blake Griffin", 1,  3, 3);
        claimedFreeBaller[msg.sender] = true;
    }

    /**
    * @dev Allows user to buy baller with set attributes
    */
    function buyBaller() public payable
    {
        // TODO add your code
        require(msg.value >= ballerFee, "NSF. Pay at least 0.10 ether to buy a baller");
        
        //create ballers with different stats based on how much caller spends
        if (msg.value == 0.10 ether)
        {
            _createBaller("Rudy Gobert", 1, 4, 3);
        }
        else if (msg.value <= 0.20 ether)
        {
            _createBaller("Robert Covington", 1, 3, 8);
        }
        else if (msg.value <= 0.30 ether)
        {
            _createBaller("Shaquille O'Neal", 1, 8, 2);
        }
        else if (msg.value <= 0.40 ether)
        {
            _createBaller("Chris Bosch", 1, 5, 4);
        }
        else if (msg.value <= 0.50 ether)
        {
            _createBaller("Lebron James", 1, 7, 5);
        }
        else if (msg.value <= 0.60 ether)
        {
            _createBaller("Kobe Bryant", 1, 6, 3);
        }
        else if (msg.value <= 0.70 ether)
        {
            _createBaller("Allen Iverson", 1, 5, 7);
        }
        else
        {
            _createBaller("Michael Jordan", 1, 8, 7);
        }
    }

    /**
    * @dev Play a game with your baller and an opponent baller
    * If your baller has more offensive skill than your opponent's defensive skill
    * you win, your level goes up, the opponent loses, and vice versa.
    * If you win and your baller reaches level 5, you are awarded a new baller with a mix of traits
    * from your baller and your opponent's baller.
    * @param _ballerId uint ID of the Baller initiating the game
    * @param _opponentId uint ID that the baller needs to be above
    */
    function playBall(uint _ballerId, uint _opponentId) onlyOwnerOf(_ballerId) public
    {
       // TODO add your code
       //Ensure opponent has a valid Baller card
       require(_exists(_opponentId) == true, "Opponent's Baller card is invalid");
       
       //Pit player and opponent against each other
       if (ballers[_ballerId].offenseSkill > ballers[_opponentId].defenseSkill)
       {
            //Player wins, opponent loses
            ballers[_ballerId].winCount += 1;
            ballers[_ballerId].level += 1;
            ballers[_opponentId].lossCount += 1;
            
            //When player's baller reaches level 5, award a new baller
            if (ballers[_ballerId].level == 5)
            {
               (uint lvl, uint atk, uint def) = _breedBallers(ballers[_ballerId], ballers[_opponentId]);
               
               //Create random name based on names of battling ballers
               string memory name;
               
               if (lvl == 1) {name = "Stephen Curry"; }
               else if (lvl == 2) {name = "James Harden"; }
               else if (lvl == 3) {name = "Dwight Howard"; }
               else if (lvl == 4) {name = "Dirk Nowitzki"; }
               else if (lvl == 5) {name = "Yao Ming"; }
               else if (lvl == 6) {name = "Buddy Hield"; }
               else if (lvl == 7) {name = "Magic Johnson"; }
               else {name = "Larry Bird"; }
               
               
               _createBaller(name, lvl, atk, def);
            }
       }
       else if (ballers[_ballerId].offenseSkill < ballers[_opponentId].defenseSkill)
       {
            //Opponent wins, player loses
            ballers[_opponentId].winCount += 1;
            ballers[_opponentId].level += 1;
            ballers[_ballerId].lossCount += 1;
       }
       else
       {
            //Draw: player offense = opponent defense
            ballers[_ballerId].lossCount += 1;
            ballers[_opponentId].lossCount += 1;
       }
    }

    /**
    * @dev Changes the name of your baller if they are above level two
    * @param _ballerId uint ID of the Baller who's name you want to change
    * @param _newName string new name you want to give to your Baller
    */
    function changeName(uint _ballerId, string _newName) external aboveLevel(2, _ballerId) onlyOwnerOf(_ballerId)
    {
        // TODO add your code
        ballers[_ballerId].name = _newName;
    }

    /**
   * @dev Creates a baller based on the params given, adds them to the Baller array and mints a token
   * @param _name string name of the Baller
   * @param _level uint level of the Baller
   * @param _offenseSkill offensive skill of the Baller
   * @param _defenseSkill defensive skill of the Baller
   */
    function _createBaller(string _name, uint _level, uint _offenseSkill, uint _defenseSkill) internal
    {
        // TODO add your code
        
        //Add new baller to list of ballers
        ballers.push(Baller(_name, _level, _offenseSkill, _defenseSkill, 0, 0));
        
        //Get a token representing baller. Use array index as the unique ID. Also, signal
        //Transfer event to external sources
        _mint(msg.sender, ballers.length - 1);
    }

    /**
    * @dev Helper function for a new baller which averages the attributes of the level, attack, defense of the ballers
    * @param _baller1 Baller first baller to average
    * @param _baller2 Baller second baller to average
    * @return tuple of level, attack and defense
    */
    function _breedBallers(Baller _baller1, Baller _baller2) internal pure returns (uint, uint, uint)
    {
        uint level = _baller1.level.add(_baller2.level).div(2);
        uint attack = _baller1.offenseSkill.add(_baller2.offenseSkill).div(2);
        uint defense = _baller1.defenseSkill.add(_baller2.defenseSkill).div(2);
        return (level, attack, defense);
    }
}