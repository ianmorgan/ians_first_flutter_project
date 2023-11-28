import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(builder: (context, authModel, child) {
      return Center(
          child: Column(children: [
        Text("Home page for ${authModel.username} goes here"),
        ElevatedButton(
          onPressed: () {
            _launchHomePage(authModel.username);
          }, //_launchHomePage,
          child: const Text('Open your home page on the website'),
        ),
        ElevatedButton(
          onPressed: () {
            _showLogoutConfirmation(context, authModel);
          }, //_launchHomePage,
          child: const Text('Logout'),
        )
      ]));
    });
  }
}

void _showLogoutConfirmation(BuildContext context, AuthModel authModel) {
  // set up the buttons
  Widget cancelButton = OutlinedButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = OutlinedButton(
    child: Text("Logout"),
    onPressed: () {
      Navigator.of(context).pop();
      _doLogout(context, authModel);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Logout"),
    content: Text("${authModel.username}, would you like to logout?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void _doLogout(BuildContext context, AuthModel authModel) {
  authModel.logout();
  Navigator.of(context, rootNavigator: false).pushReplacement(MaterialPageRoute(
    builder: (context) => const LoginPage(),
  ));
}

Future<void> _launchHomePage(String username) async {
  if (!await launchUrl(Uri.parse('https://myclub.run/$username'), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch home page');
  }
}
