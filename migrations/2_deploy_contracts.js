const StakingToken = artifacts.require("StakingToken");

module.exports = function (deployer) {
  deployer.deploy(StakingToken);
};
