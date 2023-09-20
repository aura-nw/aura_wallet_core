import 'dart:convert';
import 'dart:io';
import 'package:alan/proto/cosmos/bank/v1beta1/export.dart';
import 'package:alan/proto/cosmos/bank/v1beta1/export.dart' as bank;
import 'package:alan/proto/cosmwasm/wasm/v1/export.dart' as cosMWasm;
import 'package:alan/proto/cosmos/tx/v1beta1/export.dart' as auraTx;

import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:mobile_wallet_core/mobile_wallet_core.dart';
import 'core/utils/aura_inapp_wallet_helper.dart';
import 'core/utils/aura_internal_storage.dart';
import 'core/utils/grpc_logger.dart';

class AuraWalletCoreImpl implements AuraWalletCore {
  final AuraWalletCoreEnvironment environment;

  late NetworkInfo networkInfo;

  AuraWalletCoreImpl({
    this.environment = AuraWalletCoreEnvironment.testNet,
  }) {
    switch (environment) {
      case AuraWalletCoreEnvironment.testNet:
        networkInfo = NetworkInfo(
            bech32Hrp: 'aura',
            lcdInfo: LCDInfo(
              host: 'https://lcd.serenity.aura.network',
            ),
            grpcInfo: GRPCInfo(
              host: 'http://grpc.serenity.aura.network',
              port: 9092,
            ));
        break;
      case AuraWalletCoreEnvironment.euphoria:
        networkInfo = NetworkInfo(
          bech32Hrp: 'aura',
          lcdInfo: LCDInfo(
            host: 'https://lcd.euphoria.aura.network',
          ),
          grpcInfo: GRPCInfo(
            host: 'http://grpc.euphoria.aura.network',
            port: 9090,
          ),
        );
        break;
      case AuraWalletCoreEnvironment.mainNet:
        networkInfo = NetworkInfo(
            bech32Hrp: 'aura',
            lcdInfo: LCDInfo(
              host: 'https://lcd.aura.network',
            ),
            grpcInfo: GRPCInfo(
              host: 'https://grpc.aura.network',
            ));
        break;
    }
  }

  @override
  Future<AuraFullInfoWallet> createRandomHDWallet() async {
    List<String> mnemonic2 = Bip39.generateMnemonic(strength: 256);
    final Wallet wallet = Wallet.derive(mnemonic2, networkInfo);

    await AuraInternalStorage()
        .saveAuraMnemonicOrPrivateKey(mnemonic2.join(' '));

    return AuraFullInfoAuraWalletImpl(
      auraWallet: AuraWalletImpl(
        wallet: wallet,
        environment: environment,
      ),
      mnemonic: mnemonic2.join(' '),
      privateKey: HEX.encode(wallet.privateKey),
    );
  }

  @override
  Future<AuraWallet> restoreHDWallet(
      {required String key, bool isNeedSave = true}) async {
    bool isMnemonic = AuraInAppWalletHelper.checkMnemonic(mnemonic: key);
    if (!isMnemonic) {
      List<int> privateKey = HEX.decode(key);

      Uint8List data = Uint8List.fromList(privateKey);

      bool isPrivateKey = AuraInAppWalletHelper.checkPrivateKey(data);

      if (!isPrivateKey) {
        throw AuraInternalError(1, 'key is not valid');
      }

      if (isNeedSave) {
        await AuraInternalStorage().saveAuraMnemonicOrPrivateKey(key);
      }

      final wallet = Wallet.import(networkInfo, data);

      return AuraWalletImpl(
        wallet: wallet,
        environment: environment,
      );
    } else {
      /// The [Wallet.derive] function take about 500 milisecond
      final wallet = Wallet.derive(key.split(' '), networkInfo);

      if (isNeedSave) {
        await AuraInternalStorage().saveAuraMnemonicOrPrivateKey(key);
      }

      return AuraWalletImpl(
        wallet: wallet,
        environment: environment,
      );
    }
  }

  @override
  Future<AuraWallet?> loadCurrentWallet() async {
    try {
      String? key = await AuraInternalStorage().readPrivateKey();

      if (key == null) {
        return null;
      }

      return await restoreHDWallet(
        key: key,
        isNeedSave: false,
      );
    } catch (e) {
      String message =
          e is PlatformException ? '[${e.code}] ${e.message}' : e.toString();
      throw AuraInternalError(3, message);
    }
  }
}

class AuraWalletImpl extends AuraWallet {
  const AuraWalletImpl({
    required Wallet wallet,
    required AuraWalletCoreEnvironment environment,
  }) : super(
          wallet: wallet,
          environment: environment,
        );

  NetworkInfo get networkInfo => wallet.networkInfo;

  @override
  Future<bool> submitTransaction({required Tx signedTransaction}) async {
    // 4. Broadcast the transaction
    final txSender = TxSender.fromNetworkInfo(networkInfo);

    final response = await txSender.broadcastTx(signedTransaction);

    // Check the result
    if (response.isSuccessful) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<String> checkWalletBalance() async {
    String denom = "uaura";
    if (environment == AuraWalletCoreEnvironment.euphoria) {
      denom = 'ueaura';
    }

    final req =
        bank.QueryBalanceRequest(address: wallet.bech32Address, denom: denom);
    final client =
        bank.QueryClient(networkInfo.gRPCChannel, interceptors: [LogInter()]);

    final response = await client.balance(req);

    return response.balance.amount;
  }

  Future<bool> checkMnemonic({required String mnemonic}) async {
    return Bip39.validateMnemonic(mnemonic.split(' '));
  }

  @override
  Future<List<AuraTransaction>> checkWalletHistory() async {
    List<AuraTransaction>? listSender = await _getListTransactionByAddress(
        wallet.bech32Address, AuraTransactionType.send);
    List<AuraTransaction>? listRecive = await _getListTransactionByAddress(
        wallet.bech32Address, AuraTransactionType.recive);

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
  }

  Future<List<AuraTransaction>?> _getListTransactionByAddress(
      String address, AuraTransactionType transactionType) async {
    if (transactionType == AuraTransactionType.send) {
      final request = auraTx.GetTxsEventRequest(events: [
        "transfer.sender='$address'",
      ], pagination: PageRequest(offset: 0.toInt64(), limit: 100.toInt64()));
      try {
        final client = auraTx.ServiceClient(networkInfo.gRPCChannel,
            interceptors: [LogInter()]);
        final GetTxsEventResponse response = await client.getTxsEvent(request);

        List<AuraTransaction> listData =
            AuraInAppWalletHelper.convertToAuraTransaction(
                response.txResponses, transactionType);
        return listData;
      } catch (e, s) {}
      return null;
    } else if (transactionType == AuraTransactionType.recive) {
      final request = auraTx.GetTxsEventRequest(events: [
        "transfer.recipient='$address'",
      ], pagination: PageRequest(offset: 0.toInt64(), limit: 100.toInt64()));
      try {
        final client = auraTx.ServiceClient(networkInfo.gRPCChannel,
            interceptors: [LogInter()]);
        final GetTxsEventResponse response = await client.getTxsEvent(request);

        List<AuraTransaction> listData =
            AuraInAppWalletHelper.convertToAuraTransaction(
                response.txResponses, transactionType);
        return listData;
      } catch (e, s) {}
      return null;
    }

    return null;
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

    String denom = "uaura";
    if (environment == AuraWalletCoreEnvironment.euphoria) {
      denom = 'ueaura';
    }

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

    final cosMWasm.MsgExecuteContract request = cosMWasm.MsgExecuteContract(
      contract: contractAddress,
      sender: wallet.bech32Address,
      msg: msg,
      funds: coins,
    );

    ///2 : Create fee
    final Fee feeData = AuraInAppWalletHelper.createFee(
        amount: (fee ?? 200).toString(), environment: environment);

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
      return AuraInternalStorage().readPrivateKey();
    } catch (e) {
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
    String denom = "uaura";
    if (environment == AuraWalletCoreEnvironment.euphoria) {
      denom = 'ueaura';
    }
    //

    // Step #1 : create msgSend
    final MsgSend message = bank.MsgSend.create()
      ..fromAddress = wallet.bech32Address
      ..toAddress = toAddress;
    message.amount.add(Coin.create()
      ..denom = denom
      ..amount = amount);

    // Step #2 : create fee
    final Fee feeData =
        AuraInAppWalletHelper.createFee(amount: fee, environment: environment);

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

  @override
  Future<bool> removeCurrentWallet() async {
    try {
      await AuraInternalStorage().removePrivateKey();

      return true;
    } catch (e) {
      String message =
          e is PlatformException ? '[${e.code}] ${e.message}' : e.toString();
      throw AuraInternalError(2, message);
    }
  }
}

class AuraFullInfoAuraWalletImpl extends AuraFullInfoWallet {
  AuraFullInfoAuraWalletImpl({
    required super.mnemonic,
    required super.privateKey,
    required super.auraWallet,
  });
}
