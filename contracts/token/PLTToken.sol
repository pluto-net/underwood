pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract PLTToken is MintableToken {
    string public constant name = "Pluto";
    string public constant symbol = "PLT";
    string public constant decimals = 18;
}