pragma solidity ^0.4.17;


library PlutoUtilsLibrary {
    function packUint(uint _value, bytes _target, uint _position)
        public
        returns (uint oPosition)
    {
        assembly {
            mstore(add(add(_target, 0x20), _position), _value)
            oPosition := add(_position, 0x04)
        }
    }

    function unpackUint(bytes _data, uint _target, uint _position)
        public
        returns (uint oPosition)
    {
        assembly {
            _target := mload(add(add(_data, 0x20), _position))
            oPosition := add(_position, 0x04)
        }
    }

    function packUint32(uint32 _value, bytes _target, uint _position)
        public
        returns (uint oPosition)
    {
        assembly {
            mstore(add(add(_target, 0x20), _position), mul(_value, exp(2, 224)))
            oPosition := add(_position, 0x04)
        }
    }

    function unpackUint32(bytes _data, uint32 _target, uint _position)
        public
        returns (uint oPosition)
    {
        assembly {
            _target := div(mload(add(add(_data, 0x20), _position)), exp(2, 224))
            oPosition := add(_position, 0x04)
        }
    }

    function packUint64(uint64 _value, bytes _target, uint _position)
        public
        returns(uint oPosition)
    {
        assembly {
            mstore(add(add(_target, 0x20), _position), mul(_value, exp(2, 192)))
            oPosition := add(_position, 0x08)
        }
    }

    function unpackUint64(bytes _data, uint64 _target, uint _position)
        public
        returns (uint oPosition)
    {
        assembly {
            _target := div(mload(add(add(_data, 0x20), _position)), exp(2, 192))
            oPosition := add(_position, 0x08)
        }
    }

    function packString(string _value, bytes _target, uint _position)
        public
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
        public
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