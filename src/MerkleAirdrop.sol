// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    // This directive attaches the functions from SafeERC20 (like safeTransfer) to any variable of type IERC20
    using SafeERC20 for IERC20; // this means we can call any variables of this type
    // Purpose:
    // 1. Manage a list of addresses and corresponding token amounts eligible for the airdrop.
    // 2. Provide a mechanism for eligible users to claim their allocated tokens.

    // Errors
    error MerkleAirdrop__InalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    // State Variable
    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer=> bool claimed) private s_hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    // Events
    event Claim(address indexed account, uint256 amount);

    
    constructor (bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1"){
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }
    // address of the account they want to claim
    // amount of tokens they want to claim
    // an array which containing merklrProofs like intermediate hashes to calculate the root 
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external{
        if(s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // check the signature, if the signature is not valid return a custom error
        if(!_isValidSignature(account, getMessageHash(account, amount), v,r,s)) {
            revert MerkleAirdrop__InvalidSignature();
        }
        // calculate using the account and the amount, the hash -> leaf node
        // 1. Calculate the leaf node hash
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account,amount))));

         // 2. Verify the Merkle Proof
        if(!MerkleProof.verify(merkleProof,i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InalidProof();
        }
        s_hasClaimed[account] = true;
        // 3. Emit event
        emit Claim(account, amount); //Logging Claims with events

        // 4. Transfer tokens
        i_airdropToken.safeTransfer(account, amount);
        
    }

    // function to get message digest
    function getMessageHash(address account, uint256 amount) public view returns(bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount})))
        );
    }
    function getMerkleRoot() external view returns(bytes32) {
        return i_merkleRoot;
    }

    
    function getAirdropToken() external view returns(IERC20) {
        return i_airdropToken;
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns(bool) {
        ( address actualSigner , , ) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;

    }
}