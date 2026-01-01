# Merkle Airdrop (Foundry)

A **gas-efficient, verifiable token airdrop system** built using **Merkle Trees** and **Foundry**, designed for distributing ERC20 tokens to a predefined set of addresses without storing the entire recipient list on-chain.

This project demonstrates how modern token airdrops are implemented in production systems using **cryptographic proofs** instead of large on-chain datasets.

---

## 🚀 Introduction

Traditional airdrops require storing every eligible address on-chain, which is expensive and inefficient.

This project solves that by:
- Storing **only a Merkle Root** on-chain
- Allowing users to **prove eligibility** using a Merkle Proof
- Enabling **trustless, permissionless claiming**
- Preventing **double-claims**

It is ideal for **DAO launches, protocol incentives, community rewards, and token distributions**.

---

## 🎯 Use Cases

This system can be used for:

- 🪂 **Token airdrops** (early users, NFT holders, DAO members)
- 🏛 **DAO governance token distribution**
- 🎁 **Reward programs** (contributors, bug bounties)
- 🧪 **Testnet incentives**
- 🔐 **Whitelisted minting / claiming systems**
- 💰 **Gas-efficient mass payouts**

---

## 🧠 How It Works (High Level)

1. A list of eligible addresses and claim amounts is prepared off-chain
2. A **Merkle Tree** is generated from this data
3. The **Merkle Root** is deployed on-chain
4. Users submit:
   - Their address
   - Their claim amount
   - A Merkle Proof
5. The contract:
   - Verifies the proof
   - Checks claim status
   - Transfers tokens
   - Marks the user as claimed

---

## 🏗️ Architecture Overview

┌──────────────────────────┐
│ Address + Amount List    │
│ (Eligible recipients)   │
└───────────┬──────────────┘
            │
            ▼
      Merkle Tree
            │
            ▼
        Merkle Root
┌────────────────────────────────┐
│ MerkleAirdrop Contract         │
│                                │
│ • verifyProof()                │
│ • claim()                      │
└────────────────────────────────┘



---

## 📂 Project Structure

foundry-merkle-airdrop-cu/
├── src/
│ ├── MerkleAirdrop.sol
│ └── Token.sol
│
├── script/
│ ├── Deploy.s.sol
│ └── Claim.s.sol
│
├── test/
│ └── MerkleAirdrop.t.sol
│
├── lib/
├── foundry.toml
└── README.md



---

## ⚙️ Prerequisites

- **Foundry**
- Node.js (for generating Merkle trees)
- A funded wallet for deployment

Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## 🧪 Local Development & Testing

### Install Dependencies

```bash
forge install
```

### Run Tests
```bash
forge test
```

### Run Tests with Detailed Logs
```bash
forge test -vvvv
```

## 🚀 Deploying Locally (Anvil)
#### Start local chain:
```bash
anvil
```

#### Deploy contracts:
```bash
forge script script/Deploy.s.sol \
  --rpc-url http://127.0.0.1:8545 \
  --private-key <PRIVATE_KEY> \
  --broadcast
```

## 🌍 Deploying to Testnets / Mainnets
#### Example: Sepolia
```bash
forge script script/Deploy.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --account deployer \
  --broadcast \
  --verify
```

#### Example: Base Sepolia
```bash 
forge script script/Deploy.s.sol \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --account deployer \
  --broadcast
```

#### Example: Ethereum Mainnet
```bash 
forge script script/Deploy.s.sol \
  --rpc-url $MAINNET_RPC_URL \
  --account deployer \
  --broadcast
```

### 🪂 Claiming Tokens
Users can claim tokens by calling claim() with:
- Address
- Amount
- Merkle Proof
#### Example using Foundry script
```bash
forge script script/Claim.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --account user \
  --broadcast
```

## 🔐 Security Properties

✅ No on-chain whitelist storage
✅ Cryptographic proof verification
✅ Double-claim protection
✅ Deterministic and auditable
✅ Gas-efficient

## ⚠️ Common Failure Cases

| Error                  | Meaning                     |
| ---------------------- | --------------------------- |
| `Invalid proof`        | User not in Merkle tree     |
| `Already claimed`      | Duplicate claim attempt     |
| `Insufficient balance` | Airdrop contract not funded |
| `Invalid root`         | Incorrect Merkle root       |


### 📌 Customization

You can easily:

- Change token type
- Adjust claim logic
- Add expiration timestamps
- Add pause / emergency withdrawal
- Support NFTs instead of ERC20


## 📚 Learning Outcomes

Things I learned in during this project:

- Merkle Trees & cryptographic proofs
- Gas optimization techniques
- Secure token distribution
- Foundry scripting & testing
- Production-grade airdrop design

## 👤 Author
DecentralizedGlasses(Sivaji)

## 📜 License

MIT License