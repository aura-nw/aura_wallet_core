import 'package:alan/proto/cosmos/tx/v1beta1/tx.pb.dart';
import 'package:aura_wallet_core/src/constants/aura_constants.dart';
import 'package:aura_wallet_core/enum/order_enum.dart';
import 'package:aura_wallet_core/src/cores/aura_wallet/entities/aura_transaction_info.dart';

/// Abstract class representing an Aura Wallet.
abstract class AuraWallet {
  final String walletName;
  final String bech32Address;

  const AuraWallet({
    required this.walletName,
    required this.bech32Address,
  });

  /// Create a new transaction and sign it.
  ///
  /// Parameters:
  ///   - [toAddress]: The recipient's address.
  ///   - [amount]: The amount to send.
  ///   - [fee]: The transaction fee.
  ///   - [memo]: An optional memo to include in the transaction.
  Future<Tx> sendTransaction({
    required String toAddress,
    required String amount,
    required String fee,
    required int gasLimit,
    String? memo,
  });

  /// Send the transaction to the Aura network.
  ///
  /// Parameters:
  ///   - [signedTransaction]: The signed transaction to submit.
  Future<bool> submitTransaction({required Tx signedTransaction});

  /// Check the balance value of the wallet's address.
  Future<String> checkWalletBalance();

  /// Get a list of transactions associated with the wallet's address.
  /// Parameters:
  ///   - [offset] : The transaction offset.
  ///   - [limit] : Maximum transaction page.
  ///   - [orderBy] : The order by parameters.
  Future<List<AuraTransaction>> getWalletHistory(
      {int offset = defaultQueryOffset,
      int limit = defaultQueryLimit,
      AuraTransactionOrderByType orderBy =
          AuraTransactionOrderByType.ORDER_BY_ASC});

  /// Return response data corresponding to a smart contract query.
  ///
  /// Parameters:
  ///   - [contractAddress]: The address of the smart contract.
  ///   - [query]: The query parameters.
  Future<String> makeQuerySmartContract({
    required String contractAddress,
    required Map<String, dynamic> query,
  });

  /// Return the TxHash code corresponding to the execution of a smart contract message.
  ///
  /// Parameters:
  ///   - [contractAddress]: The address of the smart contract.
  ///   - [executeMessage]: The message to execute.
  ///   - [funds]: Optional funds.
  ///   - [fee]: Optional fee.
  Future<String> makeInteractiveWriteSmartContract({
    required String contractAddress,
    required Map<String, dynamic> executeMessage,
    required int gasLimit,
    required int fee,
    List<int>? funds,
  });

  /// Verify the status of contract execution from a TxHash.
  ///
  /// Parameters:
  ///   - [txHash]: The transaction hash to verify.
  Future<bool> verifyTxHash({
    required String txHash,
  });

  /// Return the mnemonic passphrase of the user.
  Future<String?> getWalletPassPhrase();
}

/// Represents a Comprehensive Wallet in the Aura Wallet application.
///
/// A `ComprehensiveWallet` combines both the cryptographic credentials (mnemonic
/// and private key) and an associated `AuraWallet` instance. It serves as a
/// complete representation of a wallet, including the means to sign and manage
/// transactions (through `AuraWallet`) and the underlying cryptographic identity.
class ComprehensiveWallet {
  final String mnemonic;
  final String privateKey;
  final AuraWallet auraWallet;

  /// Constructor for a `ComprehensiveWallet`.
  ///
  /// Parameters:
  ///   - [mnemonic]: A secret phrase used for cryptographic key derivation.
  ///   - [privateKey]: A private key associated with the wallet's identity.
  ///   - [auraWallet]: An instance of `AuraWallet` for transaction management
  ///                   and communication with the Aura Network.
  ComprehensiveWallet({
    required this.mnemonic,
    required this.privateKey,
    required this.auraWallet,
  });
}
