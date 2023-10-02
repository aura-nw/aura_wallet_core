// ignore_for_file: non_constant_identifier_names

class ErrorCode {
  // Error code for cases where the contract address is empty.
  static int ContractAddressEmpty = 1001;

  // Error code for cases where the query is invalid.
  static int InvalidQuery = 1002;

  // Error code for cases where a query operation has failed.
  static int QueryFailed = 1003;

  // Error code for cases where the fee is invalid.
  static int InvalidFee = 1004;

  // Error code for cases where the wallet passphrase is not found.
  static int PassphraseNotFound = 1005;

  // Error code for cases where transaction broadcasting has failed.
  static int TransactionBroadcastFailed = 1006;

  // Error code for cases where there is an error with the wallet passphrase.
  static int WalletPassphraseError = 1007;

  // Error code for cases where a null passphrase is encountered.
  static int NullPassphrase = 1008;

  // Error code for cases where there is an error with transaction signing.
  static int TransactionSigningError = 1009;

  // Error code for cases where no transactions are found.
  static int NoTransactionsFound = 1010;

  // Error code for cases where there is an error with transaction verification.
  static int TransactionVerificationError = 1011;

// Error code for cases where wallet creation has failed.
  static int WalletCreationError = 1012;

  // Error code for cases where an invalid passphrase is encountered.
  static int InvalidPassphrase = 1013;

  // Error code for cases where wallet restoration has failed.
  static int WalletRestorationError = 1014;

  // Error code for general platform-related errors.
  static int PlatformError = 1015;

  // Error code for cases where there is an error with wallet loading.
  static int WalletLoadingError = 1016;

  // Error code for cases fetching balance error
  static int FetchBalanceError = 1017;

  // Error code for cases fetching wallet history error
  static int FetchWalletHistoryError = 1018;

  // Error code for cases user submit transaction error
  static int SubmitTransactionError = 1019;

  // Error code for cases user execute smart contract error
  static int ExecuteContractError = 1020;

  // Error code for cases user delete wallet error
  static int DeleteWalletError = 1021;
}
