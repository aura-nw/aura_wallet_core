import 'dart:async';

import 'package:flutter/material.dart';

mixin ScreenLoaderMixin<T extends StatefulWidget> on State<T> {
  final loadingController = StreamController<bool>();

  Widget buildLoader() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                  child: buildLoader(),
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}
