import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'models.dart';
import 'widgets.dart';
import 'const.dart';
import 'app-page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        return ScaffoldMessenger(
          key: _scaffoldMessengerKey,
          child: Scaffold(
            body: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _header(authModel, context),
                  _inputField(authModel, context, _scaffoldMessengerKey),
                  _forgotPassword(context),
                  _signup(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _header(AuthModel authModel, context) {
    return Column(
      children: [
        Text(
          authModel.isLoggedIn ? "Welcome Back" : "Please Login",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const Text("Enter your credentials to Login"),
      ],
    );
  }

  _inputField(AuthModel authModel, context, GlobalKey<ScaffoldMessengerState> scaffoldKey) {
    final userNameController = TextEditingController(text: authModel.displayableUserName());
    final passwordController = TextEditingController(text: authModel.attemptedPassword);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //Text("user: ${authModel.username}, isLoggedId ${authModel.isLoggedIn}, isCallingApi ${authModel.isCallingApi}"),
        TextFormField(
            decoration: InputDecoration(
                hintText: "Username",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                fillColor: baseColour.withOpacity(0.1),
                filled: true,
                prefixIcon: const Icon(Icons.person)),
            controller: userNameController),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            fillColor: baseColour.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
          controller: passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // hardcode at the moment
            authModel.startLogin(userNameController.text, passwordController.text);
            doRequestToken(userNameController.text)
                .then((value) => {doProcessResult(context, value, authModel, scaffoldKey)})
                .onError((error, stackTrace) => {doProcessError(context, error, authModel, scaffoldKey)});
          },
          style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: baseAnalogous1),
          child: authModel.isCallingApi
              ? const CircularProgressIndicator()
              : const Text(
                  "Login",
                  style: TextStyle(fontSize: 20, color: whiteText),
                ),
        )
      ],
    );
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {},
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: baseColour),
      ),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(title: "home page"),
                  ));
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(color: baseColour),
            ))
      ],
    );
  }
}

void doProcessResult(BuildContext context, http.Response response, AuthModel authModel, GlobalKey<ScaffoldMessengerState> scaffoldKey) {
  if (response.statusCode == 200) {
    // note, the response contains the token
    doSuccessLogin(context, response.body, authModel, scaffoldKey);
  } else if (response.statusCode == 401) {
    authModel.cancelLogin();
    const ErrorSnackBar("Not authorised, please check the username and password").showWithKey(scaffoldKey);
  } else {
    authModel.cancelLogin();
    ErrorSnackBar("Sorry, something went wrong. ('${response.body}'). Please try again after a short delay.").showWithKey(scaffoldKey);
  }
}

void doProcessError(BuildContext context, error, AuthModel authModel, GlobalKey<ScaffoldMessengerState> scaffoldKey) {
  authModel.cancelLogin();
  ErrorSnackBar("Sorry, something went wrong, ('$error'). Please try again after a short delay").showWithKey(scaffoldKey);
}

Future<http.Response> doRequestToken(String username) {
  var delay = Future<int>.delayed(const Duration(seconds: 3), () => 0);
  return delay.then((value) => http.post(Uri.parse('https://myclub.run/auth/api/doRequestToken?authMode=Production'),
      body: '{"username":"$username"}'));
}

Future<dynamic> doSuccessLogin(BuildContext context, String token, AuthModel authModel, GlobalKey<ScaffoldMessengerState> scaffoldKey) {
  authModel.completeLogin(token);
  SuccessSnackBar("Logged in as '${authModel.username}'").showWithKey(scaffoldKey);

  return Navigator.of(context, rootNavigator: false).pushReplacement(MaterialPageRoute(
    builder: (context) => const AppPageRoute(),
  ));
}
