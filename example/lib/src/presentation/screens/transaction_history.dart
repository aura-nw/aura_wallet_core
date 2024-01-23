import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:example/src/application/app_theme/app_theme.dart';
import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:example/src/application/global/global.dart';
import 'package:example/src/presentation/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<AuraTransaction> listData = [];

  String? errorMsg;

  @override
  Widget build(BuildContext context) {
    return AppThemeBuilder(
      builder: (theme) {
        return Scaffold(
          backgroundColor: theme.darkColor,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: theme.darkColor,
            title: const Text('Transaction History'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Transaction History',
                    style: TextStyle(
                      color: theme.lightColor,
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                InactiveGradientButton(
                  onPress: doLoadHistory,
                  text: 'Load History',
                ),
                Expanded(
                  child: listData.isNotEmpty
                      ? ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: listData.length,
                          itemBuilder: (context, index) {
                            final item = listData[index];
                            return createViewItem(item, theme);
                          },
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> doLoadHistory() async {
    try {
      final currentWallet = await AppGlobal.sdkCore.loadStoredWallet();
      final List<AuraTransaction> list =
          await currentWallet!.getWalletHistory();
      setState(() {
        listData = list;
      });
    } catch (e) {
      errorMsg = e.toString();
    }
  }

  Widget createViewItem(AuraTransaction auraTransaction, AppTheme theme) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Column(children: [
        Row(
          children: [
            Text(
              'From: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.lightColor,
              ),
            ),
            Text(
              'auraTransaction.fromAddress',
              style: TextStyle(color: theme.lightColor),
            )
          ],
        ),
        Row(
          children: [
            Text(
              'To: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.lightColor,
              ),
            ),
            Text(
              'auraTransaction.toAddress',
              style: TextStyle(
                color: theme.lightColor,
              ),
            )
          ],
        ),
        Row(
          children: [
            Text(
              'Amout: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.lightColor,
              ),
            ),
            Text(
              'auraTransaction.amount',
              style: TextStyle(
                color: theme.lightColor,
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text(
              'Type: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'auraTransaction.toAddress',
              style: TextStyle(
                color: theme.lightColor,
              ),
            )
          ],
        ),
      ]),
    );
  }
}
