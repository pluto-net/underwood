pragma solidity ^0.4.17;

contract PlutoMemberDB {
    uint32 mNumMembers = 0;
    mapping (uint32 => bytes) mMemberStorage;

    function getMember(uint32 _memberId) returns (bytes memberData) {
        memberData = mMemberStorage[_memberId];
    }

    function setMember(bytes _memberData) {
        uint32 memberId = mNumMembers++;
        mMemberStorage[memberId] = _memberData;
    }
}