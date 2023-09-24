// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract StakeTOEarn is ERC20Pausable, Ownable{

    using Address for address payable;

    uint256 public salePrice = 0.01 ether;
    uint256 public totatlStaked = 0;

    mapping(address => uint256) public staked;
    mapping(address => uint256) public getBalance;


    constructor(uint256 _initialSupply) ERC20("Stack To Earn", "STE") {}

    function buyTokens(uint256 _amount, address _to) external payable {
        require(_to != address(0), "invalid to");
        require(msg.value * 100 == _amount, "wrong amount of ETH sent");

        _mint(_to, _amount);
    }

    // User can stake tokens earn rewards
    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0 Tokens");
        require(balanceOf(msg.sender) >= _amount, "Cannot stake more tokens than you hold unstaked");

        staked[msg.sender] += _amount;
        totatlStaked += _amount;
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