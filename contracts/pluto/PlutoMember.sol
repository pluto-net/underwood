pragma solidity ^0.4.17;


contract PlutoMember {
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
        position = unpackUint32(destUint32, testUint32, position);
        UnpackUint32Result(position, testUint32, destUint32);
        
        position = 0;
        string memory testStr = "testa";
        uint destLen = 32 + bytes(testStr).length;
        bytes memory destStr = new bytes(destLen);
        position = packString(testStr, destStr, position);
        PackStringResult(position, destStr, testStr);
        
        position = 0;
        position = unpackString(destStr, testStr, position);
        UnpackStringResult(position, testStr, destStr);
    }

    function mixedTest()
        public
    {
        uint32 testUint32 = 172;
        string memory testStr1 = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
        uint testStr1Ptr;
        
        string memory testStr2 = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?";
        uint testStr2Ptr;

        bytes memory dest = new bytes(4 + 32 + bytes(testStr1).length + 32 + bytes(testStr2).length);
        uint destPtr;
        assembly {
            destPtr := add(dest, 0x20)
            testStr1Ptr := add(testStr1, 0x00)
            testStr2Ptr := add(testStr2, 0x00)
        }

        uint position = 0;
        position = packString(testStr1, dest, position);
        position = packUint32(testUint32, dest, position);
        position = packString(testStr2, dest, position);

        position = 0;
        position = unpackString(dest, testStr1, position);
        UnpackStringResult(position, testStr1, dest);

        position = unpackUint32(dest, testUint32, position);
        UnpackUint32Result(position, testUint32, dest);

        position = unpackString(dest, testStr2, position);
        UnpackStringResult(position, testStr2, dest);
    }

    function storeMember (
        uint32 _memberId, 
        string _email,
        string _name, 
        string _institution,
        string _major
    )
        public
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
