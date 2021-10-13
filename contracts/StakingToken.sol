pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingToken is ERC20, Ownable {
    using SafeMath for uint256;

    address[] private stakeHolders;

    mapping(address => uint256) internal stakes;

    mapping(address => uint256) internal rewards;

    constructor() ERC20("StakingToken", "STK") {
        _mint(msg.sender, 10000000);
    }

    function _isStakeHolder(address _address) public view returns (bool isStakeHolder, uint256 stakeHolderIndex) {
        for (uint256 i = 0; i < stakeHolders.length; i++) {
            if (_address == stakeHolders[i]) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function addStakeHolder(address _address) public {
        (bool isStakeHolder, ) = _isStakeHolder(_address);
        require(!isStakeHolder, "Already Stake Holder");
        stakeHolders.push(_address);
    }

    function removeStakeHolder(address _address) public {
        (bool isStakeHolder, uint256 stakeHolderIndex) = _isStakeHolder(_address);
        require(isStakeHolder, "Not a Stake Holder");
        delete stakeHolders[stakeHolderIndex];
    }

    function stakeOf(address _stakeHolder) public view returns (uint256 stake) {
        return stakes[_stakeHolder];
    }

    function getTotalStakes() public view returns (uint256 totalStakes) {
        uint256 _totalStakes = 0;
        for (uint256 i = 0; i < stakeHolders.length; i++) {
            _totalStakes = _totalStakes.add(stakes[stakeHolders[i]]);
        }
        return _totalStakes;
    }

    function createStake(uint256 _stake) public {
        _burn(msg.sender, _stake);
        if (stakes[msg.sender] == 0) addStakeHolder(msg.sender);
        stakes[msg.sender].add(_stake);
    }

    function removeStake(uint256 _stake) public {
        stakes[msg.sender].sub(_stake);
        if (stakes[msg.sender] == 0) removeStakeHolder(msg.sender);
        _mint(msg.sender, _stake);
    }

    function rewardOf(address _stakeHolder) public view returns (uint256) {
        return rewards[_stakeHolder];
    }

    function totalRewards() public view returns (uint256) {
        uint256 _totalRewards = 0;
        for (uint256 i = 0; i < stakeHolders.length; i++) {
            _totalRewards = _totalRewards.add(rewards[stakeHolders[i]]);
        }
        return _totalRewards;
    }

    function calculateRewards(address _stakeHolder) public view returns (uint256) {
        return stakes[_stakeHolder] / 100;
    }

    function distributeRewards() public onlyOwner {
        for (uint256 i = 0; i < stakeHolders.length; i++) {
            address stakeHolder = stakeHolders[i];
            uint256 reward = calculateRewards(stakeHolder);
            rewards[stakeHolder] = rewards[stakeHolder].add(reward);
        }
    }

    function withdrawReward() public {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }
}