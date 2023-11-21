import 'package:flutter/material.dart';

class ErrorSnackBar  {
  final String _message;

  const ErrorSnackBar(this._message);

  void build(BuildContext context) {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
         content: Text(_message, style: const TextStyle(color: Colors.red))));
  }
}


class SuccessSnackBar  {
  final String _message;
  const SuccessSnackBar(this._message);

  void build(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_message, style: const TextStyle(color: Colors.green))));
  }
}
