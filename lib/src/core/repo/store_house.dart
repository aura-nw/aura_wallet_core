import 'package:alan/alan.dart';
import 'package:aura_wallet_core/src/config_options/biometric_options.dart';
import 'package:aura_wallet_core/src/env/env.dart';
import 'package:aura_wallet_core/src/utils/aura_wallet_utils.dart';
import 'package:aura_wallet_core/storage_util.dart';

class Storehouse {
  Storehouse._();

  static late AuraWalletCoreEnvironment environment;
  static late NetworkInfo networkInfo;
  static late AuraInternalStorage storage;

  static void makeDI(
    AuraWalletCoreEnvironment environment,
    BiometricOptions? biometricOptions,
  ) {
    Storehouse.environment = environment;
    Storehouse.networkInfo = AuraWalletUtil.getNetworkInfo(environment);
    Storehouse.storage = AuraInternalStorage(biometricOptions);
  }
}
