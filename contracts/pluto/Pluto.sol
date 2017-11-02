pragma solidity ^0.4.17;

import '../zeppelin-solidity/ownership/Ownable.sol';
import './PlutoWallet.sol';


contract Pluto is Ownable {
    mapping (uint64 => address) public mWallets;

    event WalletCreated(uint64 indexed memberId, address indexed walletAddr);

    function createWallet(uint64 _memberId)
        onlyOwner
        returns (address walletAddr)
    {
        walletAddr = address(new PlutoWallet(_memberId));
        mWallets[_memberId] = walletAddr;

        WalletCreated(_memberId, walletAddr);
    }
}
