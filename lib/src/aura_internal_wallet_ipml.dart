import 'package:alan/alan.dart';

import 'package:aura_wallet_core/src/utils/aura_wallet_utils.dart';

import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import '../aura_wallet_core.dart';
import 'config_options/biometric_options.dart';
import 'constants/aura_constants.dart';
import 'core/exceptions/aura_internal_exception.dart';

import 'core/repo/di.dart';
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
  Future<AuraFullInfoWallet> createRandomHDWallet(
      {String walletName = CONST_DEFAULT_WALLET_NAME}) async {
    List<String> mnemonic2 = Bip39.generateMnemonic(strength: 256);
    final Wallet wallet = Wallet.derive(mnemonic2, Storehouse.networkInfo);

    return AuraFullInfoAuraWalletImpl(
      auraWallet: AuraWalletImpl(
        walletName: walletName,
        bech32Address: wallet.bech32Address,
        environment: Storehouse.environment,
      ),
      mnemonic: mnemonic2.join(' '),
      privateKey: HEX.encode(wallet.privateKey),
    );
  }

  @override
  Future<AuraWallet> restoreHDWallet(
      {required String passPhrase,
      String walletName = CONST_DEFAULT_WALLET_NAME}) async {
    bool isMnemonic = AuraInAppWalletHelper.checkMnemonic(mnemonic: passPhrase);
    if (isMnemonic) {
      throw INVAILD_PASSPHRASE;
    }

    final wallet = Wallet.derive(passPhrase.split(' '), Storehouse.networkInfo);

    await Storehouse.storage.saveWalletToStorage(
        walletName: walletName,
        passphrase: passPhrase,
        walletAddress: wallet.bech32Address);

    return AuraWalletImpl(
      walletName: walletName,
      bech32Address: wallet.bech32Address,
      environment: Storehouse.environment,
    );
  }

  @override
  Future<AuraWallet?> loadStoragedWallet(
      {String walletName = CONST_DEFAULT_WALLET_NAME}) async {
    try {
      String? passPhrase =
          await Storehouse.storage.loadWalletPassPhrase(walletName: walletName);

      if (passPhrase == null) {
        return null;
      }
      final wallet =
          Wallet.derive(passPhrase.split(' '), Storehouse.networkInfo);

      return AuraWalletImpl(
        walletName: walletName,
        bech32Address: wallet.bech32Address,
        environment: Storehouse.environment,
      );
      ;
    } catch (e) {
      if (e is PlatformException) {
        throw AuraInternalError(1001, '[${e.code}] ${e.message}');
      } else {
        throw AuraInternalError(2001, e.toString());
      }
    }
  }
}

class AuraFullInfoAuraWalletImpl extends AuraFullInfoWallet {
  AuraFullInfoAuraWalletImpl({
    required super.mnemonic,
    required super.privateKey,
    required super.auraWallet,
  });
}
