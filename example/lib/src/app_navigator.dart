import 'package:example/src/utils/app_route.dart';
import 'package:flutter/material.dart';

import 'presentation/screens/inapp_wallet_page.dart';
import 'presentation/screens/check_aura_balance.dart';
import 'presentation/screens/create_hd_wallet.dart';
import 'presentation/screens/make_a_transaction.dart';
import 'presentation/screens/make_query_smart_contract.dart';
import 'presentation/screens/make_write_smart_contract.dart';
import 'presentation/screens/restore_hd_wallet.dart';
import 'presentation/screens/transaction_history.dart';
import 'presentation/screens/wallet_detail_screen.dart';

class AppRoutePath {
  static const String _base = '/';
  static const String inAppWallet = _base;
  static const String walletDetail = '${_base}wallet_detail';
  static const String generateHdWallet = '${inAppWallet}generate-hd-wallet';
  static const String restoreHdWallet = '${inAppWallet}restore-hd-wallet';
  static const String transactionHistory = '$walletDetail/transaction-history';
  static const String checkHdWalletBalance = '$walletDetail/check-hd-wallet-balance';
  static const String makeTransaction = '$walletDetail/make-transaction';
  static const String makeQuerySmartContract = '$walletDetail/make-query-smart_contract';
  static const String makeWriteSmartContract = '$walletDetail/make-write-smart_contract';
}

class AppNavigator {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutePath.inAppWallet:
        return _defaultRoute(
            const InAppWalletPage(title: 'Digital Wallet Demo'), settings);
      case AppRoutePath.walletDetail:
        return _defaultRoute(
          const WalletDetailScreen(),
          settings,
        );
      case AppRoutePath.generateHdWallet:
        return _defaultRoute(const CreateHdWalletPage(), settings);
      case AppRoutePath.restoreHdWallet:
        return _defaultRoute(const RestoreHdWalletPage(), settings);
      case AppRoutePath.transactionHistory:
        return _defaultRoute(const TransactionHistory(), settings);
      case AppRoutePath.checkHdWalletBalance:
        return _defaultRoute(const CheckHDWalletBalance(), settings);
      case AppRoutePath.makeTransaction:
        return _defaultRoute(const MakeTransactionPage(), settings);
      case AppRoutePath.makeQuerySmartContract:
        return _defaultRoute(const MakeQuerySmartContract(), settings);
      case AppRoutePath.makeWriteSmartContract:
        return _defaultRoute(const MakeWriteSmartContract(), settings);
      default:
        return _defaultRoute(
            const InAppWalletPage(title: 'Digital Wallet Demo'), settings);
    }
  }

  static Future? push<T>(String route, [T? arguments]) =>
      state?.pushNamed(route, arguments: arguments);

  static Future? replaceWith<T>(String route, [T? arguments]) =>
      state?.pushReplacementNamed(route, arguments: arguments);

  static void pop<T>([T? arguments]) => state?.pop(arguments);

  static void popToFirst() => state?.popUntil((route) => route.isFirst);

  static void replaceAllWith(String route) =>
      state?.pushNamedAndRemoveUntil(route, (route) => route.isFirst);

  static NavigatorState? get state => navigatorKey.currentState;

  static Route _defaultRoute(
      Widget child,
      RouteSettings settings,
      ) {
    return SlideRoute(
      page: child,
      settings: settings,
    );
  }
}