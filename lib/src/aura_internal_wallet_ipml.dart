import 'package:alan/alan.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:aura_wallet_core/config_options/biometric_options.dart';
import 'package:aura_wallet_core/config_options/enviroment_options.dart';
import 'package:aura_wallet_core/src/cores/aura_internal_storage.dart';
import 'package:aura_wallet_core/src/cores/aura_wallet/aura_wallet.dart';
import 'package:aura_wallet_core/src/cores/aura_wallet/aura_wallet_impl.dart';
import 'package:aura_wallet_core/src/cores/exceptions/aura_internal_exception.dart';
import 'package:aura_wallet_core/src/cores/exceptions/error_constants.dart';
import 'package:aura_wallet_core/src/cores/repo/store_house.dart';
import 'package:aura_wallet_core/src/cores/utils/aura_wallet_utils.dart';
import 'package:aura_wallet_core/src/constants/aura_constants.dart';
import 'package:aura_wallet_core/src/helpers/aura_wallet_helper.dart';

import 'package:flutter/services.dart';
import 'package:hex/hex.dart';

// Implementation of AuraWalletCore interface.
class AuraWalletCoreImpl implements AuraWalletCore {
  AuraWalletCoreImpl({
    required AuraEnvironment environment,
    required BiometricOptions? biometricOptions,
  }) {
    // Initialize Storehouse settings with provided environment and biometric options.
    Storehouse.environment = environment;
    Storehouse.networkInfo = AuraWalletUtil.getNetworkInfo(environment);
    Storehouse.storage = AuraInternalStorage(biometricOptions);
  }

  // Create a new random HD wallet.
  @override
  Future<ComprehensiveWallet> createRandomHDWallet({
    String walletName = CONST_DEFAULT_WALLET_NAME,
  }) async {
    try {
      // Generate a random mnemonic with a strength of 256 bits.
      final List<String> mnemonic = Bip39.generateMnemonic(strength: 256);

      // Derive a wallet from the generated mnemonic.
      final Wallet wallet = Wallet.derive(mnemonic, Storehouse.networkInfo);

      // Create and return a ComprehensiveWallet instance with the derived wallet details.
      return ComprehensiveWallet(
        auraWallet: AuraWalletImpl(
          walletName: walletName,
          bech32Address: wallet.bech32Address,
          environment: Storehouse.environment,
        ),
        mnemonic: mnemonic.join(' '),
        privateKey: HEX.encode(wallet.privateKey),
      );
    } catch (e) {
      // Handle any exceptions that might occur during wallet creation.
      throw AuraInternalError(
        ErrorCode.WalletCreationError,
        'Error creating a random HD wallet: $e',
      );
    }
  }

  // Restore an HD wallet using a provided passphrase.
  @override
  Future<AuraWallet> restoreHDWallet({
    required String passPhrase,
    String walletName = CONST_DEFAULT_WALLET_NAME,
  }) async {
    try {
      // Check if the provided passphrase is a valid mnemonic.
      bool isMnemonic = AuraWalletHelper.checkMnemonic(mnemonic: passPhrase);

      // If it's a valid mnemonic, throw an error.
      if (!isMnemonic) {
        throw AuraInternalError(
          ErrorCode.InvalidPassphrase,
          'Invalid passphrase provided.',
        );
      }

      // Derive a wallet from the provided passphrase.
      final Wallet wallet =
          Wallet.derive(passPhrase.split(' '), Storehouse.networkInfo);

      // Save the wallet details to storage.
      await Storehouse.storage.saveWalletToStorage(
        walletName: walletName,
        passphrase: passPhrase,
        walletAddress: wallet.bech32Address,
      );

      // Create and return an AuraWalletImpl instance with the restored wallet details.
      return AuraWalletImpl(
        walletName: walletName,
        bech32Address: wallet.bech32Address,
        environment: Storehouse.environment,
      );
    } catch (e) {
      // Handle any exceptions that might occur during wallet restoration.
      throw AuraInternalError(
        ErrorCode.WalletRestorationError,
        'Error restoring HD wallet: $e',
      );
    }
  }

  // Load a stored wallet using its walletName.
  @override
  Future<AuraWallet?> loadStoredWallet({
    String walletName = CONST_DEFAULT_WALLET_NAME,
  }) async {
    try {
      // Attempt to read the passphrase from storage.
      String? passPhrase =
          await Storehouse.storage.readWalletPassPhrase(walletName: walletName);

      // If the passphrase is null, return null (no wallet found).
      if (passPhrase == null) {
        return null;
      }

      // Derive a wallet from the stored passphrase.
      final Wallet wallet =
          Wallet.derive(passPhrase.split(' '), Storehouse.networkInfo);

      // Create and return an AuraWalletImpl instance with the loaded wallet details.
      return AuraWalletImpl(
        walletName: walletName,
        bech32Address: wallet.bech32Address,
        environment: Storehouse.environment,
      );
    } catch (e) {
      // Handle any exceptions that might occur during wallet loading.
      if (e is PlatformException) {
        // If the exception is a PlatformException, create an AuraInternalError with a specific error code and message.
        throw AuraInternalError(
          ErrorCode.PlatformError,
          '[${e.code}] ${e.message}',
        );
      } else {
        // If it's any other type of exception, create an AuraInternalError with a different error code and the exception message.
        throw AuraInternalError(
          ErrorCode.WalletLoadingError,
          e.toString(),
        );
      }
    }
  }

  // Remove a wallet with the specified walletName.
  @override
  Future<void> removeWallet(
      {String walletName = CONST_DEFAULT_WALLET_NAME}) async {
    try {
      // Delete the wallet using the provided walletName.
      await Storehouse.storage.deleteWallet(walletName: walletName);
    } catch (e) {
      // Handle any exceptions that might occur during wallet removal.
      if (e is PlatformException) {
        throw AuraInternalError(
            ErrorCode.PlatformError, '[${e.code}] ${e.message}');
      } else {
        throw AuraInternalError(ErrorCode.WalletLoadingError, e.toString());
      }
    }
  }
}
