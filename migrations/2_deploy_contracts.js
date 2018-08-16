var Identity = artifacts.require("Identity");
var IdentityManager = artifacts.require("IdentityManager");

module.exports = function (deployer) {
    // deploy IdentityManager contract
    deployer.deploy(IdentityManager);
}