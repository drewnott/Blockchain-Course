pragma solidity ^0.4.24;

import "./IERC20.sol";
import "./SafeMath.sol";

/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) internal _balances;
  mapping (address => mapping (address => uint256)) internal _allowed;
  uint256 internal _totalSupply;

  // -----------------------------------------
  // Public Functions (DO NOT CHANGE!!)
  // -----------------------------------------

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    // TODO: Your Code Here
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    // TODO: Your Code Here
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address owner, address spender) public view returns(uint256) {
    // TODO: Your Code Here
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  * @return Should always return true if all conditions are met. Otherwise throw exception.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    // TODO: Your Code Here
    
    //Ensure owner has enough tokens before transferring
    require(_balances[msg.sender] >= value, "Owner does not have sufficient tokens to transfer");
    
    //Ensure we have a valid recipient address
    require(to != 0, "Invalid receiver address");
    
    _balances[msg.sender] = _balances[msg.sender].sub(value);   //update (decrease) owner's balance of tokens
    _balances[to] = _balances[to].add(value);                   //update (increase) buyer's balance of tokens
    
    emit Transfer(msg.sender, to, value); //log the details of the transfer to blockchain
    
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Note that the owner (msg.sender) can approve someone to spend tokens that they do not yet have.
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   * @return Should always return true if success. Otherwise throw exception.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    // TODO: Your Code Here
    //Ensure we have enough tokens to supply
    require(_totalSupply >= value, "Approved tokens exceeds total token supply");
    
    //Spender address must be valid location
    require(spender != 0, "Invalid spender address");
    
    //number of tokens needs to be non-zero,  i.e. valid
    require(value > 0, "Invalid number of tokens");
    
    _allowed[msg.sender][spender] = value; //set the amount of tokens owner is allowing proxy to send
    
    emit Approval(msg.sender, spender, value); //log the approval on the blockchain
    
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    // TODO: Your Code Here
    require(to != 0, "Invalid \"To\" address");
    require(_allowed[from][msg.sender] >= value, "Total tokens exceeds allowed amount");
    require(_balances[from] !=  0, "Owner has no tokens");
    require(_balances[from] >= value, "Owner does not have enough tokens requested for transfer");
    
    _balances[from] = _balances[from].sub(value);                       //update (decrease) owner's balance of tokens
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value); //update (decrease) total tokens authorized to transfer on owner's behalf
    _balances[to] = _balances[to].add(value);                           //update (increase) buyer's balance of tokens
    
    emit Transfer(from, to, value); //log the transfer on the blockchain
    
    return true;
  }

  // -----------------------------------------
  // Internal functions (you can write any other internal helper functions here)
  // -----------------------------------------
}