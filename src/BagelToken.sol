// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BagelToken is ERC20, Ownable{
    // This contract will implement the ERC20 token standard.
    // The initial supply will be managed by the owner minting tokens as needed,
    // rather than minting a fixed supply at deployment.
    constructor() ERC20("Bagel", "BAGEL") Ownable(msg.sender){}

    function mint(address to, uint256 amount) external onlyOwner{
        _mint(to, amount);
    }
}