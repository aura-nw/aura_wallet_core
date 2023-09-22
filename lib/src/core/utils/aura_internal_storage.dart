import 'package:aura_wallet_core/src/config_options/biometric_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuraInternalStorage {
  late FlutterSecureStorage _storage;

  AuraInternalStorage._(BiometricOptions? biometricOptions) {
    UserAuthenticationRequiredAndroid? authenticationRequiredAndroid;
    IOSUserAuthenticationRequired? authenticationRequiredIOS;
    if (biometricOptions != null) {
      authenticationRequiredAndroid = UserAuthenticationRequiredAndroid(
          bioMetricSubTitle: biometricOptions.requestSubtitle,
          bioMetricTitle: biometricOptions.requestTitle,
          userAuthenticationTimeout: biometricOptions.authenticationTimeOut);

      authenticationRequiredIOS = IOSUserAuthenticationRequired(
        localizedReason: biometricOptions.requestSubtitle,
        userAuthenticationTimeout: biometricOptions.authenticationTimeOut,
      );
    }

    AndroidOptions androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
      preferencesKeyPrefix: 'aura_sdk_prefix',
      sharedPreferencesName: 'aura_sdk',
      userAuthenticationRequiredAndroid: authenticationRequiredAndroid,
    );
    _storage = FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: IOSOptions(
        iosUserAuthenticationRequired: authenticationRequiredIOS,
      ),
    );
  }

  factory AuraInternalStorage(BiometricOptions? biometricOptions) {
    return AuraInternalStorage._(biometricOptions);
  }

  final IOSOptions _getNonSecureIosOptions = const IOSOptions();
  final AndroidOptions _getNonSecureAndroidOptions = const AndroidOptions(
    encryptedSharedPreferences: true,
    preferencesKeyPrefix: 'aura_sdk_prefix_non_secure',
    sharedPreferencesName: 'aura_sdk_non_secure',
  );

  Future<void> saveWalletToStorage(
      {required String walletName,
      required String walletAddress,
      required String passphrase}) async {
    await _storage.write(
        key: walletName,
        value: walletAddress,
        aOptions: _getNonSecureAndroidOptions,
        iOptions: _getNonSecureIosOptions);

    await _storage.write(key: walletAddress, value: passphrase);
  }

  Future<String?> loadWalletPassPhrase({required String walletName}) async {
    String? walletAddress = await _storage.read(
        key: walletName,
        aOptions: _getNonSecureAndroidOptions,
        iOptions: _getNonSecureIosOptions);
    if (walletAddress == null) {
      return null;
    }

    String? passPhrase = await _storage.read(key: walletAddress);
    return passPhrase;
  }

  Future<String?> getWalletAddress({required String walletName}) async {
    String? walletAddress = await _storage.read(
        key: walletName,
        aOptions: _getNonSecureAndroidOptions,
        iOptions: _getNonSecureIosOptions);
    return walletAddress;
  }

  // Future<void> saveAuraMnemonicOrPrivateKey(
  //     String address, String privateKey) async {
  //   return _storage.write(
  //     key: address,
  //     value: privateKey,
  //   );
  // }

  // Future<String?> readPrivateKey(String address) async {
  //   return _storage.read(key: address);
  // }

  // Future<bool> checkExistsPrivateKey(String address) async {
  //   return _storage.containsKey(key: address);
  // }

  // Future<void> removePrivateKey(String address) async {
  //   return _storage.delete(key: address);
  // }

  // Future<void> saveBech32Address(String bech32Address) async {
  //   return _storage.write(
  //     key: 'bech32Address',
  //     value: bech32Address,
  //     iOptions: _getNonSecureIosOptions,
  //     aOptions: _getNonSecureAndroidOptions,
  //   );
  // }

  // Future<String?> readBech32Address() async {
  //   return _storage.read(
  //     key: 'bech32Address',
  //     iOptions: _getNonSecureIosOptions,
  //     aOptions: _getNonSecureAndroidOptions,
  //   );
  // }

  // Future<bool> checkExistsBech32Android() async {
  //   return _storage.containsKey(
  //     key: 'bech32Address',
  //     iOptions: _getNonSecureIosOptions,
  //     aOptions: _getNonSecureAndroidOptions,
  //   );
  // }

  // Future<void> removeBech32Address() async {
  //   return _storage.delete(
  //     key: 'bech32Address',
  //     iOptions: _getNonSecureIosOptions,
  //     aOptions: _getNonSecureAndroidOptions,
  //   );
  // }
}
