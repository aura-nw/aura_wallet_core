import 'dart:async';
import 'dart:convert';

import 'package:aura_wallet_core/src/wallet_connect/wallet_connect_service_utils.dart';
import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

enum WalletConnectEvent {
  connect,
  sign,
}

class WalletConnectService {
  static const String projectId = '85289c08fad8fae4ca3eb5e525005bf3';

  final Map<WalletConnectEvent, void Function(dynamic)> _call = {};

  void addListener(WalletConnectEvent event, void Function(dynamic) callback) {
    _call[event] = callback;
  }

  Web3Wallet? _web3Wallet;

  /// The list of requests from the dapp
  /// Potential types include, but aren't limited to:
  /// [SessionProposalEvent], [AuthRequest]
  @override
  ValueNotifier<List<PairingInfo>> pairings =
      ValueNotifier<List<PairingInfo>>([]);
  @override
  ValueNotifier<List<SessionData>> sessions =
      ValueNotifier<List<SessionData>>([]);
  @override
  ValueNotifier<List<StoredCacao>> auth = ValueNotifier<List<StoredCacao>>([]);

  Future<void> create({
    required String name,
    required String description,
    required String url,
    required String icon,
    String? nativeRedirect,
    String? universalRedirect,
  }) async {
    // Create the web3wallet
    _web3Wallet = Web3Wallet(
      core: Core(
        projectId: projectId,
        logLevel: LogLevel.error,
      ),
      metadata: PairingMetadata(
        name: name,
        description: description,
        url: url,
        icons: [icon],
        redirect: Redirect(
          native: nativeRedirect,
          universal: universalRedirect,
        ),
      ),
    );

    await _web3Wallet!.init();

    WalletConnectServiceUtils.registerChain('cosmos:euphoria-2', _web3Wallet!);
    WalletConnectServiceUtils.registerChain('cosmos:cosmoshub-4', _web3Wallet!);
    WalletConnectServiceUtils.registerChain('cosmos:xstaxy-1', _web3Wallet!);

    // Setup our listeners
    print('web3wallet create');
    _web3Wallet!.core.pairing.onPairingInvalid.subscribe(_onPairingInvalid);
    _web3Wallet!.core.pairing.onPairingCreate.subscribe(_onPairingCreate);
    _web3Wallet!.pairings.onSync.subscribe(_onPairingsSync);
    _web3Wallet!.onSessionProposal.subscribe(_onSessionProposal);
    _web3Wallet!.onSessionProposalError.subscribe(_onSessionProposalError);
    _web3Wallet!.onSessionConnect.subscribe(_onSessionConnect);
    _web3Wallet!.onSessionRequest.subscribe(_onSessionRequest);
    _web3Wallet!.onAuthRequest.subscribe(_onAuthRequest);
    _web3Wallet!.core.relayClient.onRelayClientError
        .subscribe(_onRelayClientError);
  }

  void registerChain(String chainId) {
    WalletConnectServiceUtils.registerChain(chainId, _web3Wallet!);
  }

  void registerAccount(String chainId, String accountAddress) {
    _web3Wallet?.registerAccount(
        chainId: chainId, accountAddress: accountAddress);
  }

  Future<void> preload() async {
    pairings.value = _web3Wallet!.pairings.getAll();
    sessions.value = _web3Wallet!.sessions.getAll();
    auth.value = _web3Wallet!.completeRequests.getAll();
  }

  FutureOr onDispose() {
    _web3Wallet!.core.pairing.onPairingInvalid.unsubscribe(_onPairingInvalid);
    _web3Wallet!.pairings.onSync.unsubscribe(_onPairingsSync);
    _web3Wallet!.onSessionProposal.unsubscribe(_onSessionProposal);
    _web3Wallet!.onSessionProposalError.unsubscribe(_onSessionProposalError);
    _web3Wallet!.onSessionConnect.unsubscribe(_onSessionConnect);
    _web3Wallet!.onSessionRequest.unsubscribe(_onSessionRequest);
    _web3Wallet!.onAuthRequest.unsubscribe(_onAuthRequest);
    _web3Wallet!.core.relayClient.onRelayClientError
        .unsubscribe(_onRelayClientError);
  }

  Future connect({required Uri uri}) async {
    print('#2 WalletConnectService connect $uri');
    return _web3Wallet?.pair(uri: uri);
  }

  List<PairingInfo> get pairingsList => _web3Wallet!.pairings.getAll();
  List<SessionData> get sessionsList => _web3Wallet!.sessions.getAll();

  void approveConnection({required int sessionId, required String account}) {
    _web3Wallet?.approveSession(id: sessionId, namespaces: {
      'cosmos': Namespace(accounts: [
        'cosmos:euphoria-2:$account',
        'cosmos:cosmoshub-4:$account',
        'cosmos:xstaxy-1:$account',
      ], methods: [
        'cosmos_signDirect',
        'cosmos_getAccounts',
        'cosmos_signAmino'
      ], events: [
        'chainChanged',
        'accountsChanged'
      ]),
    });
  }

  ///
  /// Rejects a connection request
  void rejectConnection({required int sessionId}) {
    _web3Wallet?.rejectSession(
        id: sessionId, reason: Errors.getSdkError(Errors.USER_REJECTED));
  }

  void approveRequest({
    required int id,
    required String topic,
    required dynamic msg,
  }) async {
    final r = {'id': id, 'result': msg, 'jsonrpc': '2.0'};
    final response = JsonRpcResponse.fromJson(r);

    print('approveRequest $response');
    _web3Wallet?.respondSessionRequest(topic: topic, response: response);
  }

  void rejectRequest({
    required int id,
    required String topic,
  }) {
    final r = {
      'id': id,
      'error': {
        'code': -5000,
        'message': 'User rejected the request',
      },
      'jsonrpc': '2.0'
    };
    final response = JsonRpcResponse.fromJson(r);
    _web3Wallet?.respondSessionRequest(topic: topic, response: response);
  }

  void registerEventCallBack(
      {required void Function(SessionConnect? sessionConnect) onSessionConnect,
      required void Function(SessionRequestEvent? args) onSessionRequest,
      required void Function(SessionProposalEvent? args) onSessionProposal,
      required void Function(SessionProposalErrorEvent? args)
          onSessionProposalError,
      required void Function(PairingEvent? args) onPairingCreate,
      required void Function(PairingInvalidEvent? args) onPairingInvalid,
      required void Function(ErrorEvent? args) onRelayClientError,
      required void Function(StoreSyncEvent? args) onPairingsSync,
      required void Function(AuthRequest? args) onAuthRequest}) {
    this.onSessionConnect = onSessionConnect;
    this.onSessionRequest = onSessionRequest;
    this.onSessionProposal = onSessionProposal;
    this.onSessionProposalError = onSessionProposalError;
    this.onPairingCreate = onPairingCreate;
    this.onPairingInvalid = onPairingInvalid;
    this.onRelayClientError = onRelayClientError;
    this.onPairingsSync = onPairingsSync;
    this.onAuthRequest = onAuthRequest;
  }

  Function(SessionConnect? args)? onSessionConnect;
  Function(SessionRequestEvent? args)? onSessionRequest;
  Function(SessionProposalEvent? args)? onSessionProposal;
  Function(SessionProposalErrorEvent? args)? onSessionProposalError;
  Function(PairingEvent? args)? onPairingCreate;
  Function(PairingInvalidEvent? args)? onPairingInvalid;
  Function(ErrorEvent? args)? onRelayClientError;
  Function(StoreSyncEvent? args)? onPairingsSync;
  Function(AuthRequest? args)? onAuthRequest;

  void approveAuthRequest({required int id, required String iss}) {
    _web3Wallet?.respondAuthRequest(id: id, iss: iss);
  }

  void rejectAuthRequest({required int id, required String iss}) {
    _web3Wallet?.respondAuthRequest(
        id: id, iss: iss, error: Errors.getSdkError(Errors.USER_REJECTED));
  }

  void _onPairingsSync(StoreSyncEvent? args) {
    print('#PyxisDebug _onPairingsSync $args');
    if (args != null) {
      pairings.value = _web3Wallet!.pairings.getAll();
    }
    onPairingsSync?.call(args);
  }

  void _onRelayClientError(ErrorEvent? args) {
    print('#PyxisDebug _onRelayClientError $args');
    debugPrint('[$runtimeType] _onRelayClientError ${args?.error}');
    onRelayClientError?.call(args);
  }

  void _onSessionProposalError(SessionProposalErrorEvent? args) {
    print('#PyxisDebug _onSessionProposalError $args');
    debugPrint('[$runtimeType] _onSessionProposalError $args');
    onSessionProposalError?.call(args);
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
    print('#PyxisDebug _onSessionProposal $args');
    onSessionProposal?.call(args);
    // args.params.generatedNamespaces
  }

  void _onPairingInvalid(PairingInvalidEvent? args) {
    debugPrint('[$runtimeType] _onPairingInvalid $args');
    onPairingInvalid?.call(args);
  }

  void _onPairingCreate(PairingEvent? args) {
    debugPrint('[$runtimeType] _onPairingCreate $args');
    onPairingCreate?.call(args);
  }

  // Handle the session request event
  void _onSessionRequest(SessionRequestEvent? args) {
    // Print debug information about the event
    print('#PyxisDebug _onSessionRequest $args');

    // Check if the event is null, and return if so
    if (args == null) return;

    // Execute any custom callback for session requests
    onSessionRequest?.call(args);
  }

  void _onSessionConnect(SessionConnect? args) {
    print('#PyxisDebug SessionConnect $args');
    onSessionConnect?.call(args);
  }

  void _onAuthRequest(AuthRequest? args) async {
    print('#PyxisDebug _onAuthRequest $args');
    onAuthRequest?.call(args);
  }

  Future disconnectSession(SessionData sessionData) async {
    await _web3Wallet?.disconnectSession(
        topic: sessionData.topic,
        reason: Errors.getSdkError(
          Errors.USER_DISCONNECTED,
        ));
    return;
  }
}
