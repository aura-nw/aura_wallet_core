import 'dart:typed_data';

import 'package:alan/alan.dart';
import 'package:alan/proto/tendermint/abci/types.pb.dart';
import 'package:aura_wallet_core/config_options/enviroment_options.dart';
import 'package:aura_wallet_core/src/cores/aura_wallet/entities/aura_transaction_info.dart';
import 'package:aura_wallet_core/src/cores/utils/aura_wallet_utils.dart';
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
      List<TxResponse> txResponse, AuraTransactionType type) {
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
          AuraTransaction(sender, recipient, amount, timeStamp, type);
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
  ///   - [amount]: The transaction fee amount.
  ///   - [environment]: The Aura environment.
  /// Returns:
  ///   - A `Fee` object representing the transaction fee.
  static Fee createFee(
      {required String amount, required AuraEnvironment environment}) {
    String denom = AuraWalletUtil.getDenom(environment);
    // Compose the transaction fees
    final fee = Fee();
    fee.gasLimit = 200000.toInt64();
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

    if (privateKey.length != 32) {
      return false;
    }

    if (!ecc.isPrivate(privateKey)) {
      return false;
    }

    return true;
  }
}
