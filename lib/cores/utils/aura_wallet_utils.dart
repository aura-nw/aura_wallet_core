import 'package:alan/alan.dart';
import 'package:aura_wallet_core/config_options/biometric_options.dart';
import 'package:aura_wallet_core/config_options/enviroment_options.dart';
import 'package:aura_wallet_core/cores/aura_internal_storage.dart';

// A utility class for handling configuration related to the Aura blockchain network.

class AuraWalletUtil {
  // Returns network information based on the specified environment.
  AuraWalletUtil._();
  static NetworkInfo getNetworkInfo(AuraEnvironment environment) {
    switch (environment) {
      case AuraEnvironment.testNet:
        return NetworkInfo(
            bech32Hrp: 'aura',
            lcdInfo: LCDInfo(
              host: 'https://lcd.serenity.aura.network',
            ),
            grpcInfo: GRPCInfo(
              host: 'http://grpc.serenity.aura.network',
              port: 9092,
            ));
      case AuraEnvironment.euphoria:
        return NetworkInfo(
          bech32Hrp: 'aura',
          lcdInfo: LCDInfo(
            host: 'https://lcd.euphoria.aura.network',
          ),
          grpcInfo: GRPCInfo(
            host: 'http://grpc.euphoria.aura.network',
            port: 9090,
          ),
        );

      case AuraEnvironment.mainNet:
        return NetworkInfo(
            bech32Hrp: 'aura',
            lcdInfo: LCDInfo(
              host: 'https://lcd.aura.network',
            ),
            grpcInfo: GRPCInfo(
              host: 'https://grpc.aura.network',
            ));
    }
  }

  // Creates and returns an instance of AuraInternalStorage with optional biometric options.
  static AuraInternalStorage createStorage(BiometricOptions? biometricOptions) {
    return AuraInternalStorage(biometricOptions);
  }

// Returns the denomination based on the specified environment.
  static String getDenom(AuraEnvironment environment) {
    if (environment == AuraEnvironment.euphoria) {
      return 'ueaura';
    }
    return "uaura";
  }

  // Returns the base URL for a given environment.
  static String getBaseUrl(AuraEnvironment environment) {
    switch (environment) {
      case AuraEnvironment.testNet:
        return 'https://indexer.dev.aurascan.io';
      case AuraEnvironment.euphoria:
        return 'https://indexer.staging.aurascan.io';
      case AuraEnvironment.mainNet:
        return 'https://horoscope.aura.network';
    }
  }

  // Returns the chain ID based on the specified environment.
  static String getChainId(AuraEnvironment environment) {
    switch (environment) {
      case AuraEnvironment.testNet:
        return 'serenity-testnet-001';
      case AuraEnvironment.euphoria:
        return 'euphoria-2';
      case AuraEnvironment.mainNet:
        return 'xstaxy-1';
    }
  }
}
