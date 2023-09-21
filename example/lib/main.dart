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
            return _defaultRouter(
              const WalletDetailScreen(),
              settings,
            );
          case '/generate-hd-wallet':
            return _defaultRouter(const CreateHdWalletPage(), settings);
          case '/restore-hd-wallet':
            return _defaultRouter(const RestoreHdWalletPage(), settings);
          case '/transaction-history':
            return _defaultRouter(const TransactionHistory(), settings);
          case '/check-hd-wallet-balance':
            return _defaultRouter(const CheckHDWalletBalance(), settings);
          case '/make-transaction':
            return _defaultRouter(const MakeTransactionPage(), settings);
          case '/make-query-smart_contract':
            return _defaultRouter(const MakeQuerySmartContract(), settings);
          case '/make-write-smart_contract':
            return _defaultRouter(const MakeWriteSmartContract(), settings);
          default:
            return _defaultRouter(
                const InAppWalletPage(title: 'Digital Wallet Demo'), settings);
        }
      },
    );
  }
}
