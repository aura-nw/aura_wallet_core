import 'dart:convert';
import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:example/src/application/global/global.dart';
import 'package:example/src/application/global_state/global_cubit.dart';
import 'package:example/src/presentation/widgets/button_widget.dart';
import 'package:example/src/utils/loader_mixin.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _contractAddressController.text = contractAddress;
    _queryTriggerController.text = 'balance';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parameterController.text =
        '{"address": "${AppGlobalCubit.of(context).state.bech32Address}"}';
  }

  @override
  Widget builder(BuildContext context) {
    return AppThemeBuilder(
      builder: (theme) {
        return Scaffold(
          backgroundColor: theme.darkColor,
          appBar: AppBar(
            backgroundColor: theme.darkColor,
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
                  Text(
                    'Wallet Address: ${AppGlobalCubit.of(context).state.bech32Address}',
                    style: TextStyle(
                      fontSize: 24,
                      color: theme.lightColor,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _contractAddressController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Contract address',
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _queryTriggerController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Input Query Trigger',
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
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
                  InactiveGradientButton(
                    onPress: () async {
                      showLoading();

                      if (_queryTriggerController.text.isEmpty) return;

                      Map<String, dynamic> param =
                          jsonDecode(_parameterController.text.trim());

                      Map<String, dynamic> query = {
                        _queryTriggerController.text.trim(): param,
                      };

                      final currentWallet =
                          await AppGlobal.sdkCore.loadStoredWallet();
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
                                          onPressed: () =>
                                              Navigator.pop(context),
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
                    text: 'Query',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
