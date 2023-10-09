import 'dart:typed_data';

import 'package:alan/alan.dart';
import 'package:alan/proto/tendermint/abci/types.pb.dart';
import 'package:aura_wallet_core/src/cores/aura_wallet/entities/aura_transaction_info.dart';
import 'package:aura_wallet_core/src/cores/exceptions/aura_internal_exception.dart';
import 'package:aura_wallet_core/src/cores/exceptions/error_constants.dart';
import 'package:aura_wallet_core/src/cores/repo/store_house.dart';
import 'package:flutter/services.dart';
import 'package:protobuf/protobuf.dart' as proto;

/// The `AuraWalletHelper` class provides utility methods for various tasks
/// related to the Aura Wallet Core. These methods include converting
/// transaction responses, checking mnemonic validity, creating transaction fees,
/// signing transactions, and validating private keys.
class AuraWalletHelper {
  /// Converts a list of `TxResponse` objects into a list of `AuraTransaction` objects.
  ///
  /// Parameters:
  ///   - [txResponse]: The list of transaction responses to convert.
  ///   - [type]: The type of AuraTransaction to create.
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
  ///   - [privateKey]: The private key as a `Uint8List`.
  /// Returns:
  ///   - `true` if the private key is valid, `false` otherwise.
  static bool checkPrivateKey(Uint8List privateKey) {
    Bip32EccCurve ecc = Bip32EccCurve();

    return privateKey.length == 32 && ecc.isPrivate(privateKey);
  }

  static Future<Wallet> deriveWallet(
      String? passPhrase, Storehouse storehouse) async {
    try {
      // If the passphrase is null, return null (no wallet found).
      if (passPhrase == null ||
          !AuraWalletHelper.checkMnemonic(mnemonic: passPhrase)) {
        throw AuraInternalError(
          ErrorCode.InvalidPassphrase,
          'Invalid passphrase provided.',
        );
      }

      // Derive a wallet from the stored passphrase.
      final Wallet wallet = Wallet.derive(
          passPhrase.split(' '), storehouse.configService.networkInfo);

      // Create and return an AuraWalletImpl instance with the loaded wallet details.
      return wallet;
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
}
