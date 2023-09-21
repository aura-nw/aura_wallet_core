import 'dart:convert';
import 'package:example/src/pages/inapp_wallet_singleton_handler.dart';
import 'package:flutter/material.dart';

import '../widgets/loading_screen_mixin.dart';

class MakeQuerySmartContract extends StatefulWidget {
  const MakeQuerySmartContract({Key? key}) : super(key: key);

  @override
  State<MakeQuerySmartContract> createState() => _MakeQuerySmartContractState();
}

class _MakeQuerySmartContractState extends State<MakeQuerySmartContract>
    with ScreenLoaderMixin {
  final TextEditingController _contractAddressController =
      TextEditingController();
  final TextEditingController _queryTriggerController = TextEditingController();
  final TextEditingController _parameterController = TextEditingController();

  static const String contractAddress =
      'aura1h3kn034nh4p8gwnuqya80rdhyvg3h775ukwul49qsugzk7v3qprs2nhgzh';

  final InAppWalletProviderHandler handler =
      InAppWalletProviderHandler.instance;

  @override
  void initState() {
    super.initState();
    _contractAddressController.text = contractAddress;
    _queryTriggerController.text = 'balance';
    _parameterController.text = '{"address": "${handler.bech32Address}"}';
  }

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Smart Contract'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Wallet Address: ${handler.bech32Address}'),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _contractAddressController,
                decoration: const InputDecoration(
                  hintText: 'Contract address',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _queryTriggerController,
                decoration: const InputDecoration(
                  hintText: 'Input Query Trigger',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _parameterController,
                decoration: const InputDecoration(
                  hintText: 'Input Query Param',
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () async {
                  showLoading();

                  if (_queryTriggerController.text.isEmpty) return;

                  Map<String, dynamic> param =
                      jsonDecode(_parameterController.text.trim());

                  Map<String, dynamic> query = {
                    _queryTriggerController.text.trim(): param,
                  };

                  final currentWallet = await handler
                      .getWalletCore()
                      .loadCurrentWallet(handler.bech32Address);
                  await currentWallet!
                      .makeInteractiveQuerySmartContract(
                        contractAddress: contractAddress,
                        query: query,
                      )
                      .then((res) {
                        final Map<String, dynamic> json = jsonDecode(res);

                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: SizedBox(
                                height: 250,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Balance : ${json['balance']}'),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      })
                      .whenComplete(
                        () => hideLoading(),
                      )
                      .onError((error, stackTrace) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: SizedBox(
                                height: 100,
                                child: Center(
                                  child: Text(error.toString()),
                                ),
                              ),
                            );
                          },
                        );
                      });
                },
                child: const Text('Query'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
