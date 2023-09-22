class BiometricOptions {
  final String requestTitle;
  final String requestSubtitle;
  final int authenticationTimeOut;

  BiometricOptions(
      {required this.requestTitle,
      required this.requestSubtitle,
      required this.authenticationTimeOut});
}
