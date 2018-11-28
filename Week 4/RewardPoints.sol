pragma solidity ^0.4.24;
 
import "./SafeMath.sol";

contract RewardPoint
{
    using SafeMath for uint;
    
    address private owner;
    mapping(address => bool) private isAdmin; // Quick way to check if an addr is an Admin

    struct Merchant
    {
        uint id;
        address addr; // the organization's owner address
        bool isApproved;
        mapping(address => bool) isOperator; // is addr approved by Merchant as operator
    }

    Merchant[] private merchants;
    mapping(address => uint) private addrToMerchantId; // get merchantId from an addr

    struct User
    {
        uint id;
        address addr;
        bool isApproved;
        uint totalEarnedPoints;
        uint totalReedemedPoints;
        mapping(uint => uint) merchantToEarnedPts; // keep track of points earned from each merchant separately
        mapping(uint => uint) merchantToRedeemedPts; // keep track of points used for at each merchant
    }

    User[] private users;
    mapping(address => uint) private addrToUserId;

    // =================================
    // Events and modifiers
    // =================================
    event AddedAdmin(address indexed admin);
    event RemovedAdmin(address indexed admin);

    event AddedMerchant(address indexed merchant, uint indexed id);
    event BannedMerchant(uint indexed merchantId);
    event ApprovedMerchant(uint indexed merchantId);
    event TransferredMerchantOwnership(uint indexed merchantId, address oldOwner, address newOwner);

    event AddedOperator(uint indexed merchantId, address indexed operator);
    event RemovedOperator(uint indexed merchantId, address indexed operator);

    event AddedUser(address indexed user, uint indexed id);
    event BannedUser(address indexed user, uint indexed id);
    event ApprovedUser(address indexed user, uint indexed id);

    event RewardedUser(address indexed user, uint indexed merchantId, uint points);
    event RedeemedPoints(address indexed user, uint indexed merchantId, uint points);

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmin()
    {
        require(isAdmin[msg.sender] || msg.sender == owner);
        _;
    }

    function merchantExist(uint _id) internal view returns(bool)
    {
        if (_id != 0 && _id < merchants.length) return true;
        return false;
    }

    function isMerchantValid(uint _id) internal view returns(bool)
    {
        if(merchantExist(_id) && merchants[_id].isApproved) return true;
        return false;
    }

    function isMerchantOwner(address _owner) internal view returns(bool)
    {
        uint id = addrToMerchantId[_owner];
        return (isMerchantValid(id) && merchants[id].addr == _owner);
    }

    modifier onlyMerchantOwner()
    {
        require(isMerchantOwner(msg.sender));
        _;
    }

    modifier onlyMerchant()
    {
        uint id = addrToMerchantId[msg.sender];
        bool isOperator = merchants[id].isOperator[msg.sender];

        require(isMerchantValid(id));
        require(isMerchantOwner(msg.sender) || isOperator);
        _;
    }

    function userExist(uint _id) internal view returns(bool)
    {
        if(_id != 0 && _id < users.length) return true;
        return false;
    }

    function isUserValid(uint _id) internal view returns(bool)
    {
        if(userExist(_id) && users[_id].isApproved) return true;
        return false;
    }

    modifier onlyUser()
    {
        require(isUserValid(addrToUserId[msg.sender]));
        _;
    }

    constructor() public
    {
        // Do not use ID 0 for first user and merchant to avoid returning invalid
        // first merchant/user when looking it up with addrToMerchantID mapping
        merchants.push(Merchant(0, 0, false));
        users.push(User(0, 0, false, 0, 0));
        owner = msg.sender;
    }

    // =================================
    // Owner Only Actions
    // =================================
    function addAdmin(address _admin) external onlyOwner
    {
        //Make sure not already an admin
        require(isAdmin[_admin] == false, "Address is already an admin");
        
        //Make sure not a merchant or merchant operator
        require(addrToMerchantId[_admin] == 0, "Cannot make merchant an admin");
        
        //Make sure not a customer
        require(addrToUserId[_admin] == 0, "Cannot make customer an admin");
        
        //Make an admin
        isAdmin[_admin] = true;
        
        emit AddedAdmin(_admin);
    }

    function removeAdmin(address _admin) external onlyOwner
    {
        //Check if this is actually an admin
        require(isAdmin[_admin] == true, "Address is not an admin");
        
        //Revoke admin rights
        isAdmin[_admin] = false;
        
        emit RemovedAdmin(_admin);
    }

    // =================================
    // Admin Only Actions
    // =================================
    function addMerchant(address _merchant) external onlyAdmin
    {
        //Ensure merchant wasn't already added
        require(addrToMerchantId[_merchant] == 0, "Merchant was already added to system");
        
        //Make sure merchant isn't an admin (conflict of interest)
        require(isAdmin[_merchant] == false, "System admin cannot be a merchant");
        
        //Make sure merchant is not a customer
        require(addrToUserId[_merchant] == 0, "Cannot make a customer a merchant");
        
        //Set ID as last index in array
        uint merchId = merchants.length;
        
        //Setup the new merchant
        Merchant memory newMerchant = Merchant(
            merchId,   
            _merchant,              //set merchant as the owner
            true                    //approve the merchant
        );
        
        //Add merchant to system
        merchants.push(newMerchant);
        
        //Approve Merchant as an operator
        merchants[merchId].isOperator[_merchant] = true;
        
        //Update merchant-to-ID tracker
        addrToMerchantId[_merchant] = merchId;
        
        emit AddedMerchant(_merchant, merchId);
    }

    function banMerchant(uint _id) external onlyAdmin
    {
        //Only ban valid merchants
        require(isMerchantValid(_id) == true, "Not a valid Merchant");
        
        //Ban the merchant
        merchants[_id].isApproved = false;
        
        emit BannedMerchant(_id);
    }

    function approveMerchant(uint _id) external onlyAdmin
    {
        //Only approve valid merchants
        require(isMerchantValid(_id) == true, "Not a valid Merchant");
        
        //Approve the merchant
        merchants[_id].isApproved = true;
        
        emit ApprovedMerchant(_id);
    }

    function addUser(address _user) external onlyAdmin
    {
        //Ensure customer wasn't already added
        require(addrToUserId[_user] == 0, "Customer was already added to system");
        
        //Make sure customer isn't an admin (conflict of interest)
        require(isAdmin[_user] == false, "System admin cannot be a customer");
        
        //Make sure customer is not a merchant
        require(addrToMerchantId[_user] == 0, "Cannot make a merchant a customer");
        
        //Set ID as last index in array
        uint userId = users.length;
        
        //Setup the new customer
        User memory newUser = User(
            userId,
            _user,
            false,
            0,
            0
        );
        
        //Add customer to system
        users.push(newUser);
        
        //Set the reward points mapping
        users[userId].merchantToEarnedPts[userId] = 0;
        users[userId].merchantToRedeemedPts[userId] = 0;
        
        //Update customer-to-ID tracker
        addrToUserId[_user] = userId;
        
        emit AddedUser(_user, userId);
    }

    function banUser(address _user) external onlyAdmin
    {
        //Try to get a user ID for the address given
        uint userId = addrToUserId[_user];
        
        //Make sure user exists in system and is approved
        require(isUserValid(userId) == true, "User does not exist or is not approved");
        
        users[userId].isApproved = false;
        
        emit BannedUser(_user, userId);
    }

    function approveUser(address _user) external onlyAdmin
    {
        //Try to get a user ID for the address given
        uint userId = addrToUserId[_user];
        
        //Ensure user exists before approving them
        require(userExist(userId) == true,  "User does not exist in system");
        
        //Approve user
        users[userId].isApproved = true;
        
        emit ApprovedUser(_user, userId);
    }

    // =================================
    // Merchant Owner Only Actions
    // =================================
    function addOperator(address _operator) external onlyMerchantOwner
    {
        //Make sure operator isn't an admin (conflict of interest)
        require(isAdmin[_operator] == false, "System admin cannot be an operator");
        
        //Make sure operator is not a customer
        require(addrToUserId[_operator] == 0, "Cannot make a customer an operator");
        
        //Get the merchant ID
        uint merchId = addrToMerchantId[msg.sender];
        
        //Make sure merchant is in the system
        require(merchantExist(merchId) == true, "Invalid merchant ID");
        
        merchants[merchId].isOperator[_operator] = true;
        
        emit AddedOperator(merchId, _operator);
    }

    function removeOperator(address _operator) external onlyMerchantOwner
    {
        //Get the merchant ID
        uint merchId = addrToMerchantId[msg.sender];
        
        //Revoke operator privileges
        merchants[merchId].isOperator[_operator] = false;
        
        emit RemovedOperator(merchId, _operator);
    }

    function transferMerchantOwnership(address _newAddr) external onlyMerchantOwner
    {
        //Make sure new merchant not in system under different merchant ID
        require(addrToMerchantId[_newAddr] == 0, "Merchant was already added to system");
        
        //Make sure new merchant is not an admin (conflict of interest)
        require(isAdmin[_newAddr] == false, "System admin cannot be a merchant");
        
        //Make sure new merchant is not a customer
        require(addrToUserId[_newAddr] == 0, "Cannot make a customer a merchant");
        
        //Get old merchant's ID
        uint oldMerchId = addrToMerchantId[msg.sender];
        
        //Ensure old merchant is not banned
        require(merchants[oldMerchId].isApproved == true, "Merchant is currently banned in system");
        
        //Remove the old merchant as owner
        merchants[oldMerchId].addr = address(0);
        
        //make new merchant the owner
        merchants[oldMerchId].addr = address(_newAddr);
        
        emit TransferredMerchantOwnership(oldMerchId, msg.sender, _newAddr);
    }

    // =================================
    // Merchant only actions
    // =================================
    function rewardUser(address _user, uint _points) external onlyMerchant
    {
        //Get customer and merchant IDs, if they exist
        uint userId = addrToUserId[_user];
        uint merchId = addrToMerchantId[msg.sender];
        
        //Ensure customer exists and is approved for rewards program
        require(isUserValid(userId) == true, "Customer does not exist or is not approved for rewards");
        
        //Make sure merchant is not banned
        require(merchants[merchId].isApproved == true, "Merchant is banned and so cannot offer rewards");
        
        //Update total points for this customer
        uint totalPts = users[userId].totalEarnedPoints;
        users[userId].totalEarnedPoints = totalPts.add(_points);
        
        //update merchant points for this customer
        uint merchPts = users[userId].merchantToEarnedPts[merchId];
        users[userId].merchantToEarnedPts[merchId] = merchPts.add(_points);
        
        emit RewardedUser(_user, merchId, _points);
    }

    // =================================
    // User only action
    // =================================
    function redeemPoints(uint _mId, uint _points) external onlyUser
    {
        // TODO: your code here
        // Hints:
        // 1. Get the user ID from caller
        // 2. Ensure user has at least _points at merchant with id _mID
        // 3. Update the appropriate fields in User structs
        // 4. Emit event
        
        //Ensure merchant exists and is approved to redeem points
        require(isMerchantValid(_mId) == true, "Merchant does not exist or is not approved to redeem points");
        
        //Get customer ID
        uint userId = addrToUserId[msg.sender];
        
        //Ensure customer has enough points with merchant to redeem
        require(users[userId].merchantToEarnedPts[_mId] >= _points, "Customer does not have enough points with this merchant to redeem");
        
        //Deduct the earned points
        uint earnedPts = users[userId].merchantToEarnedPts[_mId];
        users[userId].merchantToEarnedPts[_mId] = earnedPts.sub(_points);               //update merchant pts earned
        users[userId].totalEarnedPoints = users[userId].totalEarnedPoints.sub(_points); //update total pts earned
        
        //Update the used points variables
        uint redeemPts = users[userId].merchantToRedeemedPts[_mId];
        users[userId].merchantToRedeemedPts[_mId] = redeemPts.add(_points);                 //update merchant pts earned
        users[userId].totalReedemedPoints = users[userId].totalReedemedPoints.add(_points); //update total pts earned
        
        emit RedeemedPoints(msg.sender, _mId, _points);
    }

    // =================================
    // Getters
    // =================================

    function getMerchantById(uint _id) public view returns(uint, address, bool)
    {
        require(merchantExist(_id));
        Merchant storage m = merchants[_id];
        return(m.id, m.addr, m.isApproved);
    }

    function getMerchantByAddr(address _addr) public view returns(uint, address, bool)
    {
        uint id = addrToMerchantId[_addr];
        return getMerchantById(id);
    }

    function isMerchantOperator(address _operator, uint _mId) public view returns(bool)
    {
        require(merchantExist(_mId));
        return merchants[_mId].isOperator[_operator];
    }

    function getUserById(uint _id) public view returns(uint, address, bool, uint, uint)
    {
        require(userExist(_id));
        User storage u = users[_id];
        return(u.id, u.addr, u.isApproved, u.totalEarnedPoints, u.totalReedemedPoints);
    }

    function getUserByAddr(address _addr) public view returns(uint, address, bool, uint, uint)
    {
        uint id = addrToUserId[_addr];
        return getUserById(id);
    }

    function getUserEarnedPointsAtMerchant(address _user, uint _mId) public view returns(uint)
    {
        uint uId = addrToUserId[_user];
        require(userExist(uId));
        require(merchantExist(_mId));
        return users[uId].merchantToEarnedPts[_mId];
    }

    function getUserRedeemedPointsAtMerchant(address _user, uint _mId) public view returns(uint)
    {
        uint uId = addrToUserId[_user];
        require(userExist(uId));
        require(merchantExist(_mId));
        return users[uId].merchantToRedeemedPts[_mId];
    }
}