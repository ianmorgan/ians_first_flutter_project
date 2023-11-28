import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'models.dart';
import 'login.dart';
import 'const.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(builder: (context, authModel, child) {
      return Consumer<UserProfileModel>(builder: (context, userProfileModel, child) {
        return FutureBuilder<bool>(
            future: fetchUserProfile(authModel, userProfileModel),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                    child: Column(children: [
                  Text("Home page for ${authModel.username} - goes here"),
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
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else {
                return const Text("Fetching data....", style: TextStyle(color: baseColour));
                // By default, show a loading spinner.
                // return const Center(
                //   child: CircularProgressIndicator(),
                // );
              }
            });
      });
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

Future<bool> fetchUserProfile(AuthModel authModel, UserProfileModel userProfileModel) async {
  print("**** fetchUserProfile for ${authModel.username} ****");

  final response =
      await http.get(Uri.parse('https://myclub.run/api/${authModel}/profile'), headers: {"JWT": authModel.token});

  if (response.statusCode == 200) {
    var profile = UserProfile.fromJson(jsonDecode(response.body));
    userProfileModel.initialLoad(profile);
    return true;
  }
  return false;
}
