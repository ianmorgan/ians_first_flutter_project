import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'const.dart';
import 'login.dart';
import 'app-page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => DutiesModel()),
      ChangeNotifierProvider(create: (context) => AppStateModel()),
      ChangeNotifierProvider(create: (context) => UserProfileModel())
    ],
    child: MyApp(),
  ));
}

Future<void> _launchHomePage() async {
  if (!await launchUrl(Uri.parse('https://myclub.run'), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch home page');
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
            home: FutureBuilder<PersistedState>(
                future: _loadCurrentUser(),
                builder: (buildContext, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isLoggedIn()) {
                      // Return your login here
                      //return LoginPage();
                      //return Container(color: Colors.purple);
                      return AppPageRoute(persistedState: snapshot.data!);
                    } else {
                      // Return your home here
                      //return AppPageRoute();
                      return LoginPage();
                    }
                  } else {
                    // Return loading screen while reading preferences
                    return Center(child: CircularProgressIndicator());
                  }
                })
            //home: const MyHomePage(title: 'Please Login'),
            ));
  }

  @override
  void initState() {
    super.initState();
  }

  /// Load the initial counter value from persistent storage on start,
  /// or fallback to 0 if it doesn't exist.
  Future<PersistedState> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    var currentUser = prefs.getString(storedUserNameKey) ?? "";
    var currentToken = prefs.getString(storedTokenKey) ?? "";
    var currentClub = prefs.getString(storedSelectedClubKey) ?? "";
    return PersistedState(username: currentUser, token: currentToken, selectedClub: currentClub);
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

Widget buildHomePage(BuildContext context) {
  return Consumer<AppStateModel>(builder: (context, appStateModel, child) {
    return const Center(
        child: Column(children: [
      const Text("Login page was here !!!!"),
      ElevatedButton(
        onPressed: _launchHomePage,
        child: Text('Show the homepage'),
      )
    ]));
  });
}
