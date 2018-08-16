var IdentityManager = artifacts.require("IdentityManager");
var Identity = artifacts.require("Identity");
var hexToString = require("./utils").hexToString;
var utf8ToHex = require("./utils").utf8ToHex;

contract("IdentityManager", function (accounts) {
    // zero address
    var zeroAddress = "0x0000000000000000000000000000000000000000";

    it("should create an identity", function () {
        var identityManager;

        var id = "184738199010200917",
            name = "罗兰",
            gender = 0,
            birthday = "1990-10-20",
            nationality = "中国",
            province = "上海",
            city = "宝山",
            documentHashes = ["0x8938398938398938398938398938398938398938398938398938398938398938"];

        return IdentityManager.deployed().then(instance => {
            identityManager = instance;

            return instance.createIdentity(
                utf8ToHex(id),
                utf8ToHex(name),
                gender,
                utf8ToHex(birthday),
                utf8ToHex(nationality),
                utf8ToHex(province),
                utf8ToHex(city),
                documentHashes
            );
        }).then(result => {
            return identityManager.getIdentityCount();
        }).then(count => {
            assert.equal(count.toNumber(), 1, "the identity count is wrong");
            return identityManager.getIdentityData(accounts[0]);
        }).then(data => {
            assert.equal(data[0], accounts[0], "the owner is wrong");
            assert.equal(hexToString(data[1]), id, "the id is wrong");
            assert.equal(hexToString(data[2]), name, "the name is wrong");
            assert.equal(data[3], gender, "the gender is wrong");
            assert.equal(hexToString(data[4]), birthday, "the birthday is wrong");
            assert.equal(hexToString(data[5]), nationality, "the nationality is wrong");
            assert.equal(hexToString(data[6]), province, "the province is wrong");
            assert.equal(hexToString(data[7]), city, "the city is wrong");
            assert.deepEqual(data[8], documentHashes, "the document hashes are wrong");
        });
    });

    it("should set the validity of the identity to true, being a false value originally", function () {
        var identityManager;

        return IdentityManager.deployed().then(instance => {
            identityManager = instance;
            return instance.identityValid(accounts[0]);
        }).then(valid => {
            assert.equal(valid, false, "the original validity is wrong");
            return identityManager.setIdentityValidity(accounts[0], true);
        }).then(result => {
            return identityManager.identityValid(accounts[0]);
        }).then(valid => {
            assert.equal(valid, true, "the resulting validity is wrong");
        });
    });

    it("should has an identity", function () {
        return IdentityManager.deployed().then(instance => {
            return instance.identityExists(accounts[0]);
        }).then(exist => {
            assert.equal(exist, true, "the result of existence is wrong");
        });
    });

    it("should get a non-zero address of the identity", function () {
        return IdentityManager.deployed().then(instance => {
            return instance.getIdentityAddress(accounts[0]);
        }).then(address => {
            assert.notEqual(address, zeroAddress, "the address is wrong");
        });
    });

    it("should modify the existing identity", function () {
        var identityManager;

        var id = "2000000000000000",
            name = "Allen",
            gender = 1,
            birthday = "1995-11-20",
            nationality = "英国",
            province = "伦敦",
            city = "伦敦",
            documentHashes = ["0x0fa2398938398938398938398938398938398938398938398938398938398938"];

        return IdentityManager.deployed().then(instance => {
            identityManager = instance;
            return instance.getIdentityCount();
        }).then(count => {
            assert.equal(count.toNumber(), 1, "the count of the existing identities is wrong");

            return identityManager.modifyIdentity(
                utf8ToHex(id),
                utf8ToHex(name),
                gender,
                utf8ToHex(birthday),
                utf8ToHex(nationality),
                utf8ToHex(province),
                utf8ToHex(city),
                documentHashes
            );
        }).then(result => {
            return identityManager.getIdentityData(accounts[0]);
        }).then(data => {
            assert.equal(data[0], accounts[0], "the owner is wrong");
            assert.equal(hexToString(data[1]), id, "the id is wrong");
            assert.equal(hexToString(data[2]), name, "the name is wrong");
            assert.equal(data[3], gender, "the gender is wrong");
            assert.equal(hexToString(data[4]), birthday, "the birthday is wrong");
            assert.equal(hexToString(data[5]), nationality, "the nationality is wrong");
            assert.equal(hexToString(data[6]), province, "the province is wrong");
            assert.equal(hexToString(data[7]), city, "the city is wrong");
            assert.deepEqual(data[8], documentHashes, "the document hashes are wrong");
        });
    });

    it("should delete the existing identity", function () {
        var identityManager;

        return IdentityManager.deployed().then(instance => {
            identityManager = instance;
            return instance.getIdentityCount();
        }).then(count => {
            assert.equal(count.toNumber(), 1, "the count of the existing identities is wrong");
            return identityManager.removeIdentity();
        }).then(result => {
            return identityManager.getIdentityAddress(accounts[0]);
        }).then(address => {
            assert.equal(address, zeroAddress, "the identity address is wrong");
        });
    });

    it("should get zero identity", function () {
        var identityManager;

        return IdentityManager.deployed().then(instance => {
            identityManager = instance;
            return instance.getIdentityCount();
        }).then(count => {
            assert.equal(count.toNumber(), 0, "the count of the identities is wrong");
        });
    });

    it("should has no an identity", function () {
        return IdentityManager.deployed().then(instance => {
            return instance.identityExists(accounts[1]);
        }).then(exist => {
            assert.equal(exist, false, "the result of existence is wrong");
        });
    });
});