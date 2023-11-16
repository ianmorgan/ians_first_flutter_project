import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'duties.dart';
import 'const.dart';

void main() {
  runApp(const MyApp());
}

Future<void> _launchHomePage() async {
  if (!await launchUrl(Uri.parse('https://myclub.run'), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch home page');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // see https://www.flutterbeads.com/close-hide-keyboard-flutter/ and
          //    https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
          FocusManager.instance.primaryFocus?.unfocus();

          // FocusScopeNode currentFocus = FocusScope.of(context);
          //
          // if (!currentFocus.hasPrimaryFocus) {
          //   currentFocus.unfocus();
          // }
        },
        child: MaterialApp(
          title: 'MyClub dot Run',
          theme: ThemeData(
            // This is the theme of your application.
            //
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Please Login'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: baseColour,
        title: Text(widget.title, textAlign: TextAlign.center),
      ),
      body: const Center(
          child: Column(
        children: [
          LoginForm(),
          ElevatedButton(
            onPressed: _launchHomePage,
            child: Text('Show the homepage'),
          ),
        ],
      )),
    );
  }
}

// Define a custom Form widget.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => LoginFormState();
}

// Define a corresponding State class.
// This class holds data related to the form.
class LoginFormState extends State<LoginForm> {
  // Create a global key that uniquely identifies the Form widget and allows validation of the form.

  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 3) {
                return 'Please enter a user name (at least 3 characters)';
              }
              return null;
            },
            controller: myController,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  doLogin(myController.text).then((value) => {
                        if (value.statusCode == 200)
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DutiesPageRoute()),
                            )
                          }
                        else if (value.statusCode == 401)
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "opps, not authorised - please check the name" + value.statusCode.toString())),
                            )
                          }
                        else
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("opps that failed. status code is:" + value.statusCode.toString())),
                            )
                          }
                      });
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                }
              },
              child: const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }
}

Future<http.Response> doLogin(String username) {
  return http.get(Uri.parse('https://myclub.run/auth/doLogin?username=$username&password=&from='));
}

Future<http.Response> doLogin2(String username) {
  var json = '{"username":"$username"}';
  return http.post(Uri.parse('https://myclub.run/auth/api/doLogin'),
      headers: {"Content-Type": "application/json"}, body: json);
}
