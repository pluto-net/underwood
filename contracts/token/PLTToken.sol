pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/PausableToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract PLTToken is MintableToken, PausableToken {
    using SafeMath for uint256;

    string public constant name = "Pluto";
    string public constant symbol = "PLT";
    uint8 public constant decimals = 18;
}