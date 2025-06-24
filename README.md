
# Drosera Trap SERGEANT (Level 3) — Proof of Concept (PoC) for a Unique Trap

## Objective

Create a working prototype of a unique trap (Trap) that:

* Has a technical implementation (code, logic),
* Solves a real problem or covers a specific use case (e.g., monitoring governance attacks, liquidity, access rights, etc.),
* Can potentially be used by others.

This PoC can include:

* A Solidity contract with the trap logic,
* A description of the problem it solves,
* Deployment and testing instructions,
* Example scenarios where it can be useful.

---

## Idea: Gas Spike Trap — Monitoring Suspicious Transactions with High Gas Fees

### Problem

Blockchain networks often experience attacks or manipulations accompanied by sudden spikes in transaction fees (gas price) — for example, to prioritize their transactions, perform front-running, or execute MEV (Maximal Extractable Value) attacks. These spikes may indicate attempts of manipulation or protocol attacks.

### Goal of the Trap

Automatically monitor sudden spikes in gas prices in transactions related to your project or address and alert about suspicious activities.

---

## Technical Implementation (PoC in Solidity)

```solidity
//24.06.2025
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract GasSpikeTrap is ITrap {
    uint256 public constant GAS_PRICE_THRESHOLD = 200 gwei; // 200 Gwei

    // This is called on every block over the shadow fork
    function collect() external view override returns (bytes memory) {
        // Collect current block basefee (gas price)
        return abi.encode(block.basefee);
    }

    // This is called with the output of collect() over a range of blocks
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length == 0) return (false, bytes(""));

        uint256 latestGasPrice = abi.decode(data[0], (uint256));

        // Hardcode the threshold here since this is a pure function
        if (latestGasPrice >= 200 gwei) {
            return (true, abi.encode("Gas price spike detected"));
        }
        return (false, bytes(""));
    }
}
```

### Contract address

`0x1a73368ae06d541855f523c1ed887e4e53370b47`

---

## What It Solves

* Enables timely reaction to attacks involving gas price spikes, which can lead to front-running or other manipulations.
* Helps Drosera operators and protocol developers monitor suspicious activities on the network.
* Universally applicable to any project where transaction stability and security matter.

---

## Deployment and Testing Instructions

1. Deploy the contract on a test network (e.g., Holesky).
2. Configure a Drosera operator to provide real gasPrice data in the `collect` function.
3. Simulate transactions with varying gas prices and verify trap activation.
4. Monitor emitted events and trap status via the Drosera dashboard.

---

## Example Use Cases

* Monitoring DeFi protocols for MEV and front-running attacks.
* Controlling transactions from critical addresses (wallets, contracts).
* Increasing security and resilience of decentralized applications.

---

## Next Steps

### Step 1: Configure Drosera Operator to Monitor the Trap

* Install and run the Drosera operator node if not done yet.
* In the operator config, specify your trap contract address and methods for data collection (`collect`) and decision making (`shouldRespond`).
* Set up the operator to feed real transaction gasPrice data (via RPC node on Holesky or similar).

### Step 2: Test in Real Conditions

* Perform several transactions with different gas prices on the testnet.
* Ensure the operator collects data and calls `shouldRespond` correctly.
* Verify that trap triggers and generates alerts when threshold exceeded.

### Step 3: Integrate with Drosera Dashboard

* Add the trap to the [Drosera dashboard](https://app.drosera.io/network) for monitoring.
* Track trigger statistics, logs, and operator actions.
* Set up notifications or automatic responses if needed.

### Step 4: Improve and Extend Functionality

* Add a function to update gas price threshold dynamically (e.g., `setThreshold`).
* Collect and analyze additional transaction parameters (sender address, gas used, etc.).
* Integrate with oracles for external data or more complex scenarios.

### Step 5: Document and Share

* Write clear documentation explaining the trap’s purpose, functionality, and deployment steps.
* Share the trap with the community for potential adoption.

---

![image](https://github.com/user-attachments/assets/d5148875-5fa4-4eb7-ba27-df6b7dcdf618)

