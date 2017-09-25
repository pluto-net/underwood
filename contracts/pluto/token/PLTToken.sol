pragma solidity ^0.4.15;

import '../../zeppelin-solidity/token/MintableToken.sol';
import '../../zeppelin-solidity/token/PausableToken.sol';
import '../../zeppelin-solidity/math/SafeMath.sol';


contract PLTToken is MintableToken, PausableToken {
    using SafeMath for uint256;

    string public constant name = "Pluto";
    string public constant symbol = "PLT";
    uint8 public constant decimals = 18;
}