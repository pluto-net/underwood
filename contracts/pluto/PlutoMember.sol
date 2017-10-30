pragma solidity ^0.4.17;

import '../zeppelin-solidity/ownership/Ownable.sol';

contract PlutoMember is Ownable {
    /**
      Member data is transformed into byte array(type of bytes).
      [How to store data into bytes]
      uint32 => 4 bytes
      string => 4 bytes + (string.length) bytes
     */
    struct Member {
        uint32 memberId;
        string email;
        string name;
        string institution;
        string major;
    }

    function storeMember (
        uint32 _memberId, 
        string _email,
        string _name, 
        string _institution,
        string _major
    )
        public
        onlyOwner
    {
        uint bytesLen = 4 + 4 + bytes(_email).length + 4 + bytes(_name).length + 4 + bytes(_institution).length + 4 + bytes(_major).length;
        uint position = 0;
        bytes memory memberData = new bytes(bytesLen);

        position = packUint32(_memberId, memberData, position);
        position = packString(_email, memberData, position);
        position = packString(_name, memberData, position);
        position = packString(_institution, memberData, position);
        position = packString(_major, memberData, position);
    }

    function reassembleMember (
        bytes memberData
    )
        public
        onlyOwner
        returns (Member member)
    {
        uint position = 0;
        uint32 memberId = 0;
        (memberId, position) = unpackUint32(memberData, position);
        // member = Member();
    }

    function packUint32(uint32 _value, bytes memory _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {
            mstore(add(add(_target, 0x20), _position), _value)
            oPosition := add(_position, 0x20)
        }
    }

    function unpackUint32(bytes _data, uint _position)
        internal
        returns (uint32 oValue, uint oPosition)
    {
        assembly {
            oValue := mload(add(add(_data, 0x20), _position))
            oPosition := add(_position, 0x20)
        }
    }

    function packString(string _value, bytes memory _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {
            let strlen := mload(_value)

            let dest := add(add(_target, 0x20), _position)
            mstore(dest, strlen)

            let p := 0x20
            let end := add(p, strlen)
            let leftbits := sub(end, p)
            for
                {}
                or(gt(leftbits, 0x20), eq(leftbits, 0x20))
                {p := add(p, 0x20)}
            {
                mstore(add(dest, p), mload(add(_value, p)))
                leftbits := sub(end, p)
            }
            
            let mask := exp(0x10, div(sub(0x20, leftbits), 0x04))
            mstore(add(dest, p), or(and(add(dest, p), mask), and(add(_value, p), not(mask))))

            oPosition := add(_position, end)
        }
    }

    function unpackString(bytes _data, uint _position)
        internal
        returns (string oValue, uint oPosition)
    {
        assembly {
            let p := _position
            let strlen := mload(add(_data, p))
            oValue := mload(0x40)
            mstore(0x40, add(oValue, and(add(add(strlen, 0x20), 0x1f), not(0x1f))))
            mstore(oValue, strlen)

            p := add(p, 0x20)
            let end := add(p, strlen)
            let leftbits := sub(end, p)
            let dest := add(oValue, p)
            for
                {}
                or(gt(leftbits, 0x20), eq(leftbits, 0x20))
                {p := add(p, 0x20)}
            {
                mstore(dest, mload(add(_data, p)))
                leftbits := sub(end, p)
                dest := add(oValue, p)
            }

            let mask := exp(0x10, div(sub(0x20, leftbits), 0x04))
            mstore(dest, or(and(dest, mask), and(add(_data, p), not(mask))))
        }
    }
}
