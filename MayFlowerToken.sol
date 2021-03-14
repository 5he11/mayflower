pragma solidity ^0.5.0;

import "./openzeppelin-contracts-2.5.1/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "./openzeppelin-contracts-2.5.1/contracts/token/ERC20/ERC20Mintable.sol";

contract MayFlowerToken is ERC20Mintable, ERC20Detailed, RefundableCrowdsale, MintedCrowdsale
{
  GenericEscrow private _escrow;

  constructor (
    string memory name, 
    string memory symbol,
    uint256 openingTime,
    uint256 closingTime,
    uint256 rate,
    address payable wallet,
    uint256 goal
  ) 
    public
    ERC20Detailed(name, symbol, 18)
    Crowdsale(rate, wallet, this)
    TimedCrowdsale(openingTime, closingTime)
    RefundableCrowdsale(goal)
  {
    _escrow = new GenericEscrow();
  }

  function _transfer(address sender, address recipient, uint256 amount) internal
  {
    if (recipient == address(this))
    {
        require(!finalized() || (finalized() && !goalReached()), "MayFlowerToken: refund not allowed");
    }

    bool result = super._transfer(sender, recipient, amount);
    if (result)
    {
        if (recipient == address(this))
        {
            uint256 weiAmount = amount.div(_rate);
            require(weiRaised() > weiAmount, "MayFlowerToken: insufficient balance");
            setWeiRaised(weiRaised().sub(weiAmount));

            _burn(sender, amount);
            
            _escrow.withdraw(sender, weiAmount);
        }
    }

    return result;
  }
  
  function _forwardFunds() internal {
      _escrow.deposit.value(msg.value)(_msgSender());
  }

  function finalize() public {
    require(hasClosed(), "FinalizableCrowdsale: not closed");
    
    if (goalReached()) {
        wallet().transfer(address(this).balance);
    }

    if (!finalized()) {
        super.finalize();
    }
  }

  function _finalization() internal {
      // solhint-disable-previous-line no-empty-blocks
  }

  function claimRefund(address payable refundee) public
  {
  }
}
