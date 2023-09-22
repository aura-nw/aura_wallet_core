import 'dart:convert';
import 'dart:io';

import 'package:alan/alan.dart';
import 'package:aura_wallet_core/src/utils/aura_wallet_utils.dart';
import 'package:flutter/services.dart';

import '../../aura_environment.dart';
import '../../wallet_objects.dart';

import 'package:alan/proto/cosmos/bank/v1beta1/export.dart';
import 'package:alan/proto/cosmos/bank/v1beta1/export.dart' as bank;
import 'package:alan/proto/cosmwasm/wasm/v1/export.dart' as cosMWasm;
import 'package:alan/proto/cosmos/tx/v1beta1/export.dart' as auraTx;

import '../core/exceptions/aura_internal_exception.dart';
import '../core/repo/di.dart';
import '../core/utils/aura_inapp_wallet_helper.dart';
import '../core/utils/grpc_logger.dart';

class AuraWalletImpl extends AuraWallet {
  const AuraWalletImpl({
    required String walletName,
    required String bech32Address,
    required AuraWalletCoreEnvironment environment,
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
          AuraInAppWalletHelper.convertToAuraTransaction(
              response.txResponses, transactionType);

      return listData;
    } catch (e, s) {
      // Handle any exceptions that might occur while fetching transactions.
      // You may want to log the error or handle it differently based on your application's needs.
      return null;
    }
  }

  @override
  Future<String> makeInteractiveQuerySmartContract({
    required String contractAddress,
    required Map<String, dynamic> query,
  }) async {
    if (contractAddress.isEmpty) {
      throw UnimplementedError('Contract address is not empty');
    }

    ///validate queries
    if (query.keys.toList().length != 1) {
      throw UnimplementedError('Queries not valid');
    }
    var networkInfo = Storehouse.networkInfo;
    List<int> queryData = jsonEncode(query).codeUnits;

    final cosMWasm.QueryClient client = cosMWasm.QueryClient(
        networkInfo.gRPCChannel,
        interceptors: [LogInter()]);

    final cosMWasm.QuerySmartContractStateRequest request =
        cosMWasm.QuerySmartContractStateRequest(
      address: contractAddress,
      queryData: queryData,
    );

    final cosMWasm.QuerySmartContractStateResponse response =
        await client.smartContractState(request);

    return String.fromCharCodes(response.data);
  }

  @override
  Future<String> makeInteractiveWriteSmartContract({
    required String contractAddress,
    required Map<String, dynamic> executeMessage,
    List<int>? funds,
    int? fee,
  }) async {
    ///Validator
    ///
    if (contractAddress.isEmpty) {
      throw AuraInternalError(4, 'Contract address is not empty');
    }

    if (fee != null) {
      if (fee < 200) {
        throw AuraInternalError(5, 'Min fee is 200');
      }
    }

    String denom = AuraWalletUtil.getDenom(environment);

    String? passPhrase =
        await Storehouse.storage.loadWalletPassPhrase(walletName: walletName);

    if (passPhrase == null) {
      /// Todo throw exception
      throw AuraInternalError(111, "message");
    }
    final wallet = Wallet.derive(passPhrase.split(' '), Storehouse.networkInfo);

    ///1 : Create message
    ///
    final List<int> msg = jsonEncode(executeMessage).codeUnits;

    List<Coin> coins = List.empty(growable: true);

    if (funds != null) {
      coins.addAll(funds.map(
        (e) => Coin.create()
          ..amount = e.toString()
          ..denom = denom,
      ));
    }
    String? bech32Address =
        await Storehouse.storage.getWalletAddress(walletName: walletName);

    final cosMWasm.MsgExecuteContract request = cosMWasm.MsgExecuteContract(
      contract: contractAddress,
      sender: bech32Address,
      msg: msg,
      funds: coins,
    );

    ///2 : Create fee
    final Fee feeData = AuraInAppWalletHelper.createFee(
        amount: (fee ?? 200).toString(), environment: environment);

    var networkInfo = Storehouse.networkInfo;

    ///3 : Create and sign transaction
    Tx tx = await AuraInAppWalletHelper.signTransaction(
      networkInfo: networkInfo,
      wallet: wallet,
      msgSend: [request],
      fee: feeData,
    );

    ///4: create tx sender
    final txSender = TxSender.fromNetworkInfo(networkInfo);

    ///5: broadcast transaction
    final response = await txSender.broadcastTx(tx);

    if (response.isSuccessful) {
      return response.txhash;
    }
    throw AuraInternalError(
        150, 'Broadcast transaction error\n${response.rawLog}');
  }

  @override
  Future<String?> getCurrentMnemonicOrPrivateKey() async {
    try {
      return Storehouse.storage.loadWalletPassPhrase(walletName: walletName);
    } catch (e) {
      /// Todo handle error
      String message =
          e is PlatformException ? '[${e.code}] ${e.message}' : e.toString();
      throw AuraInternalError(2, message);
    }
  }

  @override
  Future<Tx> makeTransaction({
    required String toAddress,
    required String amount,
    required String fee,
    String? memo,
  }) async {
    String denom = AuraWalletUtil.getDenom(environment);
    //

    // Step #1 : create msgSend
    final MsgSend message = bank.MsgSend.create()
      ..fromAddress = bech32Address
      ..toAddress = toAddress;
    message.amount.add(Coin.create()
      ..denom = denom
      ..amount = amount);

    // Step #2 : create fee
    final Fee feeData =
        AuraInAppWalletHelper.createFee(amount: fee, environment: environment);

    var networkInfo = Storehouse.networkInfo;

    String? passPhrase =
        await Storehouse.storage.loadWalletPassPhrase(walletName: walletName);

    if (passPhrase == null) {
      /// Todo throw exception
      throw AuraInternalError(111, "message");
    }
    final wallet = Wallet.derive(passPhrase.split(' '), Storehouse.networkInfo);

    Tx a = await AuraInAppWalletHelper.signTransaction(
      networkInfo: networkInfo,
      wallet: wallet,
      msgSend: [message],
      fee: feeData,
      memo: memo,
    );
    return a;
  }

  @override
  Future<bool> verifyTxHash({required String txHash}) async {
    String baseUrl = '';
    String chainId = '';

    switch (environment) {
      case AuraWalletCoreEnvironment.testNet:
        baseUrl = 'https://indexer.dev.aurascan.io';
        chainId = 'serenity-testnet-001';
        break;
      case AuraWalletCoreEnvironment.euphoria:
        baseUrl = 'https://indexer.staging.aurascan.io';
        chainId = 'euphoria-2';
        break;
      case AuraWalletCoreEnvironment.mainNet:
        baseUrl = 'https://horoscope.aura.network';
        chainId = 'xstaxy-1';
        break;
    }
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
      throw AuraInternalError(3, 'Wait save transactions');
    }

    Map<String, dynamic> tran =
        Map<String, dynamic>.from(trans[0]['tx_response']);

    return tran['code'] == "0";
  }
}
