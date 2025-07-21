// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MockUSDCWithMint is ERC20, ERC20Permit {
    constructor() ERC20("Mock USDC", "MockUSDC") ERC20Permit("MockUSDC") {
        _mint(msg.sender, 1_000_000_000 * 1e18);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}