import 'dart:async';
import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:flutter/material.dart';

mixin ScreenLoaderMixin<T extends StatefulWidget> on State<T> {
  final loadingController = StreamController<bool>();

  Widget _buildLoader() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      width: 72,
      height: 72,
      alignment: Alignment.center,
      child: AppThemeBuilder(
        builder: (theme) => CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.primaryColor6,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    loadingController.close();

    super.dispose();
  }

  void showLoading() {
    loadingController.add(true);
  }

  void hideLoading() {
    loadingController.add(false);
  }

  Widget builder(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        builder(context),
        StreamBuilder(
          stream: loadingController.stream,
          builder: (_, snapshot) => snapshot.data == true
              ? Positioned.fill(
                  child: _buildLoader(),
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}
