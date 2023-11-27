import 'package:flutter/material.dart';

import 'main.dart';

class ErrorSnackBar {
  final String _message;

  const ErrorSnackBar(this._message);

  void show() {
    if (scaffoldMessengerKey.currentState != null) {
      scaffoldMessengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(_message, style: const TextStyle(color: Colors.red))));
    }
  }
}

class SuccessSnackBar {
  final String _message;

  const SuccessSnackBar(this._message);

  void show() {
    if (scaffoldMessengerKey.currentState != null) {
      scaffoldMessengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(_message, style: const TextStyle(color: Colors.green))));
    }
  }
}
