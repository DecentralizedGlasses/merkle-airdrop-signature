// SPDX- License-Identifer: MIT

pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script{
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;// from output.json
    uint256 private s_amountToTransfer = 4 *25 *1e18; // 4 users, 25 tokens each

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {  // core logic
        vm.startBroadcast();
        BagelToken token = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        // minting the BagelToken with that owner address
        token.mint(token.owner(), s_amountToTransfer); // minting tokens for airdrop
        // Transferring tokens from script deployer address to deployed MerkleAirdrop contract
        token.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, token);
    }
    function run() external returns(MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}