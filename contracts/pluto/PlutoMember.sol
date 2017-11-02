pragma solidity ^0.4.17;


contract PlutoMember {
    /**
      Member data is transformed into byte array(type of bytes).
      [How to store data into bytes]
      uint32 => 4 bytes
      uint64 => 8 bytes
      string => 32 bytes + (string.length) bytes
     */

    struct Member {
        uint64 memberId;
        string email;
        string name;
        string institution;
        string major;
    }

    event MemberStored(uint64 indexed memberId);
    event MemberGotten(Member indexed member);

    uint64 mNumMembers = 0;
    mapping (uint64 => bytes) mMemberStorage;

    function storeMember (
        string _email,
        string _name, 
        string _institution,
        string _major
    )
        public
    {
        mNumMembers = mNumMembers + 1;
        uint64 memberId = mNumMembers++;

        Member memory member = Member(memberId, _email, _name, _institution, _major);
        bytes memory memberData = packMember(member);
        mMemberStorage[memberId] = memberData;
    }

    function packMember(Member member)
        internal
        returns (bytes oMemberData)
    {
        uint bytesLen = 8 + 
                        32 + bytes(member.email).length + 
                        32 + bytes(member.name).length + 
                        32 + bytes(member.institution).length +
                        32 + bytes(member.major).length;
        uint position = 0;
        oMemberData = new bytes(bytesLen);

        position = packUint64(member.memberId, oMemberData, position);
        position = packString(member.email, oMemberData, position);
        position = packString(member.name, oMemberData, position);
        position = packString(member.institution, oMemberData, position);
        position = packString(member.major, oMemberData, position);
    }

    function getMemberInfo (uint64 _memberId)
        public
        returns (Member oMember)
    {
        bytes memberData = mMemberStorage[_memberId];
        oMember = unpackMember(memberData);
        MemberGotten(oMember);
    }

    function unpackMember(bytes _memberData)
        internal
        returns (Member oMember)
    {
        uint position = 0;
        uint64 memberId;
        position = unpackUint64(_memberData, memberId, position);
        
        string email;
        position = unpackString(_memberData, email, position);

        string name;
        position = unpackString(_memberData, name, position);

        string institution;
        position = unpackString(_memberData, institution, position);

        string major;
        position = unpackString(_memberData, major, position);

        oMember = Member(memberId, email, name, institution, major);
    }

    function packUint32(uint32 _value, bytes _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {
            mstore(add(add(_target, 0x20), _position), mul(_value, exp(2, 224)))
            oPosition := add(_position, 0x04)
        }
    }

    function unpackUint32(bytes _data, uint32 _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {
            _target := div(mload(add(add(_data, 0x20), _position)), exp(2, 224))
            oPosition := add(_position, 0x04)
        }
    }

    function packUint64(uint64 _value, bytes _target, uint _position)
        internal
        returns(uint oPosition)
    {
        assembly {
            mstore(add(add(_target, 0x20), _position), mul(_value, exp(2, 192)))
            oPosition := add(_position, 0x08)
        }
    }

    function unpackUint64(bytes _data, uint64 _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {
            _target := div(mload(add(add(_data, 0x20), _position)), exp(2, 192))
            oPosition := add(_position, 0x08)
        }
    }

    function packString(string _value, bytes _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {
            let strlen := mload(_value)
            let dest := add(add(_target, 0x20), _position)
            mstore(dest, strlen)

            let p := 0x20
            let bytesleft := strlen
            for
                {}
                or(gt(bytesleft, 0x20), eq(bytesleft, 0x20))
                {p := add(p, 0x20)}
            {
                mstore(add(dest, p), mload(add(_value, p)))
                bytesleft := sub(bytesleft, 0x20)
            }
            
            let mask := sub(exp(0x100, sub(0x20, bytesleft)), 1)
            mstore(add(dest, p), or(and(mload(add(dest, p)), mask), and(mload(add(_value, p)), not(mask))))
            p := add(p, bytesleft)
            oPosition := add(_position, p)
        }
    }

    function unpackString(bytes _data, string _target, uint _position)
        internal
        returns (uint oPosition)
    {
        uint strlen;
        uint stringData;
        assembly {
            stringData := add(add(_data, 0x20), _position)
            strlen := mload(stringData)
        }
        _target = new string(strlen);
        assembly {
            mstore(_target, strlen)

            let p := 0x20
            let bytesleft := strlen
            for
                {}
                or(gt(bytesleft, 0x20), eq(bytesleft, 0x20))
                {p := add(p, 0x20)}
            {
                mstore(add(_target, p), mload(add(stringData, p)))
                bytesleft := sub(bytesleft, 0x20)
            }

            let mask := sub(exp(0x100, sub(0x20, bytesleft)), 1)
            mstore(add(_target, p), or(and(mload(add(_target, p)), mask), and(mload(add(stringData, p)), not(mask))))
            p := add(p, bytesleft)
            oPosition := add(_position, p)
        }
    }
}
