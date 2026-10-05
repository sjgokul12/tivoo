import 'package:flutter/material.dart';

extension SnackBarContext on BuildContext {
  void showAppSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}
