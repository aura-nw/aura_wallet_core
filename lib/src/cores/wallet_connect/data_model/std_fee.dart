import 'package:aura_wallet_core/src/cores/wallet_connect/data_model/std_amount.dart';

class StdFee {
  List<StdAmount> amount;
  int gas;

  StdFee({required this.amount, required this.gas});

  factory StdFee.fromJson(Map<String, dynamic> json) {
    if (json['gas'] is String) {
      return StdFee(
        amount: (json['amount'] as List<dynamic>)
            .map((e) => StdAmount.fromJson(e))
            .toList(),
        gas: int.parse(json['gas']),
      );
    }
    return StdFee(
      amount: (json['amount'] as List<dynamic>)
          .map((e) => StdAmount.fromJson(e))
          .toList(),
      gas: json['gas'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount.map((e) => e.toJson()).toList(),
      'gas': gas,
    };
  }
}
