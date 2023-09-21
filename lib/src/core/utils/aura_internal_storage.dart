import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuraInternalStorage {
  late FlutterSecureStorage _storage;

  AuraInternalStorage._() {
    AndroidOptions androidOptions = const AndroidOptions(
      encryptedSharedPreferences: true,
      preferencesKeyPrefix: 'aura_sdk_prefix',
      sharedPreferencesName: 'aura_sdk',
      userAuthenticationRequiredAndroid: UserAuthenticationRequiredAndroid(
        bioMetricTitle: 'Wallet Authentication',
        bioMetricSubTitle: 'You need authentication to access your wallet',
        userAuthenticationTimeout: 10,
      ),
    );
    _storage = FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: IOSOptions(
        iosUserAuthenticationRequired: IOSUserAuthenticationRequired(
          localizedReason: 'You need authentication to access your wallet',
          userAuthenticationTimeout: 10,
        ),
      ),
    );
  }

  static AuraInternalStorage? _internalStorage;

  factory AuraInternalStorage() {
    _internalStorage ??= AuraInternalStorage._();

    return _internalStorage!;
  }

  final IOSOptions _getNonSecureIosOptions = const IOSOptions();
  final AndroidOptions _getNonSecureAndroidOptions = const AndroidOptions(
    encryptedSharedPreferences: true,
    preferencesKeyPrefix: 'aura_sdk_prefix_non_secure',
    sharedPreferencesName: 'aura_sdk_non_secure',
  );

  Future<void> saveAuraMnemonicOrPrivateKey(
      String address, String privateKey) async {
    return _storage.write(
      key: address,
      value: privateKey,
    );
  }

  Future<String?> readPrivateKey(String address) async {
    return _storage.read(key: address);
  }

  Future<bool> checkExistsPrivateKey(String address) async {
    return _storage.containsKey(key: address);
  }

  Future<void> removePrivateKey(String address) async {
    return _storage.delete(key: address);
  }

  Future<void> saveBech32Address(String bech32Address) async {
    return _storage.write(
      key: 'bech32Address',
      value: bech32Address,
      iOptions: _getNonSecureIosOptions,
      aOptions: _getNonSecureAndroidOptions,
    );
  }

  Future<String?> readBech32Address() async {
    return _storage.read(
      key: 'bech32Address',
      iOptions: _getNonSecureIosOptions,
      aOptions: _getNonSecureAndroidOptions,
    );
  }

  Future<bool> checkExistsBech32Android() async {
    return _storage.containsKey(
      key: 'bech32Address',
      iOptions: _getNonSecureIosOptions,
      aOptions: _getNonSecureAndroidOptions,
    );
  }

  Future<void> removeBech32Address() async {
    return _storage.delete(
      key: 'bech32Address',
      iOptions: _getNonSecureIosOptions,
      aOptions: _getNonSecureAndroidOptions,
    );
  }
}
