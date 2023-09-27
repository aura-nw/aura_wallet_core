import 'dart:convert';
import 'dart:io';

import 'package:alan/alan.dart';
import 'package:aura_wallet_core/config_options/enviroment_options.dart';
import 'package:aura_wallet_core/src/cores/aura_wallet/aura_wallet.dart';
import 'package:aura_wallet_core/src/cores/aura_wallet/entities/aura_transaction_info.dart';
import 'package:aura_wallet_core/src/cores/exceptions/aura_internal_exception.dart';
import 'package:aura_wallet_core/src/cores/exceptions/error_constants.dart';
import 'package:aura_wallet_core/src/cores/repo/store_house.dart';
import 'package:aura_wallet_core/src/cores/utils/aura_wallet_utils.dart';
import 'package:aura_wallet_core/src/debugs/grpc_logger.dart';
import 'package:aura_wallet_core/src/helpers/aura_wallet_helper.dart';
import 'package:flutter/services.dart';

import 'package:alan/proto/cosmos/bank/v1beta1/export.dart';
import 'package:alan/proto/cosmos/bank/v1beta1/export.dart' as bank;
import 'package:alan/proto/cosmwasm/wasm/v1/export.dart' as cosMWasm;
import 'package:alan/proto/cosmos/tx/v1beta1/export.dart' as auraTx;

class AuraWalletImpl extends AuraWallet {
  const AuraWalletImpl({
    required String walletName,
    required String bech32Address,
    required AuraEnvironment environment,
  }) : super(
          walletName: walletName,
          bech32Address: bech32Address,
          environment: environment,
        );

  /// Submits a signed transaction to the blockchain network.
  ///
  /// Returns `true` if the transaction is successfully broadcasted, otherwise `false`.
  ///
  /// Throws an exception in case of any errors during the transaction submission.
  ///
  /// [signedTransaction]: The signed transaction to be broadcasted.
  ///
  @override
  Future<bool> submitTransaction({required Tx signedTransaction}) async {
    try {
      var networkInfo = Storehouse.networkInfo;
      final txSender = TxSender.fromNetworkInfo(networkInfo);
      final response = await txSender.broadcastTx(signedTransaction);

      return response.isSuccessful;
    } catch (e) {
      // Handle any exceptions that might occur during the transaction submission.
      return false;
    }
  }

  /// Retrieves the balance of the wallet associated with the provided [walletName].
  ///
  /// Returns the wallet balance as a string.
  ///
  /// Throws an [AuraInternalError] if there's an error while fetching the balance.
  @override
  Future<String> checkWalletBalance() async {
    try {
      String denom = AuraWalletUtil.getDenom(environment);
      String? bech32Address =
          await Storehouse.storage.getWalletAddress(walletName: walletName);

      final req =
          bank.QueryBalanceRequest(address: bech32Address, denom: denom);
      var networkInfo = Storehouse.networkInfo;

      final client =
          bank.QueryClient(networkInfo.gRPCChannel, interceptors: [LogInter()]);

      final response = await client.balance(req);

      return response.balance.amount;
    } catch (e) {
      // Handle any exceptions that might occur while fetching the balance.
      throw AuraInternalError(
          500, 'Error fetching wallet balance: ${e.toString()}');
    }
  }

  Future<bool> checkMnemonic({required String mnemonic}) async {
    return Bip39.validateMnemonic(mnemonic.split(' '));
  }

  /// Retrieves the transaction history of the wallet associated with the provided [walletName].
  ///
  /// Returns a list of [AuraTransaction] objects representing the transaction history.
  ///
  /// Throws an [AuraInternalError] if there's an error while fetching the transaction history.
  @override
  Future<List<AuraTransaction>> checkWalletHistory() async {
    try {
      String? bech32Address =
          await Storehouse.storage.getWalletAddress(walletName: walletName);

      List<AuraTransaction>? listSender = await _getListTransactionByAddress(
          bech32Address, AuraTransactionType.send);
      List<AuraTransaction>? listRecive = await _getListTransactionByAddress(
          bech32Address, AuraTransactionType.recive);

      List<AuraTransaction> listAllTransaction = [];
      listAllTransaction.addAll(listSender ?? []);
      listAllTransaction.addAll(listRecive ?? []);

      listAllTransaction.sort((a, b) {
        DateTime? aDate = DateTime.tryParse(a.timestamp);
        DateTime? bDate = DateTime.tryParse(b.timestamp);
        if (aDate == null || bDate == null) {
          return 0; // Skip
        }

        return aDate.compareTo(bDate);
      });

      return listAllTransaction;
    } catch (e) {
      // Handle any exceptions that might occur while fetching the transaction history.
      throw AuraInternalError(
          501, 'Error fetching wallet history: ${e.toString()}');
    }
  }

  /// Retrieves a list of transactions based on the provided [address] and [transactionType].
  ///
  /// If [transactionType] is [AuraTransactionType.send], it fetches transactions sent from the [address].
  /// If [transactionType] is [AuraTransactionType.recive], it fetches transactions received by the [address].
  ///
  /// Returns a list of [AuraTransaction] objects representing the transactions.
  ///
  /// Returns `null` if there's an error or no transactions are found.
  Future<List<AuraTransaction>?> _getListTransactionByAddress(
      String? address, AuraTransactionType transactionType) async {
    try {
      var networkInfo = Storehouse.networkInfo;
      final request = auraTx.GetTxsEventRequest(
        events: [
          if (transactionType == AuraTransactionType.send)
            "transfer.sender='$address'"
          else if (transactionType == AuraTransactionType.recive)
            "transfer.recipient='$address'"
        ],
        pagination: PageRequest(offset: 0.toInt64(), limit: 100.toInt64()),
      );

      final client = auraTx.ServiceClient(networkInfo.gRPCChannel,
          interceptors: [LogInter()]);

      final GetTxsEventResponse response = await client.getTxsEvent(request);

      List<AuraTransaction> listData =
          AuraWalletHelper.convertToAuraTransaction(
              response.txResponses, transactionType);

      return listData;
    } catch (e, s) {
      // Handle any exceptions that might occur while fetching transactions.
      return null;
    }
  }

  /// Executes an interactive query on a smart contract located at [contractAddress] with the provided [query].
  ///
  /// Throws an [UnimplementedError] if the [contractAddress] is empty or if there are multiple queries in the [query] map.
  ///
  /// Returns the response from the smart contract as a string.
  @override
  Future<String> makeInteractiveQuerySmartContract({
    required String contractAddress,
    required Map<String, dynamic> query,
  }) async {
    // Check if the contract address is empty.
    if (contractAddress.isEmpty) {
      throw AuraInternalError(
          ErrorCode.ContractAddressEmpty, 'Contract address is not empty');
    }

    // Check if there is exactly one query in the map.
    if (query.keys.length != 1) {
      throw AuraInternalError(ErrorCode.InvalidQuery, 'Queries not valid');
    }

    try {
      var networkInfo = Storehouse.networkInfo;
      List<int> queryData = jsonEncode(query).codeUnits;

      final cosMWasm.QueryClient client = cosMWasm.QueryClient(
        networkInfo.gRPCChannel,
        interceptors: [LogInter()],
      );

      final cosMWasm.QuerySmartContractStateRequest request =
          cosMWasm.QuerySmartContractStateRequest(
        address: contractAddress,
        queryData: queryData,
      );

      final cosMWasm.QuerySmartContractStateResponse response =
          await client.smartContractState(request);

      return String.fromCharCodes(response.data);
    } catch (e, s) {
      // Handle any exceptions that might occur during the query.
      throw AuraInternalError(ErrorCode.QueryFailed, 'Query failed: $e');
    }
  }

  /// Executes an interactive write operation on a smart contract located at [contractAddress].
  ///
  /// Throws an [AuraInternalError] with a specific error code and message if any validation fails.
  ///
  /// Returns the transaction hash if the operation is successful.
  @override
  Future<String> makeInteractiveWriteSmartContract({
    required String contractAddress,
    required Map<String, dynamic> executeMessage,
    List<int>? funds,
    int? fee,
  }) async {
    // Validate the contract address.
    if (contractAddress.isEmpty) {
      throw AuraInternalError(
          ErrorCode.ContractAddressEmpty, 'Contract address is not empty');
    }

    // Validate the fee.
    if (fee != null && fee < 200) {
      throw AuraInternalError(ErrorCode.InvalidFee, 'Min fee is 200');
    }

    // Get the denomination from the environment.
    String denom = AuraWalletUtil.getDenom(environment);

    // Load the wallet passphrase.
    String? passPhrase =
        await Storehouse.storage.readWalletPassPhrase(walletName: walletName);

    // Check if the passphrase is null.
    if (passPhrase == null) {
      throw AuraInternalError(
          ErrorCode.PassphraseNotFound, 'Passphrase not found');
    }

    // Derive the wallet from the passphrase.
    final wallet = Wallet.derive(passPhrase.split(' '), Storehouse.networkInfo);

    // Create the message.
    final List<int> msg = jsonEncode(executeMessage).codeUnits;

    List<Coin> coins = List.empty(growable: true);

    // Add funds to the list of coins if funds are provided.
    if (funds != null) {
      coins.addAll(funds.map(
        (e) => Coin.create()
          ..amount = e.toString()
          ..denom = denom,
      ));
    }

    // Get the wallet address.
    String? bech32Address =
        await Storehouse.storage.getWalletAddress(walletName: walletName);

    // Create the execute contract message.
    final cosMWasm.MsgExecuteContract request = cosMWasm.MsgExecuteContract(
      contract: contractAddress,
      sender: bech32Address,
      msg: msg,
      funds: coins,
    );

    // Create the fee.
    final Fee feeData = AuraWalletHelper.createFee(
      amount: (fee ?? 200).toString(),
      environment: environment,
    );

    // Get the network info.
    var networkInfo = Storehouse.networkInfo;

    // Sign the transaction.
    Tx tx = await AuraWalletHelper.signTransaction(
      networkInfo: networkInfo,
      wallet: wallet,
      msgSend: [request],
      fee: feeData,
    );

    // Create the transaction sender.
    final txSender = TxSender.fromNetworkInfo(networkInfo);

    // Broadcast the transaction.
    final response = await txSender.broadcastTx(tx);

    // Check if the transaction was successful.
    if (response.isSuccessful) {
      return response.txhash;
    }

    // If the transaction failed, throw an AuraInternalError with a specific error code and message.
    throw AuraInternalError(
      ErrorCode.TransactionBroadcastFailed,
      'Broadcast transaction error\n${response.rawLog}',
    );
  }

  /// Retrieves the wallet passphrase from the local storage.
  ///
  /// Returns the wallet passphrase if it exists; otherwise, returns null.
  ///
  /// Throws an [AuraInternalError] with a specific error code and message if any error occurs.
  @override
  Future<String?> getWalletPassPhrase() async {
    try {
      return Storehouse.storage.readWalletPassPhrase(walletName: walletName);
    } catch (e) {
      // Handle the error and throw an AuraInternalError with the appropriate error code and message.
      String message =
          e is PlatformException ? '[${e.code}] ${e.message}' : e.toString();
      throw AuraInternalError(ErrorCode.WalletPassphraseError, message);
    }
  }

  /// Creates and sends a transaction to the specified recipient.
  ///
  /// - [toAddress]: The recipient's address.
  /// - [amount]: The amount to send.
  /// - [fee]: The transaction fee.
  /// - [memo]: An optional memo for the transaction.
  ///
  /// Returns a [Tx] object representing the transaction.
  ///
  /// Throws an [AuraInternalError] with a specific error code and message if any error occurs.
  @override
  Future<Tx> makeTransaction({
    required String toAddress,
    required String amount,
    required String fee,
    String? memo,
  }) async {
    String denom = AuraWalletUtil.getDenom(environment);

    // Step #1: Create a message for the transaction.
    final MsgSend message = bank.MsgSend.create()
      ..fromAddress = bech32Address
      ..toAddress = toAddress;
    message.amount.add(Coin.create()
      ..denom = denom
      ..amount = amount);

    // Step #2: Create the transaction fee.
    final Fee feeData =
        AuraWalletHelper.createFee(amount: fee, environment: environment);

    var networkInfo = Storehouse.networkInfo;

    String? passPhrase =
        await Storehouse.storage.readWalletPassPhrase(walletName: walletName);

    if (passPhrase == null) {
      // Handle the case where the passphrase is null and throw an AuraInternalError.
      throw AuraInternalError(ErrorCode.NullPassphrase, "Passphrase is null");
    }
    final wallet = Wallet.derive(passPhrase.split(' '), Storehouse.networkInfo);

    try {
      // Sign the transaction.
      Tx signedTx = await AuraWalletHelper.signTransaction(
        networkInfo: networkInfo,
        wallet: wallet,
        msgSend: [message],
        fee: feeData,
        memo: memo,
      );

      return signedTx;
    } catch (e, s) {
      // Handle any error that occurs during transaction signing.
      String errorMessage =
          e is PlatformException ? '[${e.code}] ${e.message}' : e.toString();
      throw AuraInternalError(ErrorCode.TransactionSigningError, errorMessage);
    }
  }

  /// Verifies the validity of a transaction using its transaction hash.
  ///
  /// - [txHash]: The transaction hash to verify.
  ///
  /// Returns `true` if the transaction is valid, otherwise `false`.
  ///
  /// Throws an [AuraInternalError] with a specific error code and message if any error occurs.
  @override
  Future<bool> verifyTxHash({required String txHash}) async {
    String baseUrl = AuraWalletUtil.getBaseUrl(environment);
    String chainId = AuraWalletUtil.getChainId(environment);

    try {
      HttpClient client = HttpClient();

      final request = await client.getUrl(Uri.parse(
          '$baseUrl/api/v1/transaction?txHash=$txHash&chainid=$chainId'));

      final HttpClientResponse response = await request.close();

      final String data =
          await (response.transform(utf8.decoder).join()).whenComplete(
        () => client.close(),
      );

      List<Map<String, dynamic>> trans =
          List.from(jsonDecode(data)['data']['transactions']);

      if (trans.isEmpty) {
        // Throw an error if no transactions are found.
        throw AuraInternalError(
            ErrorCode.NoTransactionsFound, 'No transactions found');
      }

      Map<String, dynamic> tran =
          Map<String, dynamic>.from(trans[0]['tx_response']);

      // Check if the transaction code is "0" (indicating success).
      return tran['code'] == "0";
    } catch (e) {
      // Handle any error that occurs during verification.
      String errorMessage =
          e is PlatformException ? '[${e.code}] ${e.message}' : e.toString();
      throw AuraInternalError(
          ErrorCode.TransactionVerificationError, errorMessage);
    }
  }
}
