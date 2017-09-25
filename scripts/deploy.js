var fs = require('fs');
var path = require('path');
var process = require('process');
var Web3 = require('web3');

function readABIfile(abiPath) {
    return JSON.parse(fs.readFileSync(abiPath));
}

(function() {
    "use strict";

    var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

    web3.eth.getAccounts(function(err, accounts) {
        var abiObj = JSON.parse(fs.readFileSync(path.join(__dirname, '../build/Pluto.abi')));
        var bytecode = "0x" + fs.readFileSync(path.join(__dirname, '../build/Pluto.bin')).toString();

        var plutoContract = new web3.eth.Contract(abiObj);
        plutoContract.deploy({
                data: bytecode
            })
            .send({
                from: accounts[0],
                gas: 1500000,
                gasPrice: '30000000000000'
            })
            .on('error', function(error) {
                console.log(error);
                process.exit(2);
            })
            .on('transactionHash', function(transactionHash) {
                console.log(transactionHash);
            })
            .then(function(newContractInst) {
                console.log(newContractInst.options.address);
            });
    });
}());