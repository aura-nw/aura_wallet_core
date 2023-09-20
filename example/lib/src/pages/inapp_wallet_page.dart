import 'package:aura_wallet_core/aura_environment.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:flutter/material.dart';

import 'widgets/loading_screen_mixin.dart';

class InAppWalletPage extends StatefulWidget {
  const InAppWalletPage({super.key, required this.title});

  final String title;

  @override
  State<InAppWalletPage> createState() => _InAppWalletPageState();
}

class _InAppWalletPageState extends State<InAppWalletPage>
    with ScreenLoaderMixin {
  final AuraWalletCore _auraSDK =
      AuraWalletCore.create(environment: AuraWalletCoreEnvironment.testNet);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      showLoading();
      try {
        await _auraSDK.loadCurrentWallet().then((wallet) {
          if (wallet != null) {
            Navigator.pushNamed(
              context,
              '/wallet_detail',
              arguments: wallet,
            );
          }
        });
      } catch (e) {
        //
      } finally {
        hideLoading();
      }
    });
  }

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/generate-hd-wallet'),
                child: const Text('Create Wallet'),
              ),
            ),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/restore-hd-wallet'),
                child: const Text('Restore'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
