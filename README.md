# Merkle Airdrop

MerkleAirdrop is a smart contract that facilitates token airdrops using Merkle Trees and EIP-712 signatures. It allows users to claim a portion of an airdrop token by proving their inclusion in a Merkle Tree and providing a valid signature.

## Features

- **Merkle Proof**: Users can prove they are eligible for the airdrop using Merkle proofs.
- **Signature Verification**: Claims are verified with EIP-712 structured signatures to ensure security.
- **Token Airdrop**: Eligible users receive tokens (ERC-20) after successfully proving their inclusion and validity.

## How It Works

1. **Merkle Tree**: The contract uses a Merkle Tree where each leaf node represents an eligible participant and their airdrop amount.
2. **Claiming**: Users can claim their airdrop by providing:
   - Their address
   - The amount they are eligible to receive
   - A Merkle proof to prove inclusion in the tree
   - A valid signature from the contract owner or signer
3. **Security**: The contract ensures that each user can only claim once and that the signature matches the claim data.
