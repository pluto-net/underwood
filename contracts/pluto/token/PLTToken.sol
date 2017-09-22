pragma solidity ^0.4.15;

import '../../lib/token/MintableToken.sol';
import '../../lib/token/PausableToken.sol';
import '../../lib/math/SafeMath.sol';

contract PLTToken is MintableToken, PausableToken {
    using SafeMath for uint256;

    string public constant name = "Pluto";
    string public constant symbol = "PLT";
    uint8 public constant decimals = 18;
}