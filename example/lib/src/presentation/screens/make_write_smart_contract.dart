import 'dart:convert';
import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:example/src/application/global/global.dart';
import 'package:example/src/application/global_state/global_cubit.dart';
import 'package:example/src/presentation/widgets/button_widget.dart';
import 'package:example/src/utils/loader_mixin.dart';
import 'package:flutter/material.dart';

class MakeWriteSmartContract extends StatefulWidget {
  const MakeWriteSmartContract({Key? key}) : super(key: key);

  @override
  State<MakeWriteSmartContract> createState() => _MakeWriteSmartContractState();
}

class _MakeWriteSmartContractState extends State<MakeWriteSmartContract>
    with ScreenLoaderMixin {
  final TextEditingController _contractAddressController =
      TextEditingController();
  final TextEditingController _triggerController = TextEditingController();
  final TextEditingController _parameterController = TextEditingController();

  static const String contractAddress =
      'aura1h3kn034nh4p8gwnuqya80rdhyvg3h775ukwul49qsugzk7v3qprs2nhgzh';

  String hash = '';

  @override
  void initState() {
    super.initState();
    _contractAddressController.text = contractAddress;
    _triggerController.text = 'transfer';

    _parameterController.text =
        '{"amount" : "200","recipient": "aura1yukgemvxtr8fv6899ntd65qfyhwgx25d2nhvj6"}';
  }

  @override
  Widget builder(BuildContext context) {
    return AppThemeBuilder(
      builder: (theme) {
        return Scaffold(
          backgroundColor: theme.darkColor,
          appBar: AppBar(
            backgroundColor: theme.darkColor,
            title: const Text('Write smart contract'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 30,
              ),
              child: Column(
                children: [
                  Text(
                    'Wallet Address: ${AppGlobalCubit.of(context).state.bech32Address}',
                    style: TextStyle(
                      color: theme.lightColor,
                      fontSize: 24,
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
                    controller: _triggerController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Input Trigger',
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Input Param',
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
                    height: 50,
                  ),
                  InactiveGradientButton(
                    onPress: () async {
                      if (_triggerController.text.isEmpty) return;

                      showLoading();

                      Map<String, dynamic> param =
                          jsonDecode(_parameterController.text.trim());

                      Map<String, dynamic> executeMessage = {
                        _triggerController.text.trim(): param,
                      };

                      print(executeMessage);
                      final currentWallet =
                          await AppGlobal.sdkCore.loadStoredWallet();

                      await currentWallet!.makeInteractiveWriteSmartContract(
                        contractAddress: contractAddress,
                        executeMessage: executeMessage,
                        fee: 200,
                        gasLimit: 200,
                        funds: [
                          200,
                        ],
                      ).then((value) {
                        hash = value;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const Dialog(
                              child: SizedBox(
                                height: 100,
                                child: Center(
                                  child: Text('Success!!!!!!'),
                                ),
                              ),
                            );
                          },
                        );
                      }).onError((error, stackTrace) {
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
                      }).whenComplete(
                        () => hideLoading(),
                      );
                    },
                    text: 'Trigger',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InactiveGradientButton(
                    onPress: () async {
                      showLoading();
                      try {
                        final currentWallet =
                            await AppGlobal.sdkCore.loadStoredWallet();
                        await currentWallet!
                            .verifyTxHash(txHash: hash)
                            .then((isSuccess) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: isSuccess
                                        ? const Text('Success!!!!!!')
                                        : const Text('Error!!!!!'),
                                  ),
                                ),
                              );
                            },
                          );
                        });
                      } catch (e) {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: Text(e.toString()),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      } finally {
                        hideLoading();
                      }
                    },
                    text: 'Verify hash',
                  ),
                  const SizedBox(
                    height: 20,
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
