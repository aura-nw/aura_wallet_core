import 'package:aura_wallet_core/aura_environment.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:aura_wallet_core/wallet_objects.dart';
import 'package:flutter/material.dart';

import 'src/pages/inapp_wallet_page.dart';
import 'src/pages/wallet_details/check_aura_balance.dart';
import 'src/pages/wallet_details/create_hd_wallet.dart';
import 'src/pages/wallet_details/make_a_transaction.dart';
import 'src/pages/wallet_details/make_query_smart_contract.dart';
import 'src/pages/wallet_details/make_write_smart_contract.dart';
import 'src/pages/wallet_details/restore_hd_wallet.dart';
import 'src/pages/wallet_details/transaction_history.dart';
import 'src/pages/wallet_details/wallet_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final AuraConnectSdk _connectSdk = AuraConnectSdk();
  late final AuraWalletCore auraSDK;

  @override
  void initState() {
    auraSDK =
        AuraWalletCore.create(environment: AuraWalletCoreEnvironment.testNet);

    super.initState();
  }

  @override
  void dispose() {
    auraSDK.dispose();
    super.dispose();
  }

  MaterialPageRoute _defaultRouter(Widget child, RouteSettings settings) =>
      MaterialPageRoute(
        builder: (context) {
          return child;
        },
        settings: settings,
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _defaultRouter(
                const InAppWalletPage(title: 'Digital Wallet Demo'), settings);
          case '/inapp-wallet':
            return _defaultRouter(
                const InAppWalletPage(title: 'Digital Wallet Demo'), settings);
          case '/wallet_detail':
            final auraWallet = settings.arguments as AuraWallet;
            return _defaultRouter(
              WalletDetailScreen(
                auraWallet: auraWallet,
              ),
              settings,
            );
          case '/generate-hd-wallet':
            return _defaultRouter(const CreateHdWalletPage(), settings);
          case '/restore-hd-wallet':
            return _defaultRouter(const RestoreHdWalletPage(), settings);
          case '/transaction-history':
            final auraWallet = settings.arguments as AuraWallet;
            return _defaultRouter(
                TransactionHistory(
                  auraWallet: auraWallet,
                ),
                settings);
          case '/check-hd-wallet-balance':
            final auraWallet = settings.arguments as AuraWallet;
            return _defaultRouter(
                CheckHDWalletBalance(
                  auraWallet: auraWallet,
                ),
                settings);
          case '/make-transaction':
            final auraWallet = settings.arguments as AuraWallet;
            return _defaultRouter(
                MakeTransactionPage(
                  auraWallet: auraWallet,
                ),
                settings);
          case '/make-query-smart_contract':
            final auraWallet = settings.arguments as AuraWallet;
            return _defaultRouter(
                MakeQuerySmartContract(
                  auraWallet: auraWallet,
                ),
                settings);
          case '/make-write-smart_contract':
            final auraWallet = settings.arguments as AuraWallet;
            return _defaultRouter(
                MakeWriteSmartContract(
                  auraWallet: auraWallet,
                ),
                settings);
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // AuraWalletInfoData? data;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SizedBox(
        width: 400,
        height: 800,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pushNamed('/inapp-wallet');
              },
              child: const Text('In App wallet'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/external-wallet');
              },
              child: const Text('External wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
