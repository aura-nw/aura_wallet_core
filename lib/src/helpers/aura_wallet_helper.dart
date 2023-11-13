import 'dart:typed_data';

import 'package:alan/alan.dart';
import 'package:alan/proto/tendermint/abci/types.pb.dart';
import 'package:aura_wallet_core/src/cores/aura_wallet/entities/aura_transaction_info.dart';
import 'package:aura_wallet_core/src/cores/exceptions/aura_internal_exception.dart';
import 'package:aura_wallet_core/src/cores/exceptions/error_constants.dart';
import 'package:aura_wallet_core/src/cores/repo/store_house.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:protobuf/protobuf.dart' as proto;
import 'dart:developer' as Log;

/// The `AuraWalletHelper` class provides utility methods for various tasks
/// related to the Aura Wallet Core. These methods include converting
/// transaction responses, checking mnemonic validity, creating transaction fees,
/// signing transactions, and validating private keys.
class AuraWalletHelper {
  /// Converts a list of `TxResponse` objects into a list of `AuraTransaction` objects.
  ///
  /// Parameters:
  ///   - [txResponse]: The list of transaction responses to convert.
  /// Returns:
  ///   - A list of `AuraTransaction` objects.
  static List<AuraTransaction> convertToAuraTransaction(
    List<TxResponse> txResponse,
  ) {
    List<AuraTransaction> listResult = txResponse.map((e) {
      String timeStamp = e.timestamp;
      String recipient = '';
      String sender = '';
      String amount = '';
      List<Event> listEvent = e.events;

      for (var i = 0; i < listEvent.length; i++) {
        if (listEvent[i].type == 'transfer') {
          List<EventAttribute> listAttribute = listEvent[i].attributes;
          for (var j = 0; j < listAttribute.length; j++) {
            final txAttribute = listAttribute[j];
            String keyData = String.fromCharCodes(txAttribute.key);
            String valueData = String.fromCharCodes(txAttribute.value);

            if (keyData == 'recipient') {
              recipient = valueData;
            }
            if (keyData == 'sender') {
              sender = valueData;
            }
            if (keyData == 'amount') {
              amount = valueData;
            }
          }
        }
      }

      AuraTransaction auraTransaction =
          AuraTransaction(sender, recipient, amount, timeStamp);
      return auraTransaction;
    }).toList();
    return listResult;
  }

  /// Checks the validity of a mnemonic phrase.
  ///
  /// Parameters:
  ///   - [mnemonic]: The mnemonic phrase to validate.
  /// Returns:
  ///   - `true` if the mnemonic is valid, `false` otherwise.
  static bool checkMnemonic({required String mnemonic}) {
    return Bip39.validateMnemonic(mnemonic.split(' '));
  }

  /// Creates a transaction fee based on the specified amount and environment.
  ///
  /// Parameters:
  ///   - [amount] : The transaction fee amount.
  ///   - [gasLimit] : GasLimit of transaction
  ///   - [denom] : The coin denom aura network
  /// Returns:
  ///   - A `Fee` object representing the transaction fee.
  static Fee createFee(
      {required String amount, required int gasLimit, required String denom}) {
    // Compose the transaction fees
    final fee = Fee();
    fee.gasLimit = gasLimit.toInt64();
    fee.amount.add(
      Coin.create()
        ..amount = amount
        ..denom = denom,
    );
    return fee;
  }

  /// Signs a transaction using the provided parameters.
  ///
  /// Parameters:
  ///   - [networkInfo]: The network information.
  ///   - [wallet]: The wallet used for signing.
  ///   - [msgSend]: The list of messages to include in the transaction.
  ///   - [fee]: The transaction fee.
  ///   - [memo]: An optional memo to include in the transaction.
  /// Returns:
  ///   - A signed `Tx` object representing the transaction.
  static Future<Tx> signTransaction({
    required NetworkInfo networkInfo,
    required Wallet wallet,
    required List<proto.GeneratedMessage> msgSend,
    required Fee fee,
    String? memo,
  }) async {
    final signer = TxSigner.fromNetworkInfo(networkInfo);
    final tx = await signer.createAndSign(
      wallet,
      msgSend,
      fee: fee,
      memo: memo,
    );
    return tx;
  }

  /// Checks the validity of a private key.
  ///
  /// Parameters:
  ///   - [privateKey]: The private key as a `String`.
  /// Returns:
  ///   - `true` if the private key is valid, `false` otherwise.
  static bool checkPrivateKey(String privateKey) {
    final List<int> deCodePrivateKey = HEX.decode(privateKey);

    Bip32EccCurve ecc = Bip32EccCurve();

    return privateKey.length == 32 && ecc.isPrivate(Uint8List.fromList(deCodePrivateKey));
  }

  static Future<Wallet> deriveWallet(
      String? passPhraseOrPrivateKey, Storehouse storehouse) async {
    if (passPhraseOrPrivateKey == null) {
      throw AuraInternalError(
        ErrorCode.InvalidPassphrase,
        'Invalid or missing passphrase or private key.',
      );
    }

    try {
      if (AuraWalletHelper.checkMnemonic(mnemonic: passPhraseOrPrivateKey)) {
        // Derive a wallet from the stored passphrase.
        final Wallet wallet = Wallet.derive(
          passPhraseOrPrivateKey.split(' '),
          storehouse.configService.networkInfo,
        );
        return wallet;
      } else {
        final privateKey = HEX.decode(passPhraseOrPrivateKey);

        if (!AuraWalletHelper.checkPrivateKey(passPhraseOrPrivateKey)) {
          throw AuraInternalError(
            ErrorCode.InvalidPassphrase,
            'Invalid or missing passphrase or private key.',
          );
        }

        final wallet = Wallet.import(
          storehouse.configService.networkInfo,
          Uint8List.fromList(privateKey),
        );

        return wallet;
      }
    } catch (e, s) {
      // Handle any exceptions that might occur during wallet loading.
      final errorMessage =
          (e is PlatformException) ? '[${e.code}] ${e.message}' : e.toString();

      Log.log(e.toString(), stackTrace: s);

      throw AuraInternalError(
        ErrorCode.WalletLoadingError,
        errorMessage,
      );
    }
  }
}
