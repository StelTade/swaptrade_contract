# SwapTrade Contract

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Ecosystem: Cairo](https://img.shields.io/badge/Tool-Cairo-orange.svg)](https://www.cairo-lang.org/)
[![Status](https://img.shields.io/badge/status-active-green.svg)]()

> **Secure • Transparent • Decentralized Trading — On StarkNet** 🚀

---

## Introduction

**SwapTrade** is a Cairo-based smart contract suite for **StarkNet** that implements **atomic swaps**, **order placement**/**matching**, and **settlement** primitives for decentralized trading. It is designed to facilitate **secure, transparent, and trustless asset swaps** without the need for centralized intermediaries.

This repository contains the on-chain Cairo contracts, type definitions, helper libraries, and Cairo unit tests used to build and verify **SwapTrade**. It is intended for smart contract developers, security auditors, integrators (front-ends, relayers, bots), and researchers exploring decentralized trading primitives. See `Scarb.toml` for the Cairo project configuration.

### Purpose

- Empower developers and users to execute token swaps directly on-chain.
- Eliminate reliance on centralized exchanges, reducing risks of censorship or manipulation.
- Build a foundation for scalable, modular DeFi applications.

### Why Transparent & Decentralized Trading Matters

- **Transparency:** Every transaction is verifiable on-chain, ensuring trust in the system.
- **Security:** Immutable smart contracts enforce execution rules automatically.
- **Accessibility:** Anyone with a blockchain wallet can participate globally.
- **Fairness:** Removes control from central authorities, ensuring equal participation opportunities.

---

## ✨ Features

| Feature                        | Description                                                                      | Why It Matters                                                 |
| ------------------------------ | -------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| **🔒 Secure Trading**          | On-chain verification guarantees trades execute only if both conditions are met. | Protects participants against fraud and double-spending.       |
| **🌐 Fully Decentralized**     | Trades are validated by the StarkNet network, not by intermediaries.             | Reduces censorship and central points of failure.              |
| **⚙️ Customizable Contracts**  | Developers can configure trading pairs, execution rules, and fees.               | Flexible for different DeFi protocols and liquidity providers. |
| **📈 Scalable Architecture**   | Optimized to handle high transaction volumes with minimal overhead.              | Ensures stability during market surges.                        |
| **🛡 Security-Oriented Design** | Includes protections against reentrancy and invalid input manipulation.          | Enhances contract resilience and reliability.                  |
| **📜 Transparency**            | All trades, cancellations, and events are logged publicly on-chain.              | Facilitates independent auditing and builds trust.             |

---

## 🛠 Installation & Setup

### 1. Prerequisites

Make sure your system has the following installed:

- [Node.js](https://nodejs.org) (v16 or higher)
- [npm](https://npmjs.com) or [Yarn](https://yarnpkg.com)
- [Scarb](https://docs.swmansion.com/scarb/) (for Cairo 1)
- [Python 3.9+](https://www.python.org/) (for optional Python examples)
- Optional: [Docker](https://docker.com)

### 2. Clone Repository

```bash
git clone https://github.com/your-org/swaptrade_contract.git
cd swaptrade_contract
```

### 3. Install Dependencies (JS & Cairo)

```bash
npm install
# or
yarn install
```

For Python users:

```bash
pip install starknet-py
```

### 4. Configure Environment Variables

```bash
cp .env.example .env
```

Example `.env.example`:

```
RPC_URL=https://starknet-goerli.infura.io/v3/your-key
PRIVATE_KEY=0x...
ETHERSCAN_API_KEY=...
```

### 5. Compile Contracts

```bash
scarb build
```

### 6. Run Tests

```bash
scarb test
```

### 7. Deploy Contracts

```bash
npx starknet deploy --contract target/dev/swaptrade_Contract.sierra.json
```

---

## ⚡ Usage

### Cairo (StarkNet CLI / starkli)

> Use the Cairo/StarkNet toolchain directly from the CLI. Great for quick verification and scripts.

**Prerequisites**: `scarb` (build artifacts), StarkNet CLI (`starknet`) or [`starkli`](https://github.com/xJonathanLEI/starkli), a running devnet or testnet RPC.

**Artifacts** (after `scarb build`):

- Sierra: `target/dev/SwapTrade.sierra.json`
- ABI: `target/dev/SwapTrade_abi.json`

**1) Read a view (owner)**

```bash
export CONTRACT=0xCONTRACT_ADDRESS
starknet call \
  --address $CONTRACT \
  --abi target/dev/SwapTrade_abi.json \
  --function owner \
  --network alpha-goerli
```

**2) Create an order (invoke)**

```bash
starknet invoke \
  --address $CONTRACT \
  --abi target/dev/SwapTrade_abi.json \
  --function createOrder \
  --inputs 0xTOKEN_A 0xTOKEN_B 100000000000000000000 1500000000000000000 1735689600 \
  --max_fee 1500000000000000 \
  --network alpha-goerli
```

**3) Check tx status / events**

```bash
starknet tx_status --hash 0xTX_HASH --network alpha-goerli
```

**Local devnet**: add `--gateway_url http://127.0.0.1:5050` and `--feeder_gateway_url http://127.0.0.1:5050` instead of `--network`.

---

### Cairo (CLI Interaction)

#### 1. Call a view function

```bash
starknet call \
  --address 0xCONTRACT_ADDRESS \
  --abi ./artifacts/SwapTrade_abi.json \
  --function owner
```

#### 2. Create an order

```bash
starknet invoke \
  --address 0xCONTRACT_ADDRESS \
  --abi ./artifacts/SwapTrade_abi.json \
  --function createOrder \
  --inputs <tokenA> <tokenB> <amountOut> <price> <expiry>
```

#### 3. Cancel an order

```bash
starknet invoke \
  --address 0xCONTRACT_ADDRESS \
  --abi ./artifacts/SwapTrade_abi.json \
  --function cancelOrder \
  --inputs 1
```

---

### JavaScript Examples (starknet.js)

#### Read Contract

```js
import { Provider, Contract } from "starknet";
import abi from "./SwapTrade_abi.json";

const provider = new Provider({ sequencer: { network: "goerli-alpha" } });
const contract = new Contract(abi, "0xCONTRACT_ADDRESS", provider);

const owner = await contract.owner();
console.log("Owner:", owner);
```

#### Create Order

```js
const tx = await contract.createOrder(tokenA, tokenB, 1000, 10, 999999);
await tx.wait();
```

---

### Python Examples (starknet-py)

#### Read Contract

```python
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.contract import Contract

client = GatewayClient("https://alpha4.starknet.io")
contract = await Contract.from_address(
    address="0xCONTRACT_ADDRESS",
    client=client,
    abi=open("./SwapTrade_abi.json").read()
)

owner = await contract.functions["owner"].call()
print("Owner:", owner)
```

#### Create Order

```python
tx = await contract.functions["createOrder"].invoke(
    tokenA,
    tokenB,
    1000,
    10,
    999999,
    max_fee=int(1e16)
)
print("Transaction Hash:", tx.hash)
```

---

## 🤝 Contributing

We welcome all contributions! Here’s how:

### 📌 Steps to Contribute

1. **Fork** the repository.
2. **Create a branch**:
   ```bash
   git checkout -b feature/<name>
   ```
3. **Make changes** → follow coding standards.
4. **Write tests** for your feature.
5. **Commit** using [Conventional Commits](https://www.conventionalcommits.org/).
6. **Push** branch & open a Pull Request(**PR**).

### 🔑 Guidelines

- Cairo code: follow StarkNet/Cairo best practices.
- JavaScript: lint with ESLint + Prettier.
- Python: follow PEP8 and use `black` for formatting.
- Respect the [Code of Conduct](CODE_OF_CONDUCT.md).
- Read more about the contributing guidelines [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 🧪 Testing

Rigorous tests ensure correctness, security, and upgrade safety. SwapTrade is **Cairo-first**, with optional JS/Python testing for integration layers.

### Cairo (Primary)

- **Tooling**: `scarb test` (Cairo 1 built-in test runner)
- **Location**: Tests live alongside modules or under `tests/` in Cairo 1

**Run all tests**

```bash
scarb test
```

**Sample Cairo 1 test** (illustrative — align names with your ABI/module):

```rust
// src/swaptrade.cairo
#[starknet::contract]
mod SwapTrade {
    // ... contract storage & entrypoints ...

    #[event]
    fn OrderCreated(order_id: felt252, maker: felt252) {}

    // #[external] fn createOrder(...)

    #[cfg(test)]
    mod tests {
        use super::*;
        use starknet::testing;

        #[test]
        fn create_order_emits_event() {
            // Arrange: fresh state + deployed contract
            let mut state = testing::State::default();
            let contract = SwapTrade::deploy(&mut state);

            // Act: create order (example args)
            let _ = contract.createOrder(0x1, 0x2, 100.into(), 1_500_000_000_000_000.into(), 1_735_689_600.into());

            // Assert: event emitted (pseudo — adapt to your event API)
            // testing::assert_event_emitted::<OrderCreated>(&state, |e| e.order_id == 1.into());
        }
    }
}
```

**Best practices**

- ✅ Cover success & failure paths (invalid inputs, expired orders, insufficient balance)
- ✅ Assert events & state transitions
- ✅ Use fixtures/helpers to avoid repetitive setup
- ✅ Keep tests deterministic; avoid timestamp drift

**Troubleshooting**

- `scarb: command not found` → install Scarb
- Tests can’t find ABI/Sierra → run `scarb build` first
- Very slow tests → consolidate setup into fixtures/helpers

---

### JavaScript (Optional Integration – Hardhat)

**Install**

```bash
npm install --save-dev hardhat
```

**Run**

```bash
npx hardhat test
```

**Example**

```js
it("should create an order", async () => {
  const Swap = await ethers.getContractFactory("SwapTrade");
  const swap = await Swap.deploy();
  await swap.deployed();
  const tx = await swap.createOrder(tokenA, tokenB, 1000, 10, 999999);
  await tx.wait();
  const orders = await swap.getActiveOrders();
  expect(orders.length).to.be.greaterThan(0);
});
```

---

### Python (Optional Integration – pytest + starknet-py)

**Install**

```bash
pip install pytest pytest-asyncio starknet-py
```

**Run**

```bash
pytest tests/
```

**Example**

```python
import pytest

@pytest.mark.asyncio
async def test_create_order(contract):
    tx = await contract.functions["createOrder"].invoke(
        tokenA, tokenB, 1000, 10, 999999, max_fee=int(1e16)
    )
    await tx.wait_for_acceptance()
    orders = await contract.functions["getActiveOrders"].call()
    assert len(orders) > 0
```

---

## 🔒 Security & Auditing & Auditing

- Contracts are designed with **reentrancy protection** and **access control**.
- Vulnerability reports: send to **support@swaptrade.com**.
- Audits are recommended before mainnet deployment.

---

## FAQ

- Compilation errors (Node / Hardhat)

  - Check your Node version:

    ```bash
    node -v
    # require v16+
    ```

  - Reinstall dependencies deterministically (CI) or when you don't need to change deps:

    ```bash
    npm ci
    ```

    If `npm ci` fails (lockfile mismatch), fall back to:

    ```bash
    rm -rf node_modules package-lock.json
    npm install
    ```

  - If Hardhat/Solidity compilation fails, verify the compiler settings in `hardhat.config.js` match your local solc version (optimizer and version).
  - Quick cleanup:

    ```bash
    npx hardhat clean
    ```

- Compilation errors (Cairo / Scarb)

  - Verify Scarb and Cairo tool versions:

    ```bash
    scarb --version
    # Check `cairo-version` in Scarb.toml and match local toolchain
    ```

  - Build and run tests:

    ```bash
    scarb build
    scarb test
    ```

  - If build errors reference missing deps or wrong Cairo version, update `Scarb.toml` or install the Cairo toolchain that matches the declared version.

- Out‑of‑gas in tests

  - Hardhat (increase gas limits in `hardhat.config.js`):

    ```js
    // hardhat.config.js
    module.exports = {
      networks: {
        hardhat: {
          gas: 12_000_000,
          blockGasLimit: 30_000_000,
        },
      },
    };
    ```

  - For flaky or expensive external calls: mock external services or stub heavy-path logic in unit tests.
  - When invoking via CLI / devnet, set a larger `--max_fee` or adjust account fee settings:

    ```bash
    starknet invoke --max_fee 2000000000000000 ...
    ```

- Etherscan / block explorer verification failures

  - Confirm you’re using the correct network and the deployed contract address.
  - Ensure the exact constructor arguments (order and types) are passed to the verify command:

    ```bash
    npx hardhat verify --network <network> <DEPLOYED_ADDRESS> "arg1" "arg2"
    ```

  - Match compiler settings: solc version, optimizer enabled/disabled, and optimizer runs must match the values used when compiling the deployed artifact.
  - If verification requires flattened source, use the official Hardhat verify plugin or a trusted flattener and confirm metadata (some explorers require exact byte-for-byte match).
  - Check verification logs for the expected error (constructor mismatch, solc mismatch, or metadata mismatch) and fix the corresponding setting.

- Quick troubleshooting checklist

  - Clear caches and rebuild:

    ```bash
    npm ci && npx hardhat clean && npm run compile
    scarb build   # for Cairo
    ```

  - Inspect verbose logs (Hardhat / scarb) and the ABI/class JSON in `target/dev/` or `artifacts/`.
  - Verify account signing and CLI version differences (`starknet` vs `starkli`) if CLI calls fail.

---

## 📜 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE).

- ✅ Free for personal & commercial use
- ✅ Modify and redistribute under same license
- ⚠️ No warranty provided

---

## 📩 Contact

- GitHub Issues → [Open an issue](https://github.com/StelTade/swaptrade_contract/issues)
- Email → support@swaptrade.com
- OnlyDust → [SwapTrade Project](https://app.onlydust.com/projects/swaptrade)

---
