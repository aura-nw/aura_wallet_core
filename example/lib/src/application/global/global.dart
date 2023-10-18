import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:aura_wallet_core/config_options/biometric_options.dart';
import 'package:aura_wallet_core/config_options/environment_options.dart';

class AppGlobal {
  static late AuraWalletCore _sdk;

  static AuraWalletCore get sdkCore => _sdk;

  static bool _initialized = false;

  static void init(AuraEnvironment environment, BiometricOptions? options) {
    if (_initialized) return;

    _sdk = AuraWalletCore.create(
      environment: environment,
      biometricOptions: options,
    );

    _initialized = true;
  }
}
