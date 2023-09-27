import 'package:grpc/service_api.dart' as $grpc;
import 'dart:developer' as auraLog;

class LogInter implements $grpc.ClientInterceptor {
  @override
  $grpc.ResponseStream<R> interceptStreaming<Q, R>(
      $grpc.ClientMethod<Q, R> method,
      Stream<Q> requests,
      $grpc.CallOptions options,
      $grpc.ClientStreamingInvoker<Q, R> invoker) {
    return invoker(method, requests, options);
  }

  @override
  $grpc.ResponseFuture<R> interceptUnary<Q, R>(
      $grpc.ClientMethod<Q, R> method,
      Q request,
      $grpc.CallOptions options,
      $grpc.ClientUnaryInvoker<Q, R> invoker) {
    auraLog.log(
      'Grpc request. '
      'method: ${method.path}, '
      'request: $request',
    );
    final response = invoker(method, request, options);

    response.then((r) {
      auraLog.log(
        'Grpc response. '
        'method: ${method.path}, '
        'response: ${r.toString()}',
      );
    });

    return response;
  }
}
