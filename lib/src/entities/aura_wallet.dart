import 'package:alan/proto/cosmos/tx/v1beta1/tx.pb.dart';
import '../core/type_data/aura_transaction_info.dart';
import '../env/env.dart';

abstract class AuraWallet {
  final String walletName;
  final String bech32Address;
  final AuraWalletCoreEnvironment environment;

  const AuraWallet({
    required this.walletName,
    required this.bech32Address,
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
  Future<String?> getWalletPassPhrase();
}

abstract class ComprehensiveWallet {
  final String mnemonic;
  final String privateKey;
  final AuraWallet auraWallet;

  ComprehensiveWallet({
    required this.mnemonic,
    required this.privateKey,
    required this.auraWallet,
  });
}
