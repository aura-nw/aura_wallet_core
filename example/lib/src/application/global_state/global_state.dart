enum AppGlobalStatus {
  unauthorized,
  authorized,
}

class GlobalState {
  final String bech32Address;
  final AppGlobalStatus status;

  const GlobalState({
    this.bech32Address = '',
    this.status = AppGlobalStatus.unauthorized,
  });
}
