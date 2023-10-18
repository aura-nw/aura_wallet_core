import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:example/src/application/global/global.dart';
import 'package:example/src/application/global_state/global_cubit.dart';
import 'package:example/src/application/global_state/global_state.dart';
import 'package:example/src/presentation/widgets/button_widget.dart';
import 'package:example/src/presentation/widgets/message_dialog.dart';
import 'package:example/src/utils/loader_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateHdWalletPage extends StatefulWidget {
  const CreateHdWalletPage({super.key});

  @override
  State<CreateHdWalletPage> createState() => _CreateHdWalletPageState();
}

class _CreateHdWalletPageState extends State<CreateHdWalletPage>
    with ScreenLoaderMixin {
  final TextEditingController _confirmPasspharseController =
      TextEditingController();

  @override
  Widget builder(BuildContext context) {
    return AppThemeBuilder(
      builder: (theme) {
        return Scaffold(
          backgroundColor: theme.darkColor,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: theme.darkColor,
            title: const Text('Generate Hd Wallet'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Text(
                    'Generate HD Wallet',
                    style: TextStyle(
                      color: theme.lightColor,
                      fontSize: 30,
                    ),
                  ),
                ),
                InactiveGradientButton(
                  onPress: doGeneWallet,
                  text: 'Generate',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void doGeneWallet() async {
    showLoading();
    try {
      await AppGlobal.sdkCore.createRandomHDWallet().then(
        (wallet) {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Private Key'),
                        const SizedBox(
                          height: 8,
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => copyText(wallet.privateKey ?? ""),
                          child: Text(wallet.privateKey ?? ""),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('PassPhase'),
                        const SizedBox(
                          height: 8,
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => copyText(wallet.mnemonic ?? ""),
                          child: Text(wallet.mnemonic ?? ""),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Address'),
                        const SizedBox(
                          height: 8,
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => copyText(wallet.bech32Address),
                          child: Text(wallet.bech32Address),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Passpharse',
                            border: InputBorder.none,
                          ),
                          controller: _confirmPasspharseController,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InactiveGradientButton(
                          onPress: () async {
                            if (_confirmPasspharseController.text.isEmpty)
                              return;
                            try {
                              final wallet =
                                  await AppGlobal.sdkCore.restoreHDWallet(
                                passPhraseOrPrivateKey:
                                    _confirmPasspharseController.text.trim(),
                              );

                              if (mounted) {
                                AppGlobalCubit.of(context).changeState(
                                  GlobalState(
                                    bech32Address: wallet.bech32Address,
                                    status: AppGlobalStatus.authorized,
                                  ),
                                );
                              }
                            } catch (e) {
                              print(e.toString());
                            }
                          },
                          text: 'OK',
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: MessageDialog(
                message: e.toString(),
              ),
            );
          },
        );
      }
    } finally {
      hideLoading();
    }
  }

  void copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
