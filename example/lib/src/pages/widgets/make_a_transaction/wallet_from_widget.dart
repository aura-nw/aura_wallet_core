import 'package:flutter/material.dart';

class TransactionFromWidget extends StatelessWidget {
  final String address;
  final double amount;
  const TransactionFromWidget(
      {super.key, required this.address, required this.amount});

  @override
  Widget build(BuildContext context) {
    double auraAmountData = amount / 1000000;
    double auraAmount = double.parse(auraAmountData.toStringAsFixed(2));
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16, top: 32),
          width: double.infinity,
          child: const Text('Address'),
        ),
        Container(
            width: double.infinity,
            decoration: BoxDecoration(border: Border.all()),
            margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
            padding: const EdgeInsets.all(
              8,
            ),
            child: Text(address)),
        Container(
          margin: const EdgeInsets.only(top: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 16,
                ),
                child: const Text('Amount: '),
              ),
              Container(
                  width: 250,
                  decoration: BoxDecoration(border: Border.all()),
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  child: Text('$auraAmount Aura'))
            ],
          ),
        )
      ],
    );
  }
}
