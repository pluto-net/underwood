pragma solidity ^0.4.15;

import '../zeppelin-solidity/ownership/Ownable.sol';

contract PlutoWallet is Ownable {
    uint public mMemberId;

    function PlutoWallet(uint _memberId) {
        mMemberId = _memberId;
    }
}