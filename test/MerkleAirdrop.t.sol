// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test{
    MerkleAirdrop public airdrop;
    BagelToken public token;

    // ROOT value is derived from your code merkle tree generation script and this is same for every user
    // it will be updated later in process
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18; // Example claim amount of the test user
    // FUND the airdrop contract
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4; // Total tokens to fund the airdrop contract

    // these are the proof hashes generated in out output file
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address public gasPayer;
    address user;
    uint256 userPrivKey;

    function setUp() public {
        if(!isZkSyncChain()) { // This check is from ZkSyncChainChecker
            // deploy with script
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
             // Original manual deployment for ZKsync environments (or other specific cases)

            // Deploy ERC20 token and airdrop based on our ROOT and token
            token = new BagelToken();

            // Ensure 'ROOT' here is consistent with s_merkleRoot in the script
            // Deploy the Merkle airdrop contract
            // pass the Merkle ROOT and the address of the token contract
            airdrop = new MerkleAirdrop(ROOT, token);

            // Ensure 'AMOUNT_TO_SEND' here is consistent with s_amountToTransfer in the script
            // mint tokens to the owner
            token.mint(token.owner(), AMOUNT_TO_SEND);
            // transfer minted ERC20 tokens to the airdrop contract
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        
        // this will Generate a deterministic user 
        // This is crucial because we need to know the user address before 
        (user, userPrivKey) = makeAddrAndKey("user"); // this will create a address and key for that "user" string
        gasPayer = makeAddr("gasPayer"); // creating a gas payer address
    }

    function testUsersCanClaim() public {
        // 1. Get the user's starting token balance
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        // sign a message
        // 2. User signs the digest using their private key
        // vm.sign is a Foundry cheatcode 
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
        
        // gasPayer calls claim using the signed message
        // 3. call the claim function on the airdrop contract
        vm.prank(gasPayer); // he will send the gas amount and claims the amount on user address
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        // 4. Call the users ending token balance
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending Balance:", endingBalance);
        // assert that the balance increased by the expected claim amount
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}