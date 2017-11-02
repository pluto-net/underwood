pragma solidity ^0.4.17;

import "../zeppelin-solidity/math/SafeMath.sol";


contract PlutoDB {
    mapping(bytes32 => uint32) mUint32Storage;
    mapping(bytes32 => uint64) mUint64Storage;
    mapping(bytes32 => string) mStringStorage;

    function getUint32(bytes32 key)
        constant
        returns (uint32)
    {
        return mUint32Storage[key];
    }

    function setUint32(bytes32 key, uint32 value) {
        mUint32Storage[key] = value;
    }

    function deleteUint32(bytes32 key) {
        delete mUint32Storage[key];
    }

    function getUint64(bytes32 key)
        constant
        returns (uint64)
    {
        return mUint64Storage[key];
    }

    function setUint64(bytes32 key, uint64 value) {
        mUint64Storage[key] = value;
    }

    function deleteUint64(bytes32 key) {
        delete mUint32Storage[key];
    }

    function getString(bytes32 key)
        constant
        returns (string)
    {
        return mStringStorage[key];
    }

    function setString(bytes32 key, string value) {
        mStringStorage[key] = value;
    }

    function deleteString(bytes32 key) {
        delete mStringStorage[key];
    }
}