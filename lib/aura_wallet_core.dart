library aura_wallet_core;

import 'package:aura_wallet_core/config_options/biometric_options.dart';
import 'package:aura_wallet_core/config_options/config_options.dart';
import 'package:aura_wallet_core/config_options/environment_options.dart';
import 'package:aura_wallet_core/src/cores/aura_internal_storage.dart';
import 'package:aura_wallet_core/src/cores/aura_wallet/aura_wallet.dart';
import 'package:aura_wallet_core/src/aura_internal_wallet_impl.dart';
import 'package:aura_wallet_core/src/constants/aura_constants.dart';

export 'src/cores/aura_wallet/entities/aura_transaction_info.dart';
export 'src/cores/aura_wallet/aura_wallet.dart';
export 'src/helpers/aura_wallet_helper.dart';
export 'src/wallet_connect/wallet_connect_service.dart';
export 'src/wallet_connect/wallet_connect_service_utils.dart';
export 'src/aura_core_helper.dart';

/// An abstract class representing the core functionality of an Aura wallet.
///
/// The [AuraWalletCore] provides essential functionalities for managing wallets,
/// including generating random HD wallets, restoring wallets from passphrases,
/// loading stored wallets, and removing wallets from storage.
abstract class AuraWalletCore {
  // static const WalletService walletService = WalletService();

  /// Factory constructor for creating an instance of [AuraWalletCore].
  factory AuraWalletCore.create({
    required AuraEnvironment environment,
    BiometricOptions? biometricOptions,
    ConfigOption configOption = const ConfigOption(
      isEnableLog: true,
    ),
  }) {
    AuraInternalStorage internalStorage = AuraInternalStorage(biometricOptions);
    return _instance(environment, internalStorage, configOption);
  }

  /// Internal method to create an instance of [AuraWalletCore].
  static AuraWalletCore _instance(
    AuraEnvironment environment,
    AuraInternalStorage internalStorage,
    ConfigOption configOption,
  ) =>
      AuraWalletCoreImpl(
          environment: environment,
          internalStorage: internalStorage,
          configOption: configOption);

  /// Generates a random HD wallet.
  ///
  /// Returns an [AuraWallet] containing the wallet information.
  /// [walletName]: The name of the wallet (default is [defaultWalletName]).
  Future<AuraWallet> createRandomHDWallet({
    String walletName = defaultWalletName,
  });

  /// Restores an HD wallet from a passphrase or private key.
  ///
  /// [passPhraseOrPrivateKey]: The passphrase or private key used to restore the wallet.
  /// [walletName]: The name of the wallet (default is [defaultWalletName]).
  ///
  /// Returns an [AuraWallet] instance.
  Future<AuraWallet> restoreHDWallet({
    required String passPhraseOrPrivateKey,
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
