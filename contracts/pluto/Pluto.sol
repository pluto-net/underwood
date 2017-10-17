pragma solidity ^0.4.15;

import '../zeppelin-solidity/ownership/Ownable.sol';
import './PlutoWallet.sol';


contract Pluto is Ownable {
    mapping (uint => address) public mWallets;

    event WalletCreated(uint indexed memberId, address indexed walletAddr);

    function createWallet(uint _memberId)
        onlyOwner
    {
        address walletAddr = address(new PlutoWallet(_memberId));
        mWallets[_memberId] = walletAddr;

        WalletCreated(_memberId, walletAddr);
    }
}
