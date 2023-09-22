# Aura Wallet Core


## Roadmap
- [x] Create HDWallet
- [x] Restore HDWallet
- [x] Check Wallet Balance
- [x] Check Wallet History
- [x] Make(Sign) / Send transaction 
- [ ] Option for storage data with Biometric Secure

## Installation
Add [install](https://github.com/aura-nw/aura-wallet-core) to your pubspec.yaml

Example

```yaml
dependencies:
    aura_wallet_core : 1.0.0
```

## Step by step

### 1. Init a AuraWalletCore SDK:
``` dart
  final AuraWalletCore _walletCore = AuraWalletCore.create(
      environment: AuraWalletCoreEnvironment.testNet);
```

##### 1. Create random HD Wallet
``` dart
    AuraFullInfoWallet auraFullInfoWallet = await _walletCore.createRandomHDWallet();
    AuraWallet auraWallet = auraFullInfoWallet.auraWallet;
``` 
##### 2. Restore HD Wallet
``` dart
    AuraWallet auraWallet = _walletCore.restoreHDWallet(key: "private or passpharse");
``` 
##### 3. Send transaction 
``` dart
    try{
      final tx = await auraWallet.makeTransaction(
          toAddress: "toAddress", amount: "amount ( number )", fee: 'fee( number )');

      final response = await auraWallet.submitTransaction(
        signedTransaction: tx,
      );

      if (response) {
        print("success");
      } else {
        print("fail");
      }
    }catch(e){
        print("error");
    }
``` 
##### 4. Wallet Balance/History
``` dart
    /// Check Wallet Balance
    final String balance = await auraWallet.checkWalletBalance() ?? '';

    /// Check List History
    final List<AuraTransaction> list =
          await auraWallet.checkWalletHistory();
``` 

