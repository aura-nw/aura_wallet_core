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

### 2. In-App Wallet

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
