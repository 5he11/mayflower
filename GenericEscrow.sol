pragma solidity ^0.5.0;

import "./openzeppelin-contracts-2.5.1/contracts/math/SafeMath.sol";
import "./openzeppelin-contracts-2.5.1/contracts/ownership/Secondary.sol";
import "./openzeppelin-contracts-2.5.1/contracts/utils/Address.sol";

contract GenericEscrow is Secondary {
    using SafeMath for uint256;
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    uint256 private _balance;

    function balance() public view returns (uint256) {
        return _balance;
    }

    function deposit(address payee) public onlyPrimary payable {
        uint256 amount = msg.value;
        _balance = _balance.add(amount);

        emit Deposited(payee, amount);
    }

    function withdraw(address payable payee, uint256 weiAmount) public onlyPrimary {
        uint256 newBalance = balance().sub(weiAmount);
        require(newBalance >= 0, "Escrow: insufficient balance");

        _balance = newBalance;
        payee.transfer(weiAmount);

        emit Withdrawn(payee, weiAmount);
    }

    function withdrawWithGas(address payable payee) public onlyPrimary {
        uint256 newBalance = balance().sub(weiAmount);
        require(newBalance >= 0, "Escrow: insufficient balance");

        _balance = newBalance;
        payee.sendValue(weiAmount);

        emit Withdrawn(payee, weiAmount);
    }
}
