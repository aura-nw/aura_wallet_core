import 'package:aura_wallet_core/aura_environment.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';

class AppGlobal {
  static late AuraWalletCore _sdk;

  static AuraWalletCore get sdkCore => _sdk;

  static bool _initialized = false;

  static void init(
      AuraWalletCoreEnvironment environment, BiometricOptions ?options) {

    if(_initialized) return;

    _sdk = AuraWalletCore.create(
      environment: environment,
      biometricOptions: options,
    );

    _initialized = true;
  }
}
