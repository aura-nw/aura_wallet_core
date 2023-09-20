import 'package:aura_wallet_core/wallet_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckHDWalletBalance extends StatefulWidget {
  final AuraWallet auraWallet;
  const CheckHDWalletBalance({required this.auraWallet, super.key});

  @override
  State<CheckHDWalletBalance> createState() => _CheckHDWalletBalanceState();
}

class _CheckHDWalletBalanceState extends State<CheckHDWalletBalance> {
  String walletBalance = '';
  String? errorMsg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Hd Wallet Balance'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Check Hd Wallet Balance'),
          ),
          SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: doCheck,
                child: const Text('Check'),
              )),
          Container(
            margin: const EdgeInsets.only(left: 16, top: 32),
            width: double.infinity,
            child: const Text('Wallet Amount'),
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
        ]),
      ),
    );
  }

  void doCheck() async {
    errorMsg = null;
    try {
      final String balance = await widget.auraWallet.checkWalletBalance();
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
