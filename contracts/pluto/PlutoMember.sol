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

    event PackUint32Result(uint position, bytes result, uint32 source);
    event UnpackUint32Result(uint position, uint32 result, bytes source);
    event PackStringResult(uint position, bytes result, string source);
    event UnpackStringResult(uint position, string result, bytes source);
    
    function test()
        public
    {
        uint position = 0;
        
        uint32 testUint32 = 4;
        bytes memory destUint32 = new bytes(4);
        position = packUint32(testUint32, destUint32, position);
        PackUint32Result(position, destUint32, testUint32);
        
        position = 0;
        (testUint32, position) = unpackUint32(destUint32, position);
        UnpackUint32Result(position, testUint32, destUint32);
        
        position = 0;
        string memory testStr = "testa";
        uint destLen = 32 + bytes(testStr).length;
        bytes memory destStr = new bytes(destLen);
        position = packString(testStr, destStr, position);
        PackStringResult(position, destStr, testStr);
        
        position = 0;
        (testStr, position) = unpackString(destStr, position);
        UnpackStringResult(position, testStr, destStr);
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

    function packUint32(uint32 _value, bytes _target, uint _position)
        internal
        returns (uint oPosition)
    {
        assembly {

            mstore(add(add(_target, 0x20), _position), mul(_value, exp(2, 224)))
            oPosition := add(_position, 0x04)
        }
    }

    function unpackUint32(bytes _data, uint _position)
        internal
        returns (uint32 oValue, uint oPosition)
    {
        assembly {
            oValue := div(mload(add(add(_data, 0x20), _position)), exp(2, 224))
            oPosition := add(_position, 0x04)
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
            oPosition := add(_position, 0x20)
            let bytesleft := strlen
            for
                {}
                or(gt(bytesleft, 0x20), eq(bytesleft, 0x20))
                {p := add(p, 0x20)}
            {
                mstore(add(dest, p), mload(add(_value, p)))
                bytesleft := sub(bytesleft, 0x20)
                oPosition := add(oPosition, 0x20)
            }
            
            let mask := sub(exp(0x100, sub(0x20, bytesleft)), 1)
            mstore(add(dest, p), or(and(mload(add(dest, p)), mask), and(mload(add(_value, p)), not(mask))))
            oPosition := add(oPosition, 0x20)
        }
    }

    function unpackString(bytes _data, uint _position)
        internal
        returns (string oValue, uint oPosition)
    {
        assembly {
            let stringData := add(add(_data, 0x20), _position)
            let strlen := mload(stringData)
            oValue := mload(0x40)
            mstore(0x40, add(oValue, and(add(add(strlen, 0x20), 0x1f), not(0x1f))))
            mstore(oValue, strlen)

            let p := 0x20
            oPosition := add(_position, 0x20)
            let bytesleft := strlen
            for
                {}
                or(gt(bytesleft, 0x20), eq(bytesleft, 0x20))
                {p := add(p, 0x20)}
            {
                mstore(add(oValue, p), mload(add(stringData, p)))
                bytesleft := sub(bytesleft, 0x20)
                oPosition := add(oPosition, 0x20)
            }

            let mask := sub(exp(0x100, sub(0x20, bytesleft)), 1)
            mstore(add(oValue, p), or(and(mload(add(oValue, p)), mask), and(mload(add(stringData, p)), not(mask))))
            oPosition := add(oPosition, bytesleft)
        }
    }
}
