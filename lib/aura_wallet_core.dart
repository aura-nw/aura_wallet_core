library aura_wallet_core;

import 'package:aura_wallet_core/config_options/biometric_options.dart';
import 'package:aura_wallet_core/config_options/config_options.dart';
import 'package:aura_wallet_core/config_options/enviroment_options.dart';
import 'package:aura_wallet_core/src/cores/aura_wallet/aura_wallet.dart';
import 'package:aura_wallet_core/src/aura_internal_wallet_ipml.dart';
import 'package:aura_wallet_core/src/constants/aura_constants.dart';

/// An abstract class representing the core functionality of an Aura wallet.
abstract class AuraWalletCore {
  /// Factory constructor for creating an instance of [AuraWalletCore].
  factory AuraWalletCore.create({
    required AuraEnvironment environment,
    BiometricOptions? biometricOptions,
    ConfigOption configOption = const ConfigOption(
      isEnableLog: true,
    ),
  }) {
    return _instance(environment, biometricOptions, configOption);
  }

  /// Internal method to create an instance of [AuraWalletCore].
  static AuraWalletCore _instance(
    AuraEnvironment environment,
    BiometricOptions? biometricOptions,
    ConfigOption configOption,
  ) =>
      AuraWalletCoreImpl(
          environment: environment,
          biometricOptions: biometricOptions,
          configOption: configOption);

  /// Generates a random HD wallet.
  ///
  /// Returns an [ComprehensiveWallet] containing the wallet information.
  Future<ComprehensiveWallet> createRandomHDWallet();

  /// Restores a HD wallet from a passphrase.
  ///
  /// [passPhrase]: The passphrase used to restore the wallet.
  /// [walletName]: The name of the wallet (default is [defaultWalletName]).
  ///
  /// Returns an [AuraWallet] instance.
  Future<AuraWallet> restoreHDWallet({
    required String passPhrase,
    String walletName = defaultWalletName,
  });

  /// Loads a previously stored wallet.
  ///
  /// [walletName]: The name of the wallet to load (default is [defaultWalletName]).
  ///
  /// Returns an [AuraWallet] instance or `null` if no wallet is found.
  Future<AuraWallet?> loadStoredWallet({
    String walletName = defaultWalletName,
  });

  /// Removes a wallet from storage.
  ///
  /// [walletName]: The name of the wallet to remove (default is [defaultWalletName]).
  Future<void> removeWallet({
    String walletName = defaultWalletName,
  });
}
