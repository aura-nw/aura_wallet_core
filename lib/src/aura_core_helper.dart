import 'dart:typed_data';

import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:aura_wallet_core/src/cores/wallet_connect/data_model/std_sign_doc.dart';
import 'package:aura_wallet_core/src/wallet_connect/aura_wallet_connect_helper.dart';

class AuraCoreHelper {
  static Map<String, dynamic> signAmino(
      {required Map<String, dynamic> signDoc,
      required String privateKeyHex,
      required String pubKeyHex}) {
    // Generate Signdoc object
    StdSignDoc stdSignDoc = StdSignDoc.fromJson(signDoc);

    // Generate signature
    String signatureBase64 = AuraWalletConnectHelper.createSignatureFromSignDoc(
        signDoc: stdSignDoc, privateKeyHex: privateKeyHex);

    // Generate public key
    Uint8List privateKey =
        AuraWalletHelper.getPrivateKeyFromString(privateKeyHex);

    // Make response
    Map<String, dynamic> response = AuraWalletConnectHelper.makeReslt(
        stdSignDoc, signatureBase64, pubKeyHex);

    return response;
  }
}
