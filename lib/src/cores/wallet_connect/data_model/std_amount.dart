class StdAmount {
  String amount;
  String denom;

  StdAmount({required this.amount, required this.denom});

  factory StdAmount.fromJson(Map<String, dynamic> json) {
    if (json['amount'] is int) {
      return StdAmount(
        amount: '${json['amount']}',
        denom: json['denom'] as String,
      );
    }
    return StdAmount(
      amount: json['amount'] as String,
      denom: json['denom'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'denom': denom,
    };
  }
}
