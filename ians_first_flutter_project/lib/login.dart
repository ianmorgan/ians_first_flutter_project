import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    return Consumer<AppStateModel>(
      builder: (context, appStateModel, child) {
        return ScaffoldMessenger(
          key: _scaffoldMessengerKey,
          child: Scaffold(
            body: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _header(appStateModel),
                  _inputField(appStateModel, context, _scaffoldMessengerKey),
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

  _header(AppStateModel appStateModel) {
    return Column(
      children: [
        Text(
          appStateModel.isLoggedIn ? "Welcome Back" : "Please Login",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
        ),
        const Text("Enter your credentials to Login"),
      ],
    );
  }

  _inputField(AppStateModel appStateModel, context, GlobalKey<ScaffoldMessengerState> scaffoldKey) {
    final userNameController = TextEditingController(text: appStateModel.displayableUserName());
    final passwordController = TextEditingController(text: appStateModel.attemptedPassword);

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
            appStateModel.startLogin(userNameController.text, passwordController.text);
            _doRequestToken(userNameController.text)
                .then((value) => {_doProcessResult(context, value, appStateModel, scaffoldKey)})
                .then((value) => _saveLogin(appStateModel))
                .onError((error, stackTrace) => _doProcessError(context, error, appStateModel, scaffoldKey));
          },
          style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: baseAnalogous1),
          child: appStateModel.isCallingApi
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
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => const MyHomePage(title: "home page"),
              //     ));
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(color: baseColour),
            ))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }


  Future<dynamic> _doSuccessLogin(
      BuildContext context, String token, AppStateModel appStateModel, GlobalKey<ScaffoldMessengerState> scaffoldKey) {
    appStateModel.completeLogin(token);
    SuccessSnackBar("Logged in as '${appStateModel.username}'").showWithKey(scaffoldKey);

    return Navigator.of(context, rootNavigator: false).pushReplacement(MaterialPageRoute(
      builder: (context) => AppPageRoute(persistedState: appStateModel.buildPersistedState()),
    ));
  }

  Future<void> _saveLogin(AppStateModel appStateModel) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString(storedUserNameKey, appStateModel.username);
      prefs.setString(storedTokenKey, appStateModel.token);
      prefs.setString(storedSelectedClubKey, appStateModel.selectedClub);
    });
  }

  void _doProcessResult(BuildContext context, http.Response response, AppStateModel appStateModel,
      GlobalKey<ScaffoldMessengerState> scaffoldKey) {
    if (response.statusCode == 200) {
      // note, the response contains the token
      _doSuccessLogin(context, response.body, appStateModel, scaffoldKey);
    } else if (response.statusCode == 401) {
      appStateModel.cancelLogin();
      const ErrorSnackBar("Not authorised, please check the username and password").showWithKey(scaffoldKey);
    } else {
      appStateModel.cancelLogin();
      ErrorSnackBar("Sorry, something went wrong. ('${response.body}'). Please try again after a short delay.")
          .showWithKey(scaffoldKey);
    }
  }

  void _doProcessError(
      BuildContext context, error, AppStateModel appStateModel, GlobalKey<ScaffoldMessengerState> scaffoldKey) {
    appStateModel.cancelLogin();
    ErrorSnackBar("Sorry, something went wrong, ('$error'). Please try again after a short delay")
        .showWithKey(scaffoldKey);
  }

  Future<http.Response> _doRequestToken(String username) {
    var delay = Future<int>.delayed(const Duration(seconds: simulatedDelay), () => 0);
    return delay.then((value) => http.post(Uri.parse('https://myclub.run/auth/api/doRequestToken?authMode=Production'),
        body: '{"username":"$username"}'));
  }
}
