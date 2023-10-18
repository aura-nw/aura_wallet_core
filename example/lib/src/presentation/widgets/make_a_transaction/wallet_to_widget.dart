import 'package:flutter/material.dart';

class TransactionToWidgetController {
  double amount = 0;
  final TextEditingController textEditingController;

  TransactionToWidgetController(this.textEditingController);
}

class TransactionToWidget extends StatefulWidget {
  final double amount;
  final TransactionToWidgetController controller;

  const TransactionToWidget(
      {super.key, required this.amount, required this.controller});

  @override
  State<TransactionToWidget> createState() => _TransactionToWidgetState();
}

class _TransactionToWidgetState extends State<TransactionToWidget> {
  double _slideValue = 0;

  double get slideValue => double.parse(_slideValue.toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    final double auraAmount = widget.amount / 1000000;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16, top: 32),
          width: double.infinity,
          child: const Text(
            'To Address',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: TextField(
              controller: widget.controller.textEditingController,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                labelText: 'Enter the target Wallet',
                hintStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            )),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Amount: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                'Selected Value $slideValue',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
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
