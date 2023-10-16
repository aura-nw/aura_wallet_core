import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../config_options/biometric_options.dart';

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
      required String passPhraseOrPrivateKey}) async {
    await _storage.write(
        key: walletName,
        value: walletAddress,
        aOptions: _getNonSecureAndroidOptions,
        iOptions: _getNonSecureIosOptions);

    await _storage.write(key: walletAddress, value: passPhraseOrPrivateKey);
  }

  Future<String?> getWalletPassPhrase({required String walletName}) async {
    String? walletAddress = await getWalletAddress(walletName: walletName);
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

  Future<void> deleteWallet({required String walletName}) async {
    final String? walletAddress =
        await getWalletAddress(walletName: walletName);

    if (walletAddress != null) {
      await _storage.delete(
          key: walletName,
          aOptions: _getNonSecureAndroidOptions,
          iOptions: _getNonSecureIosOptions);

      await _storage.delete(
        key: walletAddress,
      );
    }
  }
}
