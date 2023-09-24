// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract StakeTOEarn is ERC20Pausable, Ownable{

    using Address for address payable;

    uint256 public salePrice = 0.01 ether;
    uint256 public totatlStaked = 0;
    uint256 public userBalance = 0;

    // Mapping of User who staked and the amount of tokens staked
    mapping(address => mapping(address => UserStake)) public userStakes;

    constructor(uint256 _initialSupply) ERC20("Stack To Earn", "STE") {}

    function buyTokens(uint256 _amount, address _to) external payable {
        require(_to != address(0), "invalid to");
        require(msg.value * 100 == _amount, "wrong amount of ETH sent");

        _mint(_to, _amount);
    }

//   function createIncentive(
//         address token,
//         address rewardToken,
//         uint112 rewardAmount,
//         uint32 startTime,
//         uint32 endTime
//     ) external nonReentrant returns (uint256 incentiveId) {

//         if (rewardAmount <= 0) revert InvalidInput();

//         if (startTime < block.timestamp) startTime = uint32(block.timestamp);

//         if (startTime >= endTime) revert InvalidTimeFrame();

//         unchecked { incentiveId = ++incentiveCount; }

//         if (incentiveId > type(uint24).max) revert IncentiveOverflow();

//         _saferTransferFrom(rewardToken, rewardAmount);

//         incentives[incentiveId] = Incentive({
//             creator: msg.sender,
//             token: token,
//             rewardToken: rewardToken,
//             lastRewardTime: startTime,
//             endTime: endTime,
//             rewardRemaining: rewardAmount,
//             liquidityStaked: 0,
//             // Initial value of rewardPerLiquidity can be arbitrarily set to a non-zero value.
//             rewardPerLiquidity: type(uint256).max / 2
//         });

//         emit IncentiveCreated(token, rewardToken, msg.sender, incentiveId, rewardAmount, startTime, endTime);

//     }

    function stakeToken(address token, uint256 amount) public nonReentrant {

        _saferTransferFrom(token, amount);

        UserStake storage userStake = userStakes[msg.sender][token];

        uint112 previousLiquidity = userStake.liquidity;

        userStake.liquidity += amount;

    }

    function unstakeToken(address token, uint112 amount, bool transferExistingRewards) external nonReentrant {

        UserStake storage userStake = userStakes[msg.sender][token];

        uint112 previousLiquidity = userStake.liquidity;

        if (amount > previousLiquidity) revert InsufficientStakedAmount();

        userStake.liquidity -= amount;

        uint256 n = userStake.subscribedIncentiveIds.countStoredUint24Values();

        ERC20(token).safeTransfer(msg.sender, amount);

        emit Unstake(token, msg.sender, amount);

    }

    function pause(bool state) external onlyOwner {
        if (state) {
            Pausable._pause();
        } else {
            Pausable._unpause();
        }
    }

    function withdraw() external onlyOwner {
        payable(owner()).sendValue(address(this).balance);
    }
}