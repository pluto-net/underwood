pragma solidity ^0.4.15;

import '../zeppelin-solidity/ownership/Ownable.sol';
import './PlutoWallet.sol';

contract Pluto is Ownable {
    mapping (uint => address) wallets;

    function createWallet(uint _memberId) {
        wallets[_memberId] = new PlutoWallet(_memberId);
    }
}
