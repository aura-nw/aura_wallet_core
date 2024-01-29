import 'dart:convert';
import 'dart:typed_data';

import 'package:alan/alan.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:aura_wallet_core/src/cores/wallet_connect/data_model/std_sign_doc.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart';
import 'package:crypto/src/sha256.dart';
import 'package:walletconnect_flutter_v2/apis/models/json_rpc_request.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class AuraWalletConnectHelper {
  static String createSignatureFromSignDoc(
      {required StdSignDoc signDoc, required String privateKeyHex}) {
    Uint8List serializedSignDoc = _serializeSignDoc(signDoc);

    List<int> message = sha256.convert(serializedSignDoc).bytes;

    final signature = _createSignature(
      Uint8List.fromList(message),
      AuraWalletHelper.getPrivateKeyFromString(privateKeyHex),
    );

    String signatureBase64 = base64Encode(signature);
    print(base64Encode(signature));
    return signatureBase64;
  }

  static String _escapeCharacters(String input) {
    // Dart does not have built-in Unicode escape sequences, so manually replace characters
    input = input
        .replaceAll('&', r'\u0026')
        .replaceAll('<', r'\u003c')
        .replaceAll('>', r'\u003e');
    return input;
  }

  static Uint8List _serializeSignDoc(StdSignDoc signDoc) {
    String serialized = _escapeCharacters(_sortedJsonStringify(
      signDoc.toJson(),
    ));
    return _toUtf8(serialized);
  }

  static Uint8List _toUtf8(String input) {
    // Implement the _toUtf8 function if not already available
    // ...

    // For demonstration purposes, using utf8.encode from dart:convert
    return utf8.encode(input);
  }

  static String _sortedJsonStringify(Map<String, dynamic> obj) {
    return jsonEncode(_sortedObject(obj));
  }

  static dynamic _sortedObject(Object? obj) {
    if (obj == null) {
      return obj;
    }

    if (obj is List) {
      return obj.map((item) => _sortedObject(item)).toList();
    }

    if (obj is Map<String, dynamic>) {
      List<String> sortedKeys = obj.keys.toList()..sort();
      Map<String, dynamic> result = {};
      sortedKeys.forEach((key) {
        print(key);
        result[key] = _sortedObject(obj[key]);
      });
      return result;
    }

    return obj;
  }

  /// Create a signature form private key and hashMessage
  static Uint8List _createSignature(
      Uint8List hashedMessage, Uint8List privateKey) {
    final ecPrivateKey = ECPrivateKey(
      BigInt.parse(HEX.encode(privateKey), radix: 16),
      ECCurve_secp256k1(),
    );

    final hash = SHA256Digest().process(hashedMessage);

    final ecdsaSigner = ECDSASigner(null, HMac(SHA256Digest(), 64))
      ..init(true, PrivateKeyParameter(ecPrivateKey));

    final ecSignature = ecdsaSigner.generateSignature(hash) as ECSignature;

    var normalizedS = ecSignature.s;

    if (normalizedS.compareTo(ECCurve_secp256k1().n >> 1) > 0) {
      normalizedS = ECCurve_secp256k1().n - normalizedS;
    }
    final normalized = ECSignature(ecSignature.r, normalizedS);

    final rBytes = normalized.r.toUin8List();
    final sBytes = normalized.s.toUin8List();

    var sigBytes = Uint8List(64);

    _copy(rBytes, 32 - rBytes.length, 32, sigBytes);
    _copy(sBytes, 64 - sBytes.length, 64, sigBytes);

    return sigBytes;
  }

  /// Just for create signature
  static void _copy(
      Uint8List source, int start, int end, Uint8List destination) {
    var index = 0;
    for (var i = start; i < end; i++) {
      destination[i] = source[index];
      index++;
    }
  }

  static Map<String, dynamic> makeReslt(
      StdSignDoc signDoc, String signatureBase64, Uint8List publicKeyHex) {
    print('signDoc.msg: ${signDoc.msgs}');
    // Map<String, dynamic> listMsg = jsonDecode(signDoc.msgs.toString());

    // print('listMsg: $listMsg');

    String msgData = jsonEncode(signDoc.msgs[0]);

    print('#Pyxis msgData: $msgData');

    Map<String, dynamic> listMsg2 = jsonDecode(msgData);

    print('#Pyxis listMsg2: $listMsg2');
    Map<String, dynamic> json = {
      'signed': {
        'account_number': signDoc.accountNumber,
        'chain_id': signDoc.chainId,
        'fee': {
          'amount': signDoc.fee.amount.map((e) => e.toJson()).toList(),
          'gas': signDoc.fee.gas,
        },
        'memo': signDoc.memo,
        'msgs': [listMsg2],
        'sequence': signDoc.sequence,
      },
      'signature': {
        'pub_key': {
          'type': 'tendermint/PubKeySecp256k1',
          'value': HEX.encode(publicKeyHex),
        },
        'signature': signatureBase64,
      }
    };

    return json;
  }
}
