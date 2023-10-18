import 'package:aura_wallet_core/config_options/biometric_options.dart';
import 'package:aura_wallet_core/config_options/environment_options.dart';
import 'package:example/src/app_navigator.dart';
import 'package:example/src/application/app_theme/cubit/app_theme_cubit.dart';
import 'package:example/src/application/global_state/global_cubit.dart';
import 'package:example/src/application/global_state/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/application/global/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppGlobal.init(
    AuraEnvironment.testNet,
    BiometricOptions(
      requestTitle: 'Your request title',

      ///For android
      requestSubtitle: 'Your request subtitle',
      authenticationTimeOut: 10,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppNavigator.navigatorKey,
      initialRoute: AppRoutePath.inAppWallet,
      onGenerateRoute: AppNavigator.onGenerateRoute,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AppThemeCubit(),
            ),
            BlocProvider(
              create: (context) => AppGlobalCubit(),
            ),
          ],
          child: Builder(
            builder: (context) {
              return BlocListener<AppGlobalCubit, GlobalState>(
                listenWhen: (previous, current) =>
                    current.status != previous.status,
                listener: (context, state) {
                  switch (state.status) {
                    case AppGlobalStatus.authorized:
                      AppNavigator.replaceAllWith(
                        AppRoutePath.walletDetail,
                      );
                      break;
                    case AppGlobalStatus.unauthorized:
                      AppNavigator.replaceAllWith(AppRoutePath.inAppWallet);
                      break;
                  }
                },
                child: child ?? const SizedBox(),
              );
            },
          ),
        );
      },
    );
  }
}
