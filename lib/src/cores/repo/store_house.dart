import 'package:alan/alan.dart';
import 'package:aura_wallet_core/config_options/biometric_options.dart';
import 'package:aura_wallet_core/config_options/enviroment_options.dart';
import 'package:aura_wallet_core/src/cores/aura_internal_storage.dart';
import 'package:aura_wallet_core/src/cores/utils/aura_wallet_utils.dart';

/// The `Storehouse` class serves as a central hub for managing dependencies and
/// providing access to essential configuration elements within the Aura Wallet Core.
class Storehouse {
  Storehouse._(); // Private constructor prevents direct instantiation.

  // Stores the current environment configuration for the Aura Wallet Core.
  static late AuraEnvironment environment;

  // Stores network information necessary for communication with the Aura Network.
  static late NetworkInfo networkInfo;

  // Stores the instance of `AuraInternalStorage` for data storage and retrieval.
  static late AuraInternalStorage storage;

  /// Initializes the dependency injection for the Aura Wallet Core.
  ///
  /// This method should be called during the application's setup phase to
  /// configure the environment, network information, and storage options.
  ///
  /// Parameters:
  ///   - [environment]: The Aura environment (testNet, euphoria, mainNet).
  ///   - [biometricOptions]: Optional biometric authentication options.
  static void makeDI(
    AuraEnvironment environment,
    BiometricOptions? biometricOptions,
  ) {
    // Set the current environment.
    Storehouse.environment = environment;

    // Retrieve and store network information based on the selected environment.
    Storehouse.networkInfo = AuraWalletUtil.getNetworkInfo(environment);

    // Initialize the storage instance with optional biometric options.
    Storehouse.storage = AuraInternalStorage(biometricOptions);
  }
}
