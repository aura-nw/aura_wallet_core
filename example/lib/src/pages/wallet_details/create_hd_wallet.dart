import 'package:aura_wallet_core/aura_environment.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/loading_screen_mixin.dart';
import '../widgets/message_dialog.dart';

class CreateHdWalletPage extends StatefulWidget {
  const CreateHdWalletPage({super.key});

  @override
  State<CreateHdWalletPage> createState() => _CreateHdWalletPageState();
}

class _CreateHdWalletPageState extends State<CreateHdWalletPage>
    with ScreenLoaderMixin {
  final AuraWalletCore _auraSDK =
      AuraWalletCore.create(environment: AuraWalletCoreEnvironment.testNet);

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Hd Wallet'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Generate HD Wallet'),
          ),
          SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: doGeneWallet,
                child: const Text('Generate'),
              )),
        ]),
      ),
    );
  }

  void doGeneWallet() async {
    showLoading();
    try {
      await _auraSDK.createRandomHDWallet().then((wallet) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 16, top: 16),
                      width: double.infinity,
                      child: const Text('Private Key'),
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
                        onPressed: () => copyText(wallet.privateKey),
                        child: Text(wallet.privateKey),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 16, top: 16),
                      width: double.infinity,
                      child: const Text('PassPhase'),
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
                        onPressed: () => copyText(wallet.mnemonic),
                        child: Text(wallet.mnemonic),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 16, top: 16),
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
                        onPressed: () =>
                            copyText(wallet.auraWallet.wallet.bech32Address),
                        child: Text(wallet.auraWallet.wallet.bech32Address),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/wallet_detail',
                          arguments: wallet.auraWallet,
                        );
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: MessageDialog(
              message: e.toString(),
            ),
          );
        },
      );
    } finally {
      hideLoading();
    }
  }

  void copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
