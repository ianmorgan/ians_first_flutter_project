import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'models.dart';
import 'widgets.dart';
import 'duties.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        return Scaffold(
          body: Container(
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _header(authModel, context),
                _inputField(authModel, context),
                _forgotPassword(context),
                _signup(context),
              ],
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
        const Text("Enter your credential to Login"),
      ],
    );
  }

  _inputField(AuthModel authModel, context) {
    final _userNameController = TextEditingController(text: authModel.displayableUserName());
    final _passwordController = TextEditingController(text: authModel.attemptedPassword);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("user: ${authModel.username}, isLoggedId ${authModel.isLoggedIn}, isCallingApi ${authModel.isCallingApi}"),
        TextFormField(
          decoration: InputDecoration(
              hintText: "Username",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              fillColor: Colors.purple.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.person)),
          controller: _userNameController
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            fillColor: Colors.purple.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
          controller: _passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // hardcode at the moment
            authModel.startLogin(_userNameController.text, _passwordController.text);
            doRequestToken(_userNameController.text)
                .then((value) => {doProcessResult(context, value, authModel)})
                .onError((error, stackTrace) => {
                      doProcessError(context, error, authModel)
                    });
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.purple,
          ),
          child: authModel.isCallingApi
              ? const CircularProgressIndicator()
              : const Text(
                  "Login",
                  style: TextStyle(fontSize: 20),
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
        style: TextStyle(color: Colors.purple),
      ),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Dont have an account? "),
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
              style: TextStyle(color: Colors.purple),
            ))
      ],
    );
  }
}

void doProcessResult(BuildContext context, http.Response response, AuthModel authModel) {
  //print("*** in doProcessResult ****");
  if (response.statusCode == 200) {
    // note, the response contains the token
    doSuccessLogin(context, response.body, authModel);
  } else if (response.statusCode == 401) {
    authModel.cancelLogin();
    const ErrorSnackBar("Not authorised, please check the username and password").build(context);
  } else {
    authModel.cancelLogin();
    ErrorSnackBar("Sorry, something went wrong. ('${response.body}'). Please try again after a short delay.").build(context);
  }
}

void doProcessError(BuildContext context, error, AuthModel authModel) {
  authModel.cancelLogin();
  ErrorSnackBar("Sorry, something went wrong, ('$error'). Please try again after a short delay").build(context);
}

Future<http.Response> doRequestToken(String username) {
  var delay = Future<int>.delayed(const Duration(seconds: 3), () => 0);
  return delay.then((value) => http.post(Uri.parse('https://myclub.run/auth/api/doRequestToken?authMode=Production'),
      body: '{"username":"$username"}'));
}

Future<dynamic> doSuccessLogin(BuildContext context, String token, AuthModel authModel) {
  authModel.completeLogin(token);
  SuccessSnackBar("Logged in as '${authModel.username}'").build(context);
  return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DutiesPageRoute(),
      ));
}
