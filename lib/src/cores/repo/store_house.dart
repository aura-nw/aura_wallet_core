import 'package:alan/alan.dart';
import 'package:aura_wallet_core/config_options/config_options.dart';
import 'package:aura_wallet_core/config_options/enviroment_options.dart';
import 'package:aura_wallet_core/src/cores/aura_internal_storage.dart';

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

  // Stores the configuration options for the Aura Wallet Core.
  static late ConfigOption configOption;
}
