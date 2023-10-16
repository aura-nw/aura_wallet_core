import 'package:aura_wallet_core/config_options/config_options.dart';
import 'package:aura_wallet_core/config_options/environment_options.dart';
import 'package:aura_wallet_core/src/aura_internal_wallet_impl.dart';
import 'package:aura_wallet_core/src/cores/aura_internal_storage.dart';
import 'package:aura_wallet_core/src/cores/exceptions/aura_internal_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:mockito/annotations.dart';

import 'aura_wallet_core_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AuraInternalStorage>()])
void main() async {
  const bech32Address = "aura108t9nyamc72zhkugrpt9dqp25la6u4gvzhu2rd";
  late AuraWalletCore auraWalletCore;
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // anything else you need to setup
    auraWalletCore = AuraWalletCoreImpl(
      environment: AuraEnvironment.euphoria,
      configOption: const ConfigOption(isEnableLog: false),
      internalStorage: MockAuraInternalStorage(),
    );

    await Future.delayed(const Duration(seconds: 1));
  });
  group('AuraWalletCore - restoreHDWallet', () {
    test('Restoring wallet from mnemonic', () async {
      const mnemonic =
          'cash physical maple glove patrol step able move this flash flip march';

      final wallet = await auraWalletCore.restoreHDWallet(
        passPhraseOrPrivateKey: mnemonic,
        walletName: 'TestWallet',
      );

      expect(wallet, isNotNull);
      expect(wallet.bech32Address, bech32Address);
      // Add more assertions based on your requirements
    });

    test('Restoring wallet from private key', () async {
      const privateKey =
          '9096ca41cff39a0f7bfcae408af3b2f4fa9371aa4a1a6f0b5fac2f80f9b4f27b';

      final wallet = await auraWalletCore.restoreHDWallet(
        passPhraseOrPrivateKey: privateKey,
        walletName: 'TestWallet',
      );

      expect(wallet, isNotNull);
      expect(wallet.bech32Address, bech32Address);
      // Add more assertions based on your requirements
    });

    test('Invalid passphrase should throw an error', () async {
      const invalidMnemonic = 'invalid mnemonic phrase';

      expect(
        () async => await auraWalletCore.restoreHDWallet(
          passPhraseOrPrivateKey: invalidMnemonic,
          walletName: 'TestWallet',
        ),
        throwsA(isA<AuraInternalError>()),
      );
    });

    test('Invalid private key should throw an error', () async {
      const invalidPrivateKey = 'invalid_private_key';

      expect(
        () async => await auraWalletCore.restoreHDWallet(
          passPhraseOrPrivateKey: invalidPrivateKey,
          walletName: 'TestWallet',
        ),
        throwsA(isA<AuraInternalError>()),
      );
    });
  });
}
