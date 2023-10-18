import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:example/src/application/global/global.dart';
import 'package:example/src/presentation/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckHDWalletBalance extends StatefulWidget {
  const CheckHDWalletBalance({super.key});

  @override
  State<CheckHDWalletBalance> createState() => _CheckHDWalletBalanceState();
}

class _CheckHDWalletBalanceState extends State<CheckHDWalletBalance> {
  String walletBalance = '';
  String? errorMsg;

  @override
  Widget build(BuildContext context) {
    return AppThemeBuilder(
      builder: (theme) {
        return Scaffold(
          backgroundColor: theme.darkColor,
          appBar: AppBar(
            backgroundColor: theme.darkColor,
            centerTitle: true,
            title: const Text('Check Hd Wallet Balance'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Check Hd Wallet Balance',
                    style: TextStyle(
                      fontSize: 24,
                      color: theme.lightColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                InactiveGradientButton(
                  onPress: doCheck,
                  text: 'Check',
                ),
                Container(
                  margin: const EdgeInsets.only(left: 16, top: 32),
                  width: double.infinity,
                  child: Text(
                    'Wallet Amount',
                    style: TextStyle(color: theme.lightColor),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    left: 16,
                    top: 4,
                    right: 16,
                  ),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {},
                    child: Text(walletBalance),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void doCheck() async {
    errorMsg = null;
    try {
      final currentWallet = await AppGlobal.sdkCore.loadStoredWallet();
      final String balance = await currentWallet?.checkWalletBalance() ?? '';
      setState(() {
        walletBalance = balance;
      });
    } catch (e) {
      errorMsg = e.toString();
    }
  }

  void copyAddress() async {
    await Clipboard.setData(ClipboardData(text: walletBalance));
  }
}
