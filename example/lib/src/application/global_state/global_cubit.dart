import 'package:flutter/material.dart';

import 'global_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppGlobalCubit extends Cubit<GlobalState> {
  AppGlobalCubit()
      : super(
          const GlobalState(),
        );

  void changeState(GlobalState newState) {
    if (newState.status != state.status) {
      emit(newState);
    }
  }

  static AppGlobalCubit of(BuildContext context) =>
      BlocProvider.of<AppGlobalCubit>(context);
}
