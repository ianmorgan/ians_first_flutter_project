import 'package:flutter/material.dart';
import 'package:ians_first_flutter_project/models.dart';

import 'main.dart';
import 'const.dart';

class ErrorSnackBar {
  final String _message;

  const ErrorSnackBar(this._message);

  void show() {
    if (scaffoldMessengerKey.currentState != null) {
      scaffoldMessengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(_message, style: const TextStyle(color: Colors.red))));
    }
  }

  void showWithKey(GlobalKey<ScaffoldMessengerState> key) {
    key.currentState!.showSnackBar(SnackBar(content: Text(_message, style: const TextStyle(color: Colors.red))));
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

  void showWithKey(GlobalKey<ScaffoldMessengerState> key) {
    key.currentState!.showSnackBar(SnackBar(content: Text(_message, style: const TextStyle(color: Colors.green))));
  }
}

Widget buildUserImage(String username, double size) {
  return ClipOval(
    child: SizedBox.fromSize(
      size: Size.fromRadius(size), // Image radius
      child: Image.network('https://myclub.run/users/profileImage/$username', fit: BoxFit.cover),
    ),
  );
}

Widget buildClubImage(String club, double size) {
  return ClipOval(
    child: SizedBox.fromSize(
      size: Size.fromRadius(size), // Image radius
      child: Image.network('https://myclub.run/clubs/$club/profileImage', fit: BoxFit.cover),
    ),
  );
}

Widget buildClubPanel(ClubProfile club) {
  return Card(
    color: baseColourLight2,
    child: Column(children: [
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(width: 10),
          buildClubImage(club.slug, 24),
          Expanded(
              child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(text: "showing duties for ", style: heading3Light),
                      TextSpan(text: club.name, style: heading3)
                    ]),
                  ))),
        ],
      ),
      const SizedBox(height: 10),
    ]),
  );
}

Widget buildAlertMessage(String message) {
  return Text(message, style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.w500));
}
