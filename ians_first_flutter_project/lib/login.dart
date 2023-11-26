import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'models.dart';
import 'widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _header(context),
                  _inputField(authModel, context),
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

  _header(context) {
    return const Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credential to login"),
      ],
    );
  }

  _inputField(AuthModel authModel, context) {
    final userNameController = TextEditingController();
    final passwordController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: InputDecoration(
              hintText: "Username",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              fillColor: Colors.purple.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.person)),
          controller: userNameController,
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 3) {
              return 'Please enter a user name (at least 3 characters)';
            }
            return null;
          },
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
          controller: passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // hardcode at the moment
            authModel.login(userNameController.text, "some token");
            doRequestToken(userNameController.text).then((value) => {
              if (value.statusCode == 200)
              // note, the response contains the token
                {successLogin(context, userNameController.text, value.body, authModel)}
              else if (value.statusCode == 401)
                {
                  ErrorSnackBar(
                      "Not authorised, please check the name. (status code = ${value.statusCode})")
                      .build(context)
                }
              else
                {
                  ErrorSnackBar("Opps, that failed. (status code = ${value.statusCode}) ) - ${value.body}")
                      .build(context)
                }
            });

            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const MyHomePage(title: "home page"),
            //     ));
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.purple,
          ),
          child: const Text(
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
