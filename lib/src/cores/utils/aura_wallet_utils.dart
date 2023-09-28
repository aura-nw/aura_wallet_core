import 'package:aura_wallet_core/config_options/biometric_options.dart';
import 'package:aura_wallet_core/src/cores/aura_internal_storage.dart';

// A utility class for handling configuration related to the Aura blockchain network.

class AuraWalletUtil {
  // Returns network information based on the specified environment.
  AuraWalletUtil._();

  // Creates and returns an instance of AuraInternalStorage with optional biometric options.
  static AuraInternalStorage createStorage(BiometricOptions? biometricOptions) {
    return AuraInternalStorage(biometricOptions);
  }
}
