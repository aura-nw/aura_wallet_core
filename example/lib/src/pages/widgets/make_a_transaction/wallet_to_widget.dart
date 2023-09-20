import 'package:flutter/material.dart';

class TransactionToWidgetController {
  double amount = 0;
  final TextEditingController textEditingController;

  TransactionToWidgetController(this.textEditingController);
}

class TransactionToWidget extends StatefulWidget {
  final String address;
  final double amount;
  final TransactionToWidgetController controller;
  const TransactionToWidget(
      {super.key,
      required this.address,
      required this.amount,
      required this.controller});

  @override
  State<TransactionToWidget> createState() => _TransactionToWidgetState();
}

class _TransactionToWidgetState extends State<TransactionToWidget> {
  double _slideValue = 0;
  double get slideValue => double.parse(_slideValue.toStringAsFixed(2));

  // TextEditingController textEditingController = TextEditingController(
  //     text: 'aura1k24l7vcfz9e7p9ufhjs3tfnjxwu43h8quq4glv');
  @override
  Widget build(BuildContext context) {
    final double auraAmount = widget.amount / 1000000;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16, top: 32),
          width: double.infinity,
          child: const Text('To Address'),
        ),
        Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: TextField(
              controller: widget.controller.textEditingController,
              textAlign: TextAlign.start,
              decoration: const InputDecoration(
                labelText: 'Enter the target Wallet',
                border: OutlineInputBorder(),
              ),
            )),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Amount: '),
              Text('Selected Value $slideValue'),
            ],
          ),
        ),
        Slider(
            value: _slideValue,
            min: 0,
            max: auraAmount,
            onChanged: (a) {
              setState(() {
                _slideValue = a;
                widget.controller.amount = slideValue;
              });
            }),
        Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _slideValue = auraAmount * 0.25;
                        widget.controller.amount = _slideValue;
                      });
                    },
                    child: const Text('25%'),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _slideValue = auraAmount * 0.5;
                        widget.controller.amount = _slideValue;
                      });
                    },
                    child: const Text('50%'),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _slideValue = auraAmount * 0.75;
                        widget.controller.amount = _slideValue;
                      });
                    },
                    child: const Text('75%'),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _slideValue = auraAmount;
                        widget.controller.amount = _slideValue;
                      });
                    },
                    child: const Text('100%'),
                  ),
                )
              ],
            ))
      ],
    );
  }
}
