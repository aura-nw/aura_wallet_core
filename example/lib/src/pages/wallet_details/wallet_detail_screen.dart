import 'package:aura_wallet_core/wallet_objects.dart';
import 'package:flutter/material.dart';

class WalletDetailScreen extends StatelessWidget {
  final AuraWallet auraWallet;

  const WalletDetailScreen({required this.auraWallet, Key? key})
      : super(key: key);

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
              auraWallet.wallet.bech32Address,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/check-hd-wallet-balance',
                  arguments: auraWallet,
                ),
                child: const Text('Check balance'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/make-transaction',
                  arguments: auraWallet,
                ),
                child: const Text('Make transaction'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/transaction-history',
                  arguments: auraWallet,
                ),
                child: const Text('Transaction History'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/make-query-smart_contract',
                  arguments: auraWallet,
                ),
                child: const Text('Query Smart Contract'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/make-write-smart_contract',
                  arguments: auraWallet,
                ),
                child: const Text('Write Smart Contract'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () async {
                  await auraWallet.removeCurrentWallet();
                  Navigator.popUntil(context, ModalRoute.withName('/'));
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
