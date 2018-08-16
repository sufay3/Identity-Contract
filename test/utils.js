var abi = require("web3-eth-abi")
var utils = require("web3-utils")

var abiEncodeFunctionFromJson = function (json, functionName, params) {
    abis = json.abi || json;

    functionAbi = abis.filter(function (abi) {
        return abi.type === "function" && abi.name === functionName;
    });

    if (functionAbi.length === 0) {
        throw new Error("no specified function found in json.");
    }

    selector = abi.encodeFunctionSignature(functionAbi[0]);
    encodedParams = abi.encodeParameters(functionAbi[0], params);

    return selector + encodedParams.replace("0x", "")
};

module.exports = {
    abiEncode: abiEncodeFunctionFromJson,
    hexToString: utils.hexToString,
    utf8ToHex: utils.utf8ToHex
};
