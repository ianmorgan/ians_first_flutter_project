import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models.dart';
import 'const.dart';
import 'widgets.dart';
import 'login.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => DutiesModel()),
      ChangeNotifierProvider(create: (context) => AuthModel())
    ],
    child: const MyApp(),
  ));
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
          home: LoginPage()
          //home: const MyHomePage(title: 'Please Login'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _myController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: baseColour,
          title: Text(widget.title, textAlign: TextAlign.center),
          bottom: TabBar(
            tabs: [
              const Tab(icon: Icon(Icons.home), text: 'Home'),
              const Tab(icon: Icon(Icons.task), text: 'Tasks'),
              const Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
            controller: _myController,
          ),
        ),
        body: TabBarView(controller: _myController, children: [
          buildHomePage(context),
          Text("tab 2"),
          Text("tab 3"),
        ]));
  }

  @override
  void initState() {
    super.initState();
    _myController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _myController.dispose();
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
  final _myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Consumer<AuthModel>(builder: (context, authModel, child) {
      return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Text(" ${authModel.username} - ${authModel.isCallingApi}" ),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 3) {
                  return 'Please enter a user name (at least 3 characters)';
                }
                return null;
              },
              controller: _myController,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // FutureBuilder(
                    //     future: doRequestToken(_myController.text),
                    //     builder: (context, data) {
                    //       print("*** in builder *** " + data.hasData.toString());
                    //       if (data.hasData) {
                    //         if (data.data!.statusCode == 200) {
                    //
                    //             //successLogin(context, _myController.text, data.data!.body, authModel);
                    //             authModel.login(_myController.text, data.data!.body);
                    //
                    //             WidgetsBinding.instance.addPostFrameCallback((_) =>
                    //                 Navigator.push(context, MaterialPageRoute(builder: (context) {
                    //                   return DutiesPageRoute();
                    //                 })));
                    //
                    //         }
                    //         return Text(data.data!.body);
                    //       } else {
                    //         return Center(child: CircularProgressIndicator());
                    //       }
                    //     });

                    authModel.startLogin(_myController.text, "password");
                    doRequestToken(_myController.text).then((value) => {
                        if (value.statusCode == 200)
                            // note, the response contains the token
                            {doSuccessLogin(context,  value.body, authModel)}
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
    });
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }
}




Widget buildHomePage(BuildContext context) {
  return Consumer<AuthModel>(builder: (context, authModel, child) {
    return Center(
        child: Column(children: [
      LoginForm(),
      ElevatedButton(
        onPressed: _launchHomePage,
        child: Text('Show the homepage'),
      )
    ]));
  });
}
