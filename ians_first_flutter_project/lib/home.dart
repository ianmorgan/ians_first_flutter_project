import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_downloader/image_downloader.dart';
import 'dart:io';

import 'models.dart';
import 'login.dart';
import 'const.dart';
import 'image-download.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(builder: (context, authModel, child) {
      return Consumer<UserProfileModel>(builder: (context, userProfileModel, child) {
        return FutureBuilder<bool>(
            future: fetchUserProfile(authModel, userProfileModel),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                    margin: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        _header(userProfileModel.profile),
                        buildClubs(context, userProfileModel.profile, authModel),
                        Center(child: Column(children: [buildHomePageButton(authModel), buildLogoutButton(authModel)])),
                      ],
                    ));
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

  Widget buildHomePageButton(AuthModel authModel) {
    return ElevatedButton(
      onPressed: () {
        _launchHomePage(authModel.username);
      }, //_launchHomePage,
      child: const Text('View on website'),
    );
  }

  Widget buildLogoutButton(AuthModel authModel) {
    return ElevatedButton(
      onPressed: () {
        _showLogoutConfirmation(context, authModel);
      }, //_launchHomePage,
      child: const Text('Logout'),
    );
  }

  Widget buildClubCard2(ClubProfile club, AuthModel authModel) {
    return Card(
        color: baseColourLight3,
        child:
            Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
          ListTile(
            textColor: baseAnalogous1,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            title: Text(club.name),
            //subtitle: Text("a subtitle"),
            subtitleTextStyle: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Row /*or Column*/ (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(width: 10),
              ClipOval(
                child: SizedBox.fromSize(
                  size: const Size.fromRadius(48), // Image radius
                  child: Image.network('https://myclub.run/clubs/${club.slug}/profileImage', fit: BoxFit.cover),
                ),
              ),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
                child: Text(club.description + "dghf ghjfdsg fhjfdg jdfhjdg dfhjg fdshj gfdj"),
              )),
            ],
          ),
          const SizedBox(height: 5),
          _buildClubSelectionState(club, authModel),
          const SizedBox(height: 8),

          // CircleAvatar(
          //     radius: 48, // Image radius
          //     backgroundImage: NetworkImage("https://myclub.run/clubs/${club.slug}/profileImage")
          // )
          //_buildImage(club)
        ]));
  }

  _buildClubSelectionState(ClubProfile club, AuthModel authModel) {
    if (club.slug == authModel.selectedClub) {
      return const Text(
        "This is the selected Club",
        style: TextStyle(fontWeight: FontWeight.bold, color: baseAnalogous1),
      );
    } else {
      return ElevatedButton(
          onPressed: () {
            authModel.selectClub(club.slug);
          },
          child: const Text("Select this Club"));
    }
  }

  _buildImage(ClubProfile club) {
    print("starting an image loader");
    return FutureBuilder(
        future: loadImage("https://myclub.run/clubs/${club.slug}/profileImage", "${club.slug}-profile-image"),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // return Container(
            //   padding: EdgeInsets.all(8), // Border width
            //   decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            //   child: ClipOval(
            //     child: SizedBox.fromSize(
            //       size: Size.fromRadius(48), // Image radius
            //       child: Image.file(File(snapshot.data!), fit: BoxFit.cover),
            //     ),
            //   ),
            // );
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Image.file(File(snapshot.data!), width: 50.0, height: 50.0)],
            );
          }
          return CircularProgressIndicator(
            backgroundColor: Colors.purple,
            strokeWidth: 2,
          );
        });
  }

  // Widget buildClubCard(ClubProfile club) {
  //   return Card(
  //       color: baseColourLight3,
  //       child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: <Widget>[Text("Club card for ${club.name} goes here")]));
  // }

  // Column(
  // crossAxisAlignment: CrossAxisAlignment.stretch,

  Widget buildClubs(BuildContext context, UserProfile profile, AuthModel authModel) {
    List<Widget> result = List.empty(growable: true);
    //result.add(Text("There are ${profile.clubs.length} clubs"));

    for (var club in profile.clubs) {
      result.add(buildClubCard2(club, authModel));
    }

    return Column(
      children: result,
    );
  }

  _header(UserProfile profile) {
    return Column(
      children: [
        Row(children: [
          const SizedBox(width: 10),
          ClipOval(
            child: SizedBox.fromSize(
              size: const Size.fromRadius(24), // Image radius
              child: Image.network('https://myclub.run/users/profileImage/alice', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(
            "Hello ${profile.name}",
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: baseAnalogous1),
          ))
        ]),
        const SizedBox(height: 5),
        const Text("This is your home page."),
      ],
    );
  }
}

void _showLogoutConfirmation(BuildContext context, AuthModel authModel) {
  // set up the buttons
  Widget cancelButton = TextButton(
      style: TextButton.styleFrom(
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      });

  Widget logoutButton = TextButton(
      style: TextButton.styleFrom(
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: const Text('Logout'),
      onPressed: () {
        Navigator.of(context).pop();
        _doLogout(context, authModel);
      });

  AlertDialog alert = AlertDialog(
    title: const Text("Logout"),
    content: Text("${authModel.username}, would you like to logout?"),
    actions: [cancelButton, logoutButton],
  );
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
  var delay = Future<int>.delayed(const Duration(seconds: simulatedDelay), () => 0);
  final response = await delay.then((value) =>
      http.get(Uri.parse('https://myclub.run/api/${authModel.username}/profile'), headers: {"JWT": authModel.token}));

  if (response.statusCode == 200) {
    var profile = UserProfile.fromJson(jsonDecode(response.body));
    userProfileModel.initialLoad(profile);
    return true;
  }
  return false;
}

Future<String> downloadImage(String url) {
  return ImageDownloader.downloadImage(url).then((value) => value != null ? value : "missing");
}
