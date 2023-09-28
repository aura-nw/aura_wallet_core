import 'dart:convert';

import 'package:alan/alan.dart';
import 'package:aura_wallet_core/config_options/enviroment_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// [IAuraWalletCoreConfigServiceE] is extension of [IAuraWalletCoreConfigService]
extension IAuraWalletCoreConfigServiceE on IAuraWalletCoreConfigService {
  // This method return to a string as verify txHash url
  String verifyTransactionUrl(String txHash) {
    return '$baseUrl/api/v1/transaction?txHash=$txHash&chainid=$chainId';
  }
}

/// The [IAuraWalletCoreConfigService]` is interface to define base static config from Aura SDK Core
/// Providing access to essential configuration elements within the Aura Wallet Core.
abstract class IAuraWalletCoreConfigService {

  // This method must call when SDK initialized
  // It will detect to load config from env file corresponding
  Future<void> init(AuraEnvironment environment);

  // Get becH32Config from configuration
  String get becH32Config;

  // Get chainId from configuration
  String get chainId;

  // Get baseUrl from configuration
  String get baseUrl;

  // Get lcdHost from configuration
  String get lcdHost;

  // Get grpcHost from configuration
  String get grpcHost;

  // Get grpcPort from configuration
  int get grpcPort;

  // Get deNom from configuration
  String get deNom;

  // Get decimal from configuration
  int get decimal;

  // Get gasLimit from configuration
  int get gasLimit;

  // Get minFee from configuration
  int get minFee;

  // Get network info from configuration
  NetworkInfo get networkInfo;
}


/// The [AuraWalletCoreConfigService] class is implementation [IAuraWalletCoreConfigService] interface used for SDK
class AuraWalletCoreConfigService implements IAuraWalletCoreConfigService {
  const AuraWalletCoreConfigService();

  Map<String, String> get env => dotenv.env;

  Map<String, dynamic> get _chainInfo => jsonDecode(
        env['CHAIN_INFO']!,
      );

  Map<String, dynamic> get _netWorkInfo => jsonDecode(
        env['NET_WORK_INFO']!,
      );

  Map<String, dynamic> get _coin => _chainInfo['coin'];

  @override
  String get baseUrl => _netWorkInfo['baseUrl'];

  @override
  String get becH32Config => _netWorkInfo['bech32Config'];

  @override
  String get chainId => _netWorkInfo['chainId'];

  @override
  String get deNom => _coin['denom'];

  @override
  int get decimal => _coin['decimal'];

  @override
  String get grpcHost => _netWorkInfo['grpcHost'];

  @override
  Future<void> init(AuraEnvironment environment) async {
    const String baseAssetUri = 'packages/aura_wallet_core/assets/';

    switch (environment) {
      case AuraEnvironment.testNet:
        await dotenv.load(
            fileName: '$baseAssetUri.env.testnet');
        break;
      case AuraEnvironment.euphoria:
        await dotenv.load(
            fileName: '$baseAssetUri.env.euphoria');
        break;
      case AuraEnvironment.mainNet:
        await dotenv.load(
            fileName: '$baseAssetUri.env.mainnet');
        break;
    }
  }

  @override
  String get lcdHost => _netWorkInfo['lcdHost'];

  @override
  int get gasLimit => int.parse(env['GAS_LIMIT']!);

  @override
  NetworkInfo get networkInfo => NetworkInfo(
        bech32Hrp: becH32Config,
        lcdInfo: LCDInfo(host: lcdHost),
        grpcInfo: GRPCInfo(
          host: grpcHost,
          port: grpcPort,
        ),
      );

  @override
  int get grpcPort => int.parse(_netWorkInfo['grpcPort']);

  @override
  int get minFee => int.parse(env['MIN_FEE']!);
}
