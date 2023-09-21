import 'package:example/src/pages/inapp_wallet_singleton_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/loading_screen_mixin.dart';

class RestoreHdWalletPage extends StatefulWidget {
  const RestoreHdWalletPage({super.key});

  @override
  State<RestoreHdWalletPage> createState() => _RestoreHdWalletPageState();
}

class _RestoreHdWalletPageState extends State<RestoreHdWalletPage>
    with ScreenLoaderMixin {
  TextEditingController passpharseController = TextEditingController();
  String? errorMsg;

  final InAppWalletProviderHandler handler =
      InAppWalletProviderHandler.instance;

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore Hd Wallet'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Restore HD Wallet'),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: TextField(
              controller: passpharseController,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: 'Enter the passpharse',
                errorText: errorMsg,
                hintText: 'passpharse',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: doRestoreWallet,
                child: const Text('Restore'),
              )),
        ]),
      ),
    );
  }

  void doRestoreWallet() async {
    try {
      await handler
          .getWalletCore()
          .restoreHDWallet(
            key: passpharseController.text,
          )
          .then((wallet) {
        handler.setBech32Address(wallet.wallet.bech32Address);
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 16, top: 32),
                    width: double.infinity,
                    child: const Text('Address'),
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
                      onPressed: () => copyAddress(wallet.wallet.bech32Address),
                      child: Text(wallet.wallet.bech32Address),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/wallet_detail',
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        );
      });
    } catch (e) {
      errorMsg = e.toString();
      setState(() {});
    }
  }

  void copyAddress(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
  }
}
