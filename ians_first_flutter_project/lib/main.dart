import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    child: TheApp(),
  ));
}

// Future<void> _launchHomePage() async {
//   if (!await launchUrl(Uri.parse('https://myclub.run'), mode: LaunchMode.externalApplication)) {
//     throw Exception('Could not launch home page');
//   }
// }

class TheApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _TheAppState();
}

class _TheAppState extends State<TheApp> {
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
                future: _loadPersistedState(),
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
                      return const LoginPage();
                    }
                  } else {
                    // Return loading screen while reading preferences
                    return const Center(child: CircularProgressIndicator());
                  }
                })
            ));
  }

  @override
  void initState() {
    super.initState();
  }

  Future<PersistedState> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    var currentUser = prefs.getString(storedUserNameKey) ?? "";
    var currentToken = prefs.getString(storedTokenKey) ?? "";
    var currentClub = prefs.getString(storedSelectedClubKey) ?? "";
    return PersistedState(username: currentUser, token: currentToken, selectedClub: currentClub);
  }
}

