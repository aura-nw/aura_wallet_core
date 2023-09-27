
# Aura Wallet Core

Aura Wallet Core is a library designed to simplify the creation and management of Aura cryptocurrency wallets within your application. This library provides an abstract interface for creating, restoring, and managing Aura cryptocurrency wallets, allowing for seamless integration into your projects.

## Table of Contents

- [Aura Wallet Core](#aura-wallet-core)
  - [Table of Contents](#table-of-contents)
  - [Roadmap](#roadmap)
  - [Getting Started](#getting-started)
  - [Basic Usage](#basic-usage)
    - [Creating a New Aura Wallet](#creating-a-new-aura-wallet)
    - [Restoring an Aura Wallet](#restoring-an-aura-wallet)
    - [Loading a Stored Aura Wallet](#loading-a-stored-aura-wallet)
    - [Removing an Aura Wallet](#removing-an-aura-wallet)
    - [Using the Aura Wallet](#using-the-aura-wallet)
      - [Creating a Transaction](#creating-a-transaction)
      - [Submitting a Transaction](#submitting-a-transaction)
      - [Checking Wallet Balance](#checking-wallet-balance)
      - [Checking Wallet Transaction History](#checking-wallet-transaction-history)
      - [Querying Smart Contracts](#querying-smart-contracts)
      - [Verifying Transaction Status](#verifying-transaction-status)
      - [Getting Wallet Passphrase](#getting-wallet-passphrase)
  - [Documentation](#documentation)
  - [Issues and Feedback](#issues-and-feedback)
  - [License](#license)

## Roadmap

- [x] Create HDWallet
- [x] Restore HDWallet
- [x] Check Wallet Balance
- [x] Check Wallet History
- [x] Make(Sign) / Send transaction
- [ ] Option for secure storage with Biometric Authentication

## Getting Started

To begin using Aura Wallet Core in your project, follow these steps:

1. Add `aura_wallet_core` to your project's dependencies by adding the following line to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     aura_wallet_core: ^latest_version
   ```

2. Run the `flutter pub get` command to install the library.

## Basic Usage

### Creating a New Aura Wallet

```dart
import 'package:aura_wallet_core/aura_wallet_core.dart';

final AuraWalletCore auraWalletCore = AuraWalletCore.create(
  environment: AuraWalletCoreEnvironment.production,
  biometricOptions: BiometricOptions(
    requestTitle: 'Authenticate',
    requestSubtitle: 'Use your fingerprint to access your wallet',
    authenticationTimeOut: 10, // 10 seconds timeout
  ),
  ConfigOption : ConfigOption(isEnableLog : true),
);

final comprehensiveWallet = await auraWalletCore.createRandomHDWallet();
```

### Restoring an Aura Wallet

```dart
final passPhrase = "your_recovery_passphrase";

final wallet = await walletCore.restoreHDWallet(
  passPhrase: passPhrase,
  walletName: "my_aura_wallet", // Optional wallet name
);
```

### Loading a Stored Aura Wallet

```dart
final walletName = "my_aura_wallet"; // Optional wallet name

final wallet = await walletCore.loadStoredWallet(
  walletName: walletName,
);

if (wallet != null) {
  // Wallet loaded successfully
} else {
  // Wallet not found
}
```

### Removing an Aura Wallet

```dart
final walletName = "my_aura_wallet"; // Optional wallet name

await walletCore.removeWallet(
  walletName: walletName,
);
```

### Using the Aura Wallet

With the `AuraWallet` instance obtained from Aura Wallet Core, you can perform various wallet-related operations, such as creating transactions, checking balances, and more.

#### Creating a Transaction

You can create a new transaction and sign it using the `makeTransaction` method. Provide the recipient's address, amount, and fee. You can also include an optional memo:

```dart
final Tx transaction = await auraWallet.makeTransaction(
  toAddress: 'recipient_address',
  amount: '100 AURA', // The amount to send.
  fee: '1 AURA', // Transaction fee.
  memo: 'Optional memo', // Optional memo field.
);
```

#### Submitting a Transaction

Once you've created a transaction, you can submit it to the Aura network using the `submitTransaction` method. Pass the signed transaction obtained in the previous step:

```dart
final bool isTransactionSuccessful = await auraWallet.submitTransaction(
  signedTransaction: transaction,
);
```

#### Checking Wallet Balance

To check the balance of your wallet, use the `checkWalletBalance` method:

```dart
final String balance = await auraWallet.checkWalletBalance();
```

#### Checking Wallet Transaction History

You can retrieve the transaction history of your wallet with the `checkWalletHistory` method, which returns a list of `AuraTransaction` objects:

```dart
final List<AuraTransaction> transactionHistory = await auraWallet.checkWalletHistory();
```

#### Querying Smart Contracts

With Aura Wallet, you can interact with smart contracts on the Aura network. Use the following methods to make interactive queries and execute smart contracts:

- `makeInteractiveQuerySmartContract`: Make an interactive query to a smart contract by providing the contract address and a query map.

- `makeInteractiveWriteSmartContract`: Execute a smart contract by providing the contract address, an execution message, and optional funds and fees.

#### Verifying Transaction Status

You can verify the status of a contract execution by providing its transaction hash using the `verifyTxHash` method:

```dart
final bool isTransactionSuccessful = await auraWallet.verifyTxHash(
  txHash: 'transaction_hash',
);
```

#### Getting Wallet Passphrase

To retrieve the mnemonic passphrase of the wallet user, use the `getWalletPassPhrase` method. This can be useful for certain operations requiring user authorization.

```dart
final String? mnemonicPassphrase = await auraWallet.getWalletPassPhrase();
```

## Documentation

For detailed documentation and examples, please visit the [library's documentation on pub.dev](https://pub.dev/packages/aura_wallet_core).

## Issues and Feedback

Please report any issues or provide feedback on [GitHub](https://github.com/aura-nw/aura-wallet-core).

## License

This library is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
