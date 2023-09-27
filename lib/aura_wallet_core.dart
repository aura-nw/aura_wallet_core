library aura_wallet_core;

import 'package:aura_wallet_core/cores/aura_wallet/aura_wallet.dart';
import 'package:aura_wallet_core/src/constants/aura_constants.dart';

/// An abstract class representing the core functionality of an Aura wallet.
abstract class AuraWalletCore {
  /// Generates a random HD wallet.
  ///
  /// Returns an [ComprehensiveWallet] containing the wallet information.
  Future<ComprehensiveWallet> createRandomHDWallet();

  /// Restores a HD wallet from a passphrase.
  ///
  /// [passPhrase]: The passphrase used to restore the wallet.
  /// [walletName]: The name of the wallet (default is [CONST_DEFAULT_WALLET_NAME]).
  ///
  /// Returns an [AuraWallet] instance.
  Future<AuraWallet> restoreHDWallet({
    required String passPhrase,
    String walletName = CONST_DEFAULT_WALLET_NAME,
  });

  /// Loads a previously stored wallet.
  ///
  /// [walletName]: The name of the wallet to load (default is [CONST_DEFAULT_WALLET_NAME]).
  ///
  /// Returns an [AuraWallet] instance or `null` if no wallet is found.
  Future<AuraWallet?> loadStoredWallet({
    String walletName = CONST_DEFAULT_WALLET_NAME,
  });

  /// Removes a wallet from storage.
  ///
  /// [walletName]: The name of the wallet to remove (default is [CONST_DEFAULT_WALLET_NAME]).
  Future<void> removeWallet({
    String walletName = CONST_DEFAULT_WALLET_NAME,
  });
}
