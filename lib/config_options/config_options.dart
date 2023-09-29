class ConfigOption {
  final bool isEnableLog;
  final int gasLimit;
  final int minFee;

  const ConfigOption({
    this.isEnableLog = false,
    required this.gasLimit,
    required this.minFee,
  });
}
