import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:example/src/application/global/global.dart';
import 'package:example/src/application/global_state/global_cubit.dart';
import 'package:example/src/application/global_state/global_state.dart';
import 'package:example/src/presentation/widgets/button_widget.dart';
import 'package:example/src/utils/loader_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RestoreHdWalletPage extends StatefulWidget {
  const RestoreHdWalletPage({super.key});

  @override
  State<RestoreHdWalletPage> createState() => _RestoreHdWalletPageState();
}

class _RestoreHdWalletPageState extends State<RestoreHdWalletPage>
    with ScreenLoaderMixin {
  TextEditingController passpharseController = TextEditingController();
  String? errorMsg;

  @override
  Widget builder(BuildContext context) {
    return AppThemeBuilder(
      builder: (theme) {
        return Scaffold(
          backgroundColor: theme.darkColor,
          appBar: AppBar(
            backgroundColor: theme.darkColor,
            centerTitle: true,
            title: const Text('Restore Hd Wallet'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Restore HD Wallet',
                    style: TextStyle(
                      color: theme.lightColor,
                      fontSize: 30,
                    ),
                  ),
                ),
                TextField(
                  controller: passpharseController,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: theme.lightColor,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Enter the passpharse',
                    errorText: errorMsg,
                    hintText: 'passpharse',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.lightColor,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.lightColor,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                InactiveGradientButton(
                  onPress: doRestoreWallet,
                  text: 'Restore',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void doRestoreWallet() async {
    try {
      await AppGlobal.sdkCore
          .restoreHDWallet(
        passPhraseOrPrivateKey: passpharseController.text.trim(),
      )
          .then((wallet) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                      onPressed: () => copyAddress(wallet.bech32Address),
                      child: Text(wallet.bech32Address),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      AppGlobalCubit.of(context).changeState(
                        GlobalState(
                          bech32Address: wallet.bech32Address,
                          status: AppGlobalStatus.authorized,
                        ),
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
