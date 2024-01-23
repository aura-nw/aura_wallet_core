import 'package:alan/proto/google/protobuf/any.pb.dart';

class AuraTransaction {
  final String txHash;
  final int status;
  final String timeStamp;
  final String fee;
  final String type;
  final String? memo;
  final Any ?msg;

  const AuraTransaction({
    required this.status,
    required this.txHash,
    required this.timeStamp,
    required this.fee,
    required this.type,
    this.memo,
    this.msg,
  });
}
