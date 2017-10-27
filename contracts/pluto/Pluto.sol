pragma solidity ^0.4.17;

import '../zeppelin-solidity/ownership/Ownable.sol';
import './PlutoWallet.sol';


contract Pluto is Ownable {
    mapping (uint => address) public mWallets;

    event WalletCreated(uint indexed memberId, address indexed walletAddr);

    function createWallet(uint _memberId)
        onlyOwner
        returns (address walletAddr)
    {
        walletAddr = address(new PlutoWallet(_memberId));
        mWallets[_memberId] = walletAddr;

        WalletCreated(_memberId, walletAddr);
    }
}
