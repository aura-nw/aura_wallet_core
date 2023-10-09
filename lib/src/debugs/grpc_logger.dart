import 'package:aura_wallet_core/src/cores/repo/store_house.dart';
import 'package:grpc/service_api.dart' as $grpc;
import 'dart:developer' as auraLog;

// LogInter is a gRPC client interceptor used for logging gRPC requests and responses.
class LogInter implements $grpc.ClientInterceptor {
  final Storehouse _storehouse;

  LogInter(this._storehouse);
  @override
  $grpc.ResponseStream<R> interceptStreaming<Q, R>(
      $grpc.ClientMethod<Q, R> method,
      Stream<Q> requests,
      $grpc.CallOptions options,
      $grpc.ClientStreamingInvoker<Q, R> invoker) {
    // Pass through the gRPC request and response streams without modification.
    return invoker(method, requests, options);
  }

  @override
  $grpc.ResponseFuture<R> interceptUnary<Q, R>(
      $grpc.ClientMethod<Q, R> method,
      Q request,
      $grpc.CallOptions options,
      $grpc.ClientUnaryInvoker<Q, R> invoker) {
    // Check if logging is enabled in the configuration.
    final enableLogging = _storehouse.configOption.isEnableLog;

    if (enableLogging) {
      // Log the gRPC request.
      final logMessage =
          'Grpc request. method: ${method.path}, request: $request';
      auraLog.log(logMessage);
    }

    // Perform the gRPC request and capture the response.
    final response = invoker(method, request, options);

    if (enableLogging) {
      // Log the gRPC response when it becomes available.
      response.then((r) {
        final logMessage =
            'Grpc response. method: ${method.path}, response: ${r.toString()}';
        auraLog.log(logMessage);
      });
    }

    // Return the gRPC response.
    return response;
  }
}
