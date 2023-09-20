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

  Future<void> saveAuraMnemonicOrPrivateKey(String privateKey) async {
    return _storage.write(
      key: 'privateKey',
      value: privateKey,
    );
  }

  Future<String?> readPrivateKey() async {
    return _storage.read(key: 'privateKey');
  }

  Future<bool> checkExistsPrivateKey() async {
    return _storage.containsKey(key: 'privateKey');
  }

  Future<void> removePrivateKey() async {
    return _storage.delete(key: 'privateKey');
  }
}
