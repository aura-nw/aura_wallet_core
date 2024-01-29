import 'dart:convert';
import 'dart:typed_data';

import 'package:alan/alan.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart';
import 'package:walletconnect_flutter_v2/apis/web3wallet/web3wallet.dart';
import 'package:convert/convert.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';

class WalletConnectServiceUtils {
  static registerChain(String chainId, Web3Wallet web3wallet) {
    web3wallet.registerEventEmitter(chainId: chainId, event: 'chainChanged');
    web3wallet.registerEventEmitter(chainId: chainId, event: 'accountsChanged');

    web3wallet.registerRequestHandler(
        chainId: chainId, method: 'cosmos_signDirect');

    web3wallet.registerRequestHandler(
        chainId: chainId, method: 'cosmos_getAccounts');

    web3wallet.registerRequestHandler(
        chainId: chainId, method: 'cosmos_signAmino');
  }

  static String getUtf8Message(String maybeHex) {
    if (maybeHex.startsWith('0x')) {
      final List<int> decoded = hex.decode(
        maybeHex.substring(2),
      );
      return utf8.decode(decoded);
    }

    return maybeHex;
  }

  static String signAminoMessage(
      {required String aminoMessage, required String privateKeyHex}) {
    final privateKeyBytes = Uint8List.fromList(hex.decode(privateKeyHex));
    final messageBytes = utf8.encode(aminoMessage);

    final hmac = HMac(SHA256Digest(), 64)
      ..init(crypto.KeyParameter(privateKeyBytes));

    final signatureBytes = hmac.process(messageBytes);

    // Convert the signature to a hexadecimal string or any other format required
    final signatureHex = hex.encode(signatureBytes);

    return signatureHex;
  }

  /// Hashes the given [data] with SHA-256, and then sign the hash using the
  /// private key associated with this wallet, returning the signature
  /// encoded as a 64 bytes array.
  static Uint8List sign(Uint8List data, String privateKeyHex) {
    final hash = SHA256Digest().process(data);
    ECPrivateKey ecPrivateKey = _ecPrivateKey(privateKeyHex);
    final ecdsaSigner = ECDSASigner(null, HMac(SHA256Digest(), 64))
      ..init(true, PrivateKeyParameter(ecPrivateKey));

    final ecSignature = ecdsaSigner.generateSignature(hash) as ECSignature;
    final normalized = _normalizeECSignature(ecSignature, ECCurve_secp256k1());
    final rBytes = normalized.r.toUin8List();
    final sBytes = normalized.s.toUin8List();

    var sigBytes = Uint8List(64);
    copy(rBytes, 32 - rBytes.length, 32, sigBytes);
    copy(sBytes, 64 - sBytes.length, 64, sigBytes);

    return sigBytes;
  }

  /// Hashes the given [data] with SHA-256, and then sign the hash using the
  /// private key associated with this wallet, returning the signature
  /// encoded as a 64 bytes array.
  static Uint8List sign2(String msg, String privateKeyHex) {
    // final List<int> msgdata = jsonEncode(msg).codeUnits;

    Uint8List data = utf8.encode(msg);
    return sign(data, privateKeyHex);
  }

  /// Returns the associated [privateKey] as an [ECPrivateKey] instance.
  static ECPrivateKey _ecPrivateKey(String privateKey) {
    var data = hex.decode(privateKey);
    final privateKeyInt = BigInt.parse(HEX.encode(data), radix: 16);
    return ECPrivateKey(privateKeyInt, ECCurve_secp256k1());
  }

  /// Normalizes the given [signature] using the provided [curveParams].
  /// This is used to create signatures that are always in the lower-S form, to
  /// make sure that they cannot be tamped with the alternative S value.
  /// More info can be found here: https://tinyurl.com/2yfurry7
  static ECSignature _normalizeECSignature(
    ECSignature signature,
    ECDomainParameters curveParams,
  ) {
    var normalizedS = signature.s;
    if (normalizedS.compareTo(curveParams.n >> 1) > 0) {
      normalizedS = curveParams.n - normalizedS;
    }
    return ECSignature(signature.r, normalizedS);
  }
}
