import 'package:alan/alan.dart';

import 'package:aura_wallet_core/src/utils/aura_wallet_utils.dart';

import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import '../aura_wallet_core.dart';
import 'config_options/biometric_options.dart';
import 'constants/aura_constants.dart';
import 'constants/error_constants.dart';
import 'core/exceptions/aura_internal_exception.dart';

import 'core/repo/store_house.dart';
import 'core/utils/aura_inapp_wallet_helper.dart';
import 'core/utils/aura_internal_storage.dart';
import 'entities/aura_wallet.dart';
import 'entities/aura_wallet_impl.dart';
import 'env/env.dart';

class AuraWalletCoreImpl implements AuraWalletCore {
  AuraWalletCoreImpl({
    required AuraWalletCoreEnvironment environment,
    required BiometricOptions? biometricOptions,
  }) {
    Storehouse.environment = environment;
    Storehouse.networkInfo = AuraWalletUtil.getNetworkInfo(environment);
    Storehouse.storage = AuraInternalStorage(biometricOptions);
  }

  @override
  Future<ComprehensiveWallet> createRandomHDWallet({
    String walletName = CONST_DEFAULT_WALLET_NAME,
  }) async {
    try {
      // Generate a random mnemonic with a strength of 256 bits.
      final List<String> mnemonic = Bip39.generateMnemonic(strength: 256);

      // Derive a wallet from the generated mnemonic.
      final Wallet wallet = Wallet.derive(mnemonic, Storehouse.networkInfo);

      // Create and return an AuraFullInfoAuraWalletImpl instance with the derived wallet details.
      return ComprehensiveWalletImpl(
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

  @override
  Future<AuraWallet> restoreHDWallet({
    required String passPhrase,
    String walletName = CONST_DEFAULT_WALLET_NAME,
  }) async {
    try {
      // Check if the provided passphrase is a valid mnemonic.
      bool isMnemonic =
          AuraInAppWalletHelper.checkMnemonic(mnemonic: passPhrase);

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

  /// Removes a wallet with the specified [walletName].
  ///
  /// [walletName]: The name of the wallet to remove. Defaults to [CONST_DEFAULT_WALLET_NAME].
  ///
  /// Throws an [AuraInternalError] if there's an error while deleting the wallet.
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

class ComprehensiveWalletImpl extends ComprehensiveWallet {
  ComprehensiveWalletImpl({
    required super.mnemonic,
    required super.privateKey,
    required super.auraWallet,
  });
}
