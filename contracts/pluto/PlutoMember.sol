pragma solidity ^0.4.17;

import '../zeppelin-solidity/ownership/Ownable.sol';

contract PlutoMember is Ownable {
    /**
      Member data is transformed into byte array(type of bytes).
      [How to store data into bytes]
      uint32 => 4 bytes
      string => 4 bytes + (string.length) bytes
     */
    struct MemberSchema {
        uint32 memberId;
        string email;
        string name;
        string institution;
        string major;
    }

    function storeMember(
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

        position = storeUint32(_memberId, memberData, position);
        position = storeString(_email, memberData, position);
        position = storeString(_name, memberData, position);
        position = storeString(_institution, memberData, position);
        position = storeString(_major, memberData, position);
    }

    function storeUint32(uint32 _value, bytes memory _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {
            mstore(add(add(_target, 0x20), _position), _value)
            oPosition := add(_position, 0x20)
        }
    }

    function storeString(string _value, bytes memory _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {
            let strlen := mload(_value)
            let p := 0x00

            let data := add(add(_target, 0x20), _position)
            mstore(add(data, p), strlen)
            p := add(p, 0x20)

            let end := add(p, strlen)
            let leftbits := sub(end, p)
            for
                {}
                or(gt(leftbits, 0x20), eq(leftbits, 0x20))
                {p := add(p, 0x20)}
            {
                mstore(add(data, p), mload(add(_value, p)))
                leftbits := sub(end, p)
            }
            
            let mask := exp(0x10, div(sub(0x20, leftbits), 0x04))
            mstore(add(data, p), or(and(add(data, p), mask), and(add(_value, p), not(mask))))
        }
    }
}
