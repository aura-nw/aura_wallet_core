import 'package:alan/proto/cosmos/tx/v1beta1/tx.pb.dart';
import 'package:alan/wallet/wallet.dart';

import '../core/type_data/aura_type_data.dart';
import '../env/env.dart';

abstract class AuraWallet {
  final Wallet wallet;
  final AuraWalletCoreEnvironment environment;

  const AuraWallet({
    required this.wallet,
    required this.environment,
  });

  ///
  /// Create a new transaction and sign it
  ///
  Future<Tx> makeTransaction({
    required String toAddress,
    required String amount,
    required String fee,
    String? memo,
  });

  ///
  /// Send the transaction to Aura network
  ///
  Future<bool> submitTransaction({required Tx signedTransaction});

  ///
  /// Check balance value of an address
  ///
  Future<String> checkWalletBalance();

  ///
  /// Get List Transaction of an address
  ///
  Future<List<AuraTransaction>> checkWalletHistory();

  ///
  /// Return response data corresponding query
  ///
  Future<String> makeInteractiveQuerySmartContract({
    required String contractAddress,
    required Map<String, dynamic> query,
  });

  ///
  /// Return TxHash code corresponding execute message
  ///
  Future<String> makeInteractiveWriteSmartContract({
    required String contractAddress,
    required Map<String, dynamic> executeMessage,
    List<int>? funds,
    int? fee,
  });

  ///
  /// Verify status execute contract from txHash
  ///
  Future<bool> verifyTxHash({
    required String txHash,
  });

  ///
  /// Return mnemonic of user
  ///
  Future<String?> getCurrentMnemonicOrPrivateKey();

  Future<bool> removeCurrentWallet();
}

abstract class AuraFullInfoWallet {
  final String mnemonic;
  final String privateKey;
  final AuraWallet auraWallet;

  AuraFullInfoWallet({
    required this.mnemonic,
    required this.privateKey,
    required this.auraWallet,
  });
}
