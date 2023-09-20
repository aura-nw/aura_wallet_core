import 'dart:typed_data';

import 'package:alan/alan.dart';
import 'package:alan/proto/tendermint/abci/types.pb.dart';
import 'package:protobuf/protobuf.dart' as proto;

import '../../env/env.dart';
import '../type_data/aura_type_data.dart';

class AuraInAppWalletHelper {
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
      (e) {};

      AuraTransaction auraTransaction =
          AuraTransaction(sender, recipient, amount, timeStamp, type);
      return auraTransaction;
    }).toList();
    return listResult;
  }

  static bool checkMnemonic({required String mnemonic}) {
    return Bip39.validateMnemonic(mnemonic.split(' '));
  }

  static Fee createFee(
      {required String amount,
      required AuraWalletCoreEnvironment environment}) {
    String denom = "uaura";
    if (environment == AuraWalletCoreEnvironment.euphoria) {
      denom = 'ueaura';
    }
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
