import 'package:aura_wallet_core/config_options/config_options.dart';
import 'package:aura_wallet_core/config_options/environment_options.dart';
import 'package:aura_wallet_core/src/aura_internal_wallet_impl.dart';
import 'package:aura_wallet_core/src/cores/aura_internal_storage.dart';
import 'package:aura_wallet_core/src/cores/exceptions/aura_internal_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:mockito/annotations.dart';

import 'aura_wallet_core_test.mocks.dart';
import 'package:alan/alan.dart';
import 'package:aura_wallet_core/config_options/config_options.dart';
import 'package:aura_wallet_core/config_options/environment_options.dart';
import 'package:aura_wallet_core/src/aura_internal_wallet_impl.dart';
import 'package:aura_wallet_core/src/cores/aura_internal_storage.dart';
import 'package:aura_wallet_core/src/cores/exceptions/aura_internal_exception.dart';
import 'package:aura_wallet_core/src/wallet_connect/signer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:grpc/grpc.dart';
import 'package:mockito/annotations.dart';

import 'aura_wallet_core_test.mocks.dart';

void main() async {
  setUp(() async {
    // anything else you need to setup

    // await Future.delayed(const Duration(seconds: 1));
  });

  group('AuraWalletCore - Test', () {
    test('Test 1', () async {});

    test('Restoring wallet from private key', () async {});

    test('Invalid passphrase should throw an error', () async {});

    test('Invalid private key should throw an error', () async {});
  });
}
