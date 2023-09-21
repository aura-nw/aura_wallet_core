import 'package:aura_wallet_core/storage_util.dart';
import 'package:example/src/pages/inapp_wallet_singleton_handler.dart';
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
  @override
  void initState() {
    super.initState();
    InAppWalletProviderHandler.instance.addListener(_listenBech32AddressChange);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      showLoading();
      try {
        await AuraInternalStorage().readBech32Address().then((bech32Address) {
          print(bech32Address);

          if (bech32Address == null) return;

          InAppWalletProviderHandler.instance.setBech32Address(bech32Address);

          Navigator.pushNamed(
            context,
            '/wallet_detail',
          );
        });
      } catch (e) {
        // keep page
        print(e.toString());
      } finally {
        hideLoading();
      }
    });
  }

  @override
  void dispose() {
    InAppWalletProviderHandler.instance.removeListener(_listenBech32AddressChange);
    super.dispose();
  }

  void _listenBech32AddressChange() {
    Navigator.popUntil(context, (route) => route.isFirst);
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
