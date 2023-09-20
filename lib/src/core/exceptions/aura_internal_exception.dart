class AuraInternalError extends Error {
  final String message;
  final int errorCode;

  AuraInternalError(
      this.errorCode,
      this.message,
      );
  @override
  String toString() {
    return '[InternalSDKError][$errorCode] - $message';
  }
}
