import 'package:example/src/app_navigator.dart';
import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:example/src/presentation/widgets/button_widget.dart';
import 'package:example/src/utils/loader_mixin.dart';
import 'package:flutter/material.dart';

class InAppWalletPage extends StatefulWidget {
  const InAppWalletPage({super.key, required this.title});

  final String title;

  @override
  State<InAppWalletPage> createState() => _InAppWalletPageState();
}

class _InAppWalletPageState extends State<InAppWalletPage>
    with ScreenLoaderMixin {
  @override
  Widget builder(BuildContext context) {
    return AppThemeBuilder(
      builder: (theme) {
        return Scaffold(
          backgroundColor: theme.darkColor,
          appBar: AppBar(
            backgroundColor: theme.darkColor,
            centerTitle: true,
            title: Text(widget.title),
            leading: const SizedBox(),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InactiveGradientButton(
                  text: 'Create Wallet',
                  onPress: () =>
                      AppNavigator.push(AppRoutePath.generateHdWallet),
                ),
                const SizedBox(
                  height: 50,
                ),
                InactiveGradientButton(
                  text: 'Restore',
                  onPress: () =>
                      AppNavigator.push(AppRoutePath.restoreHdWallet),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
