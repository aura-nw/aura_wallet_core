import 'package:alan/alan.dart';
import 'package:aura_wallet_core/aura_environment.dart';
import 'package:aura_wallet_core/src/config_options/biometric_options.dart';
import 'package:aura_wallet_core/src/core/utils/aura_internal_storage.dart';

class AuraWalletUtil {
  AuraWalletUtil._();
  static NetworkInfo getNetworkInfo(AuraWalletCoreEnvironment environment) {
    switch (environment) {
      case AuraWalletCoreEnvironment.testNet:
        return NetworkInfo(
            bech32Hrp: 'aura',
            lcdInfo: LCDInfo(
              host: 'https://lcd.serenity.aura.network',
            ),
            grpcInfo: GRPCInfo(
              host: 'http://grpc.serenity.aura.network',
              port: 9092,
            ));
      case AuraWalletCoreEnvironment.euphoria:
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

      case AuraWalletCoreEnvironment.mainNet:
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

  static AuraInternalStorage createStorage(BiometricOptions? biometricOptions) {
    return AuraInternalStorage(biometricOptions);
  }

  static String getDenom(AuraWalletCoreEnvironment environment) {
    if (environment == AuraWalletCoreEnvironment.euphoria) {
      return 'ueaura';
    }
    return "uaura";
    ;
  }
}
