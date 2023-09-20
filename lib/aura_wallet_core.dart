import 'src/aura_internal_wallet_ipml.dart';
import 'src/entities/aura_wallet.dart';
import 'src/env/env.dart';

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

  void dispose() {}
}
