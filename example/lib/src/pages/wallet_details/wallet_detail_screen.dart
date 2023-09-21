import 'package:example/src/pages/inapp_wallet_singleton_handler.dart';
import 'package:flutter/material.dart';

class WalletDetailScreen extends StatefulWidget {
  const WalletDetailScreen({Key? key}) : super(key: key);

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  @override
  void initState() {
    InAppWalletProviderHandler.instance.checkValidBech32Address();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet detail'),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Wallet Address",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              InAppWalletProviderHandler.instance.bech32Address,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/check-hd-wallet-balance',
                ),
                child: const Text('Check balance'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/make-transaction',
                ),
                child: const Text('Make transaction'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/transaction-history',
                ),
                child: const Text('Transaction History'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/make-query-smart_contract',
                ),
                child: const Text('Query Smart Contract'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/make-write-smart_contract',
                ),
                child: const Text('Write Smart Contract'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () async {
                  InAppWalletProviderHandler.instance.setBech32Address('');
                },
                child: const Text('Remove current wallet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
