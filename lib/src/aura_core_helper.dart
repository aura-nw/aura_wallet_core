import 'dart:typed_data';

import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:aura_wallet_core/src/cores/wallet_connect/data_model/std_sign_doc.dart';
import 'package:aura_wallet_core/src/wallet_connect/aura_wallet_connect_helper.dart';

class AuraCoreHelper {
  static Map<String, dynamic> signAmino(
      {required Map<String, dynamic> signDoc, required String privateKeyHex}) {
    StdSignDoc stdSignDoc = StdSignDoc.fromJson(signDoc);
    String signatureBase64 = AuraWalletConnectHelper.createSignatureFromSignDoc(
        signDoc: stdSignDoc, privateKeyHex: privateKeyHex);
    Uint8List privateKey =
        AuraWalletHelper.getPrivateKeyFromString(privateKeyHex);

    Uint8List publicKeyHex =
        AuraWalletHelper.getPublicKeyFromPrivateKey(privateKey);
    Map<String, dynamic> response = AuraWalletConnectHelper.makeReslt(
        stdSignDoc, signatureBase64, publicKeyHex);

    return response;
  }
}
