import 'package:aura_wallet_core/aura_environment.dart';
import 'package:aura_wallet_core/aura_wallet_core.dart';
import 'package:flutter/material.dart';

class InAppWalletProviderHandler {
  static InAppWalletProviderHandler instance = InAppWalletProviderHandler();

  final AuraWalletCore _walletCore = AuraWalletCore.create(
      environment: AuraWalletCoreEnvironment.testNet);

  AuraWalletCore getWalletCore(){
    checkValidBech32Address();
    return _walletCore;
  }

  final List<VoidCallback> _listeners = List.empty(growable: true);
  String bech32Address = '';
  String _backupBech32Address = '';

  void setBech32Address(String bech32Address){
    if(bech32Address.isNotEmpty){
      _backupBech32Address = bech32Address;
    }
    this.bech32Address = bech32Address;

    checkValidBech32Address();
  }

  void addListener(VoidCallback callback){
    if(_listeners.contains(callback)) return;

    _listeners.add(callback);
  }

  void removeListener(VoidCallback callback){
    if(_listeners.contains(callback)){
      _listeners.remove(callback);
    }
  }

  void checkValidBech32Address()async{
    if(bech32Address.isEmpty){
      try{
        print(_backupBech32Address);
        final currentWallet = await _walletCore.loadCurrentWallet(_backupBech32Address);

        print('current wallet = ${currentWallet}');

        await currentWallet?.removeCurrentWallet(_backupBech32Address);
      }catch(e){
        print('run nnn -- ${e.toString()}');
      }finally{
        _backupBech32Address = bech32Address;
        for(final callback in _listeners){
          callback.call();
        }
      }
    }
  }
}
