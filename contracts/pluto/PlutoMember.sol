pragma solidity ^0.4.17;


contract PlutoMember {
    /**
      Member data is transformed into byte array(type of bytes).
      [How to store data into bytes]
      uint32 => 4 bytes
      uint64 => 8 bytes
      uint => 32 bytes
      string => 32 bytes + (string.length) bytes
     */

    struct Member {
        uint memberId;
        string email;
        string name;
        string institution;
        string major;
        uint64 dbMemberId;
    }

    event MemberStored(uint indexed memberId);
    event MemberGotten(Member indexed member);

    uint mNumMembers = 0;
    mapping (uint => bytes) mMemberStorage;

    function addMember (
        string _email,
        string _name, 
        string _institution,
        string _major,
        uint64 _dbMemberId
    )
        public
    {
        uint memberId = mNumMembers;
        mNumMembers = mNumMembers + 1;

        Member memory member = Member(memberId, _email, _name, _institution, _major, _dbMemberId);
        bytes memory memberData = packMemberData(member);
        mMemberStorage[memberId] = memberData;
    }

    function getMemberInfo (uint _memberId)
        public
        returns (Member oMember)
    {
        bytes memory memberData = mMemberStorage[_memberId];
        oMember = unpackMemberData(memberData);
        MemberGotten(oMember);
    }

    function findMemberIdByDBMemberId(uint64 _dbMemberId)
        public
        returns (uint oMemberId)
    {
        for (uint i = 0; i < mNumMembers; i++) {
            Member memory member = getMemberInfo(i);
            if (member.dbMemberId == _dbMemberId) {
                oMemberId = member.memberId;
                break;
            }
        }
    }

    function packMemberData(Member member)
        public
        returns (bytes oMemberData)
    {
        uint bytesLen = 32 + 
                        32 + bytes(member.email).length + 
                        32 + bytes(member.name).length + 
                        32 + bytes(member.institution).length +
                        32 + bytes(member.major).length + 
                        8;
        uint position = 0;
        oMemberData = new bytes(bytesLen);

        position = packUint(member.memberId, oMemberData, position);
        position = packString(member.email, oMemberData, position);
        position = packString(member.name, oMemberData, position);
        position = packString(member.institution, oMemberData, position);
        position = packString(member.major, oMemberData, position);
        position = packUint64(member.dbMemberId, oMemberData, position);
    }

    function unpackMemberData(bytes _memberData)
        public
        returns (Member oMember)
    {
        uint position = 0;
        uint memberId;
        position = unpackUint(_memberData, memberId, position);
        
        string memory email;
        position = unpackString(_memberData, email, position);

        string memory name;
        position = unpackString(_memberData, name, position);

        string memory institution;
        position = unpackString(_memberData, institution, position);

        string memory major;
        position = unpackString(_memberData, major, position);

        uint64 dbMemberId;
        position = unpackUint64(_memberData, dbMemberId, position);

        oMember = Member(memberId, email, name, institution, major, dbMemberId);
    }

    function packUint(uint _value, bytes _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {
            mstore(add(add(_target, 0x20), _position), _value)
            oPosition := add(_position, 0x04)
        }
    }

    function unpackUint(bytes _data, uint _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {
            _target := mload(add(add(_data, 0x20), _position))
            oPosition := add(_position, 0x04)
        }
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
