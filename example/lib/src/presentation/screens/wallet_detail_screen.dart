import 'package:example/src/app_navigator.dart';
import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:example/src/application/global/global.dart';
import 'package:example/src/application/global_state/global_cubit.dart';
import 'package:example/src/application/global_state/global_state.dart';
import 'package:example/src/presentation/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class WalletDetailScreen extends StatefulWidget {
  const WalletDetailScreen({Key? key}) : super(key: key);

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeBuilder(
      builder: (theme) {
        return Scaffold(
          backgroundColor: theme.darkColor,
          appBar: AppBar(
            title: const Text('Wallet detail'),
            centerTitle: true,
            backgroundColor: theme.darkColor,
            leading: const SizedBox(),
          ),
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Wallet Address",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppGlobalCubit.of(context).state.bech32Address,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    InactiveGradientButton(
                      onPress: () =>
                          AppNavigator.push(AppRoutePath.checkHdWalletBalance),
                      text: 'Check balance',
                    ),
                    const SizedBox(height: 40),
                    InactiveGradientButton(
                      onPress: () =>
                          AppNavigator.push(AppRoutePath.makeTransaction),
                      text: 'Make transaction',
                    ),
                    const SizedBox(height: 40),
                    InactiveGradientButton(
                      onPress: () =>
                          AppNavigator.push(AppRoutePath.transactionHistory),
                      text: 'Transaction History',
                    ),
                    const SizedBox(height: 40),
                    InactiveGradientButton(
                      onPress: () => AppNavigator.push(
                          AppRoutePath.makeQuerySmartContract),
                      text: 'Query Smart Contract',
                    ),
                    const SizedBox(height: 40),
                    InactiveGradientButton(
                      onPress: () => AppNavigator.push(
                          AppRoutePath.makeWriteSmartContract),
                      text: 'Write Smart Contract',
                    ),
                    const SizedBox(height: 40),
                    InactiveGradientButton(
                      onPress: () async {
                        try {
                          await AppGlobal.sdkCore.removeWallet();

                          if (context.mounted) {
                            AppGlobalCubit.of(context).changeState(
                              const GlobalState(
                                bech32Address: '',
                                status: AppGlobalStatus.unauthorized,
                              ),
                            );
                          }
                        } catch (e) {
                          print(e.toString());
                        }
                      },
                      text: 'Remove current wallet',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
