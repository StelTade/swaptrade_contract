# 🤝 Contributing Guidelines

We welcome contributions from the community to improve this project! Please follow the steps below to ensure a smooth contribution process:

## 1. Fork & Clone

Fork the repository to your own GitHub account.

Clone your fork locally:

```bash
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>
```

## 2. Create a Branch

Use a descriptive branch name for your feature or fix:

```bash
git checkout -b feature/add-order-validation
```

## 3. Code Style

Follow the project’s coding style:

- **Solidity:** Use the [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html).
- **JavaScript/TypeScript:** Ensure code is formatted using [Prettier](https://prettier.io/) and linted with [ESLint](https://eslint.org/).

Run before committing:

```bash
npm run lint
npm run format
```

## 4. Commit Messages

Write clear, descriptive commit messages (preferably following [Conventional Commits](https://www.conventionalcommits.org/)):

```
feat: add swap order validation

fix: correct contract address in deployment script

docs: improve setup instructions in README
```

## 5. Run Tests

Ensure all tests pass locally before submitting a PR:

```bash
npx hardhat test
```

## 6. Submit a Pull Request (PR)

Push your branch and open a PR against the `main` branch.

Clearly describe the problem and solution in your PR description.

Reference related issues (e.g., `Closes #42`).

## 7. Code Review & Merge

All PRs will be reviewed by maintainers.

Address review comments promptly.

Once approved, the PR will be merged.

## 8. Reporting Issues

Use the [Issues tab](https://github.com/StelTade/swaptrade_contract/issues) to report bugs or request features.

Please include reproduction steps, logs, or screenshots for bugs.
