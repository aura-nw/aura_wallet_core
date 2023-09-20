import 'package:alan/alan.dart';
import 'src/aura_internal_wallet_ipml.dart';
import 'src/core/type_data/aura_type_data.dart';

export 'src/core/type_data/aura_type_data.dart';
export 'src/core/exceptions/aura_internal_exception.dart';
export 'package:alan/alan.dart';

enum AuraWalletCoreEnvironment {
  mainNet,
  euphoria,
  testNet,
}

///
/// An in-app wallet that allows you to perform various operations related to the blockchain, such as creating a wallet, restoring a wallet, checking the balance, sending transactions, and checking transaction history.
///
/// {@category InAppWallet}
abstract class AuraWalletCore {
  factory AuraWalletCore.create(
      {required AuraWalletCoreEnvironment environment}) {
    return AuraWalletCoreImpl(environment: environment);
  }

  ///
  /// Create new random HDWallet
  ///
  ///
  /// {@category InAppWallet}
  Future<AuraFullInfoWallet> createRandomHDWallet();

  ///
  /// Restore HDWallet from mnemonic
  ///
  Future<AuraWallet> restoreHDWallet({required String key});

  ///
  /// Load current HDWallet from keychain or keystore
  ///
  Future<AuraWallet?> loadCurrentWallet();
}

abstract class AuraWallet {
  final Wallet wallet;
  final AuraWalletCoreEnvironment environment;

  const AuraWallet({
    required this.wallet,
    required this.environment,
  });

  ///
  /// Create a new transaction and sign it
  ///
  Future<Tx> makeTransaction({
    required String toAddress,
    required String amount,
    required String fee,
    String? memo,
  });

  ///
  /// Send the transaction to Aura network
  ///
  Future<bool> submitTransaction({required Tx signedTransaction});

  ///
  /// Check balance value of an address
  ///
  Future<String> checkWalletBalance();

  ///
  /// Get List Transaction of an address
  ///
  Future<List<AuraTransaction>> checkWalletHistory();

  ///
  /// Return response data corresponding query
  ///
  Future<String> makeInteractiveQuerySmartContract({
    required String contractAddress,
    required Map<String, dynamic> query,
  });

  ///
  /// Return TxHash code corresponding execute message
  ///
  Future<String> makeInteractiveWriteSmartContract({
    required String contractAddress,
    required Map<String, dynamic> executeMessage,
    List<int>? funds,
    int? fee,
  });

  ///
  /// Verify status execute contract from txHash
  ///
  Future<bool> verifyTxHash({
    required String txHash,
  });

  ///
  /// Return mnemonic of user
  ///
  Future<String?> getCurrentMnemonicOrPrivateKey();

  Future<bool> removeCurrentWallet();
}

abstract class AuraFullInfoWallet {
  final String mnemonic;
  final String privateKey;
  final AuraWallet auraWallet;

  AuraFullInfoWallet({
    required this.mnemonic,
    required this.privateKey,
    required this.auraWallet,
  });
}
