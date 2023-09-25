import 'package:example/src/application/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class TransactionFromWidget extends StatelessWidget {
  final String address;
  final double amount;
  final AppTheme theme;

  const TransactionFromWidget({
    super.key,
    required this.address,
    required this.amount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    double auraAmountData = amount / 1000000;
    double auraAmount = double.parse(auraAmountData.toStringAsFixed(2));
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16, top: 32),
          width: double.infinity,
          child: Text(
            'Address',
            style: TextStyle(color: theme.lightColor),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all()),
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
          padding: const EdgeInsets.all(
            8,
          ),
          child: Text(
            address,
            style: TextStyle(color: theme.lightColor),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 16,
                ),
                child: Text(
                  'Amount: ',
                  style: TextStyle(color: theme.lightColor),
                ),
              ),
              Container(
                width: 250,
                decoration: BoxDecoration(border: Border.all()),
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(
                  8,
                ),
                child: Text(
                  '$auraAmount Aura',
                  style: TextStyle(
                      color: theme.lightColor
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
