import 'package:aura_wallet_core/src/cores/wallet_connect/data_model/std_fee.dart';

class StdSignDoc {
  String chainId;
  String accountNumber;
  String sequence;
  StdFee fee;
  List<dynamic> msgs;
  String memo;
  String? timeoutHeight;

  StdSignDoc({
    required this.chainId,
    required this.accountNumber,
    required this.sequence,
    required this.fee,
    required this.msgs,
    required this.memo,
    this.timeoutHeight,
  });

  factory StdSignDoc.fromJson(Map<String, dynamic> json) {
    print('json: $json');
    return StdSignDoc(
      chainId: json['chain_id'] as String,
      accountNumber: json['account_number'].toString(),
      sequence: json['sequence'].toString(),
      fee: StdFee.fromJson(json['fee']),
      msgs: json['msgs'] ?? [],
      memo: json['memo'] as String,
      timeoutHeight: json['timeout_height']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chain_id': chainId,
      'account_number': int.parse(accountNumber),
      'sequence': int.parse(sequence),
      'fee': fee.toJson(),
      'msgs': msgs,
      'memo': memo,
      'timeout_height': timeoutHeight,
    };
  }
}
