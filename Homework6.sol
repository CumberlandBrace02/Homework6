// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TokenVesting is Ownable {
    using SafeMath for uint256;

    IERC20 public token;
    address public beneficiary;
    uint256 public cliff;
    uint256 public start;
    uint256 public duration;
    uint256 public released;

    event TokensReleased(uint256 amount);

    constructor(
        IERC20 _token,
        address _beneficiary,
        uint256 _start,
        uint256 _cliffDuration,
        uint256 _duration
    ) {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_cliffDuration <= _duration, "Cliff duration must be less than or equal to the vesting duration");

        token = _token;
        beneficiary = _beneficiary;
        start = _start;
        cliff = _start.add(_cliffDuration);
        duration = _duration;
    }
function release() external {
        require(block.timestamp >= cliff, "Tokens are still in cliff period");
        require(block.timestamp >= start, "Vesting has not started");
        require(!isVestingComplete(), "Vesting is already complete");

        uint256 unreleased = releasableAmount();
        require(unreleased > 0, "No tokens to release");

        released = released.add(unreleased);
        token.transfer(beneficiary, unreleased);

        emit TokensReleased(unreleased);
    }
function releasableAmount() public view returns (uint256) {
        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration) || isVestingComplete()) {
            return token.balanceOf(address(this));
        } else {
            return totalVestedAmount().mul(block.timestamp.sub(start)).div(duration).sub(released);
        }
    }

}

