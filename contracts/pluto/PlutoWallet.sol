pragma solidity ^0.4.17;

import '../zeppelin-solidity/ownership/Ownable.sol';


contract PlutoWallet is Ownable {
    uint64 public mMemberId;

    function PlutoWallet(uint64 _memberId) {
        mMemberId = _memberId;
    }
}