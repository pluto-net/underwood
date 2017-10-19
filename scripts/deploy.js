var fs = require('fs');
var path = require('path');
var process = require('process');
var Web3 = require('web3');

var plutoWalletAddr = '0xb738c45e214d6a2471cbd661f8e34c496e428ad4';
var plutoWalletPassword = process.env.PLUTO_WALLET_PASSWORD;

function readABIfile(abiPath) {
    return JSON.parse(fs.readFileSync(abiPath));
}

(function() {
    "use strict";

    var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
    web3.eth.personal.unlockAccount(plutoWalletAddr, plutoWalletPassword).then(function() {
        var abiObj = JSON.parse(fs.readFileSync(path.join(__dirname, '../build/Pluto.abi')));
        var bytecode = "0x" + fs.readFileSync(path.join(__dirname, '../build/Pluto.bin')).toString();

        var plutoContract = new web3.eth.Contract(abiObj);
        plutoContract.deploy({
                data: bytecode
            })
            .send({
                from: plutoWalletAddr,
                gas: 1500000,
            })
            .on('error', function(error) {
                console.log('An error occured.');
                console.log(error);
                process.exit(2);
            })
            .on('transactionHash', function(transactionHash) {
                console.log('transactionHash: ' + transactionHash);
            })
            .then(function(newContractInst) {
                console.log('Contract address: ' + newContractInst.options.address);
            });
    });
}());