import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:example/src/application/global/global.dart';
import 'package:example/src/application/global_state/global_cubit.dart';
import 'package:example/src/presentation/widgets/button_widget.dart';
import 'package:example/src/utils/loader_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/make_a_transaction/wallet_from_widget.dart';
import '../widgets/make_a_transaction/wallet_to_widget.dart';

class MakeTransactionPage extends StatefulWidget {
  const MakeTransactionPage({super.key});

  @override
  State<MakeTransactionPage> createState() => _MakeTransactionPageState();
}

class _MakeTransactionPageState extends State<MakeTransactionPage>
    with ScreenLoaderMixin {
  double amount = 0;
  String? errorMsg = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doGetWalletInfo();
    });
  }

  TransactionToWidgetController controller = TransactionToWidgetController(
      TextEditingController(
          text: 'aura1k24l7vcfz9e7p9ufhjs3tfnjxwu43h8quq4glv'));

  @override
  Widget builder(BuildContext context) {
    return AppThemeBuilder(
      builder: (theme) {
        return Scaffold(
          backgroundColor: theme.darkColor,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: theme.darkColor,
            title: const Text('Make Transaction Hd Wallet'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Make Transaction HD Wallet',
                      style: TextStyle(
                        fontSize: 30,
                        color: theme.lightColor,
                      ),
                    ),
                  ),
                  errorMsg == null
                      ? TransactionFromWidget(
                          address:
                              AppGlobalCubit.of(context).state.bech32Address,
                          amount: amount,
                          theme: theme,
                        )
                      : InactiveGradientButton(
                          onPress: doGetWalletInfo,
                          text: 'Get Info',
                        ),
                  if (errorMsg == null)
                    TransactionToWidget(
                      amount: amount,
                      controller: controller,
                    ),
                  if (errorMsg == null)
                    InactiveGradientButton(
                      onPress: doSend,
                      text: 'Send',
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void doGetWalletInfo() async {
    if (!mounted) {
      return;
    }
    showLoading();
    errorMsg = null;
    try {
      final currentWallet = await AppGlobal.sdkCore.loadStoredWallet();
      final String amountStr = await currentWallet?.checkWalletBalance() ?? '';
      double? amountData = double.tryParse(amountStr);
      setState(() {
        amount = amountData ?? 0;
      });
    } catch (e) {
      errorMsg = e.toString();
    } finally {
      hideLoading();
    }
  }

  void doSend() async {
    showLoading();
    try {
      String toAddress = controller.textEditingController.text;
      int amount = (controller.amount * 1000000).toInt();

      final currentWallet = await AppGlobal.sdkCore.loadStoredWallet();

      final tx = await currentWallet!.sendTransaction(
        toAddress: toAddress,
        amount: amount.toString(),
        fee: '200',
        gasLimit: 200,
      );

      final response = await currentWallet.submitTransaction(
        signedTransaction: tx,
      );

      if (response) {
        print("success");
      } else {
        print("fail");
      }
    } catch (e) {
      errorMsg = e.toString();
    }
    hideLoading();
  }

  void copyAddress() async {
    await Clipboard.setData(
      ClipboardData(
        text: AppGlobalCubit.of(context).state.bech32Address,
      ),
    );
  }
}
