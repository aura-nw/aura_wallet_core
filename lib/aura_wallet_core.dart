import 'package:aura_wallet_core/src/config_options/biometric_options.dart';

import 'src/aura_internal_wallet_ipml.dart';
import 'src/constants/aura_constants.dart';
import 'src/entities/aura_wallet.dart';
import 'src/env/env.dart';

/// An abstract class representing the core functionality of an Aura wallet.
abstract class AuraWalletCore {
  /// Factory method to create an instance of [AuraWalletCore].
  ///
  /// [environment]: The environment configuration for the wallet.
  factory AuraWalletCore.create(
      {required AuraWalletCoreEnvironment environment,
      BiometricOptions? biometricOptions}) {
    return _instance(environment, biometricOptions);
  }

  /// Internal method to create an instance of [AuraWalletCore].
  static AuraWalletCore _instance(
    AuraWalletCoreEnvironment environment,
    BiometricOptions? biometricOptions,
  ) =>
      AuraWalletCoreImpl(
        environment: environment,
        biometricOptions: biometricOptions,
      );

  /// Create a new random Hierarchical Deterministic (HD) wallet.
  ///
  /// Returns a [AuraFullInfoWallet] representing the newly created wallet.
  Future<AuraFullInfoWallet> createRandomHDWallet();

  /// Restore an HD wallet using a provided key.
  ///
  /// [key]: The key used for wallet restoration.
  ///
  /// Returns a [AuraWallet] object representing the restored wallet.
  Future<AuraWallet> restoreHDWallet(
      {required String passPhrase,
      String walletName = CONST_DEFAULT_WALLET_NAME});

  /// Load the current wallet associated with the given Bech32 address.
  ///
  /// [bech32Address]: The Bech32 address of the wallet to load.
  ///
  /// Returns a [AuraWallet] object if the wallet exists, or null if not found.
  Future<AuraWallet?> loadStoragedWallet(
      {String walletName = CONST_DEFAULT_WALLET_NAME});
}
