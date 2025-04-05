# Vault6551: Cross-chain NFT Vault with ERC-6551 and Wormhole

Vault6551 is a demonstration repository showcasing how to integrate ERC-6551 Token Bound Accounts (TBAs) with Wormhole to facilitate cross-chain NFT vaults and token staking, particularly bridging Ethereum (Sepolia testnet) and Solana (devnet/testnet).

```
[EVM TBA]
     │
     │ postMessage(payload)
     ▼
[Wormhole] ── Guardians verify ──▶ VAA generated
     │                              │
     │                              │ VAA
     ▼                              ▼
[Solana Anchor Program] ── parses VAA ──▶ creates PDA using TBA seed info
     │
     │
     ▼
[Solana PDA controlled by TBA]               
```


## Key Features

- **ERC-6551 Token Bound Accounts (TBAs):** Allow NFTs to act as wallets or vaults, holding other assets.
- **Cross-chain integration:** Utilize Wormhole for secure and verifiable cross-chain message passing and asset transfers.
- **Solana PDA integration:** Demonstrate how a TBA on Ethereum can control Program Derived Accounts (PDAs) on Solana.
- **Token staking on Solana:** Showcase how tokens can be staked via PDAs controlled by an Ethereum TBA.

## Architecture Overview

1. **ERC-6551 Token Bound Account:**
   - Deployed on Ethereum (Sepolia testnet).
   - Manages asset custody and control linked to NFTs.

2. **Wormhole Integration:**
   - Facilitates cross-chain messages and token transfers.
   - Utilizes VAA (Verifiable Action Approval) mechanism for secure communication.

3. **Solana Program Derived Account (PDA):**
   - Created dynamically on Solana (devnet/testnet) based on the Ethereum TBA seed.
   - Acts as a vault or staking contract controlled by Ethereum-based TBA.

## Getting Started

### Prerequisites

- [Anchor](https://www.anchor-lang.com/) framework
- [Solana CLI](https://docs.solana.com/cli/install-solana-cli-tools)
- [Wormhole CLI](https://github.com/wormhole-foundation/wormhole-cli)
- [Foundry (Cast & Anvil)](https://book.getfoundry.sh/getting-started/installation)

### Installation

```bash
git clone <repository-url>
cd vault6551
npm install
cargo build
```

### Setup Environment

Configure your environment variables in `.env`:

```bash
PRIVATE_KEY=<Ethereum private key>
SEPOLIA_RPC_URL=<Sepolia RPC URL>
MY_WALLET_ADDRESS=<Ethereum wallet address>
ERC721_ADDRESS=<ERC-721 contract address>
REGISTRY_ADDRESS=<ERC-6551 registry address>
ACCOUNT_IMPL_ADDRESS=<ERC-6551 account implementation>
WORMHOLE_PORTAL=<Wormhole portal address>
WETH_ADDRESS=<WETH contract address>
SOLANA_CHAIN_ID=1
SOLANA_RECIPIENT_HEX=<Solana recipient address (hex)>
SOLANA_PRIVATE_KEY_JSON=<Path to Solana private key JSON>
```

## ORAKLE Academic Activities

This repository is part of my research and experiments conducted at ORAKLE blockchain research group, focusing on cross-chain interoperability.

## Contributing

Contributions are welcome! Please create a pull request or open an issue to discuss any improvements or ideas.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

