# aura_sdk

## Description
A Flutter plugin support dApp connect to Aura from Coin98 Wallet.

## Installation
Add [install](https://github.com/aura-nw/aura-mobile-sdk) to your pubspec.yaml

Example

```yaml
    aura_sdk 1.0.0
```

## Step by step

### 1. Init a AuraConnect SDK:
``` dart
  AuraSDK auraSDK = AuraSDK.init(
        environment: AuraWalletEnvironment.testNet,
        "DApp Name",
        "DApp Logo",
        "app://open.my.app");
```
 callBackUrl is the link that the wallet will open after user approved the connection

### 2. External Wallet

##### 1. Call the function sdk.connectWallet() to open connection with the Wallet
``` dart
	AuraWalletConnectionResult result = await auraSDK.externalWallet.connectWallet();
```
 AuraWalletConnectionResult  is the result of the connection, you have to storage the result.idConnection to use for "transfer fuction" later
 
 
##### 3. After the **connectWallet()** has been called, the SDK will open the Wallet, and send a request for connect. We have some note on this step:
- The Wallet MUST init the Aura Chain ( Mainnet or Testnet )
- If you use the iOS, the trigger "Approved" will automatic open the callBackUrl, but if you use the Android devices, the callBackUrl may not called, you have to open your DApp manual ** (This is a known issuse, we are working on this to fix)**


##### 4. Now, the connection is ready, you can work with the Wallet. You may try the fuction: 
```dart
    AuraWalletInfoData walletInfoData = await  auraSDK.externalWallet.requestAccessWallet();
```


### 3. In-App Wallet

##### 1. Create random HD Wallet
``` dart
    WalletInfo walletInfo = await auraSDK.inAppWallet.createRandomHDWallet();
``` 


## Usage

```dart
import 'package:aura_sdk/aura_sdk.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuraConnectSdk _connectSdk = AuraConnectSdk();

  AuraWalletInfoData? data;

  @override
  void initState() {
    _connectSdk.init(
      callbackUrl: 'app://open.my.app',
      yourAppName: 'Example',
      yourAppLogo: 'logo',
    );
    super.initState();
  }

  @override
  void dispose() {
    _connectSdk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Aura sdk connect example app'),
        ),
        body: SizedBox(
          width: 400,
          height: 800,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _connectSdk.connectWallet().then((connection) {
                    print(connection.result);
                  }).catchError((error) {
                    print('error --$error');
                  });
                },
                child: const Text('Open'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _connectSdk.requestAccessWallet().then((walletData) {
                    setState(() {
                      data = walletData;
                    });
                  }).catchError((error) {
                    print('request access Wallet error ${error}');
                  });
                },
                child: const Text('Get account'),
              ),
              const SizedBox(
                height: 40,
              ),
              if (data != null) ...[
                Text('address : ${data!.data.address}'),
                Text('name : ${data!.data.name}'),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

```
