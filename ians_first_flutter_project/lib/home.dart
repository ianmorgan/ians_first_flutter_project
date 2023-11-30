import 'package:flutter/material.dart';
import 'package:ians_first_flutter_project/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_downloader/image_downloader.dart';

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
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(builder: (context, appStateModel, child) {
      return Consumer<UserProfileModel>(builder: (context, userProfileModel, child) {
        return FutureBuilder<bool>(
            future: fetchUserProfile(appStateModel, userProfileModel),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                    margin: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        _header(userProfileModel.profile, appStateModel),
                        _showSelectClubMessage(appStateModel),
                        _buildUpcomingDuties(userProfileModel, appStateModel),
                        _buildClubs(context, userProfileModel, appStateModel),
                        Center(
                            child: Column(
                                children: [buildHomePageButton(appStateModel), buildLogoutButton(appStateModel)])),
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

  Widget buildHomePageButton(AppStateModel appStateModel) {
    return ElevatedButton(
      onPressed: () {
        _launchHomePage(appStateModel.username);
      }, //_launchHomePage,
      child: const Text('View on website'),
    );
  }

  Widget buildLogoutButton(AppStateModel appStateModel) {
    return ElevatedButton(
      onPressed: () {
        _showLogoutConfirmation(context, appStateModel);
      }, //_launchHomePage,
      child: const Text('Logout'),
    );
  }

  Widget buildClubCard2(ClubProfile club, UserProfileModel userProfileModel, AppStateModel appStateModel) {
    return Card(
        color: baseColourLight3,
        child:
            Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
          ListTile(
            textColor: baseAnalogous1,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            title: Text(club.name),
            //subtitle: Text("a subtitle"),
            subtitleTextStyle: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Row /*or Column*/ (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(width: 10),
              buildClubImage(club.slug, 48),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
                child: Text(club.description),
              )),
            ],
          ),
          const SizedBox(height: 5),
          _buildClubSelectionState(club, userProfileModel, appStateModel),
          const SizedBox(height: 8),

          // CircleAvatar(
          //     radius: 48, // Image radius
          //     backgroundImage: NetworkImage("https://myclub.run/clubs/${club.slug}/profileImage")
          // )
          //_buildImage(club)
        ]));
  }

  _buildClubSelectionState(ClubProfile club, UserProfileModel userProfileModel, AppStateModel appStateModel) {
    if (club.slug == appStateModel.selectedClub) {
      return const Text(
        "This is the selected Club",
        style: TextStyle(fontWeight: FontWeight.w500, color: baseAnalogous1),
      );
    } else {
      return ElevatedButton(
          onPressed: () {
            appStateModel.selectClub(club.slug);
            //fetchUserProfile(appStateModel, userProfileModel);
          },
          child: const Text("Select this Club"));
    }
  }

  _showSelectClubMessage(AppStateModel appState) {
    if (appState.selectedClub == "") {
      return Row(children: [Text("You need to select a club")]);
    } else {
      return const SizedBox();
    }
  }

  _buildUpcomingDuties(UserProfileModel userProfile, AppStateModel appState) {
    const heading = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: baseAnalogous1);
    const headingLight = TextStyle(fontSize: 16, fontWeight: FontWeight.w200, color: baseAnalogous1);

    List<Widget> result = List.empty(growable: true);
    result.add(const SizedBox(height: 10));
    result.add(const Text("Upcoming Duties", style: heading2));
    result.add(const SizedBox(height: 10));
    if (userProfile.upcomingDuties.isEmpty) {
      result.add(const Text("You don't have any duties. You can find and volunteer using the Duties tab."));
      result.add(const SizedBox(height: 5));
    } else {
      result.add(Text(
          "You have ${userProfile.upcomingDuties.length} duties. Thanks for helping. You can find and volunteer for more using the Duties tab."));

      result.add(const SizedBox(height: 10));

      List<TableRow> tableRows = List.empty(growable: true);
      for (var duty in userProfile.upcomingDuties) {
        var richText = RichText(
            text: TextSpan(children: [
              TextSpan(text: "${duty.name} ", style: heading),
              TextSpan(text: "${duty.distanceInTime}\n(${duty.date})", style: headingLight),
            ]));
        var button = TextButton(child: const Text('View'), onPressed: () {
          _launchPage(duty.eventUrl);
        });
        var row = TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle, child: richText),
          const Text(""),
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.top, child: Wrap(children: [button]))
        ]);
        tableRows.add(row);
      }

      var table = Table(columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(80),
      }, children: tableRows);

      result.add(table);

      // for (var duty in userProfile.upcomingDuties) {
      //   var richText = RichText(
      //       text: TextSpan(children: [
      //     TextSpan(text: "${duty.name} ", style: heading),
      //     TextSpan(text: "${duty.distanceInTime} (${duty.date})", style: headingLight),
      //     //T//extSpan(text: userProfile)
      //   ]));
      //   result.add(richText);
      //   result.add(const SizedBox(height: 5));
      // }

      //result.add(card);
      result.add(const SizedBox(height: 5));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: result,
    );
  }

  _buildClubs(BuildContext context, UserProfileModel profile, AppStateModel appStateModel) {
    List<Widget> result = List.empty(growable: true);
    //result.add(Text("There are ${profile.clubs.length} clubs"));

    result.add(const SizedBox(height: 10));
    result.add(const Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Your Clubs",
          style: heading2,
        ),
        SizedBox(height: 5),
        Text("You are a member of the following clubs.")
      ])
    ]));
    for (var club in profile.profile.clubs) {
      result.add(buildClubCard2(club, profile, appStateModel));
    }

    return Column(
      children: result,
    );
  }

  _header(UserProfile userProfile, AppStateModel appStateModel) {
    return Column(
      children: [
        Row(children: [
          const SizedBox(width: 10),
          buildUserImage(appStateModel.username, 24),
          const SizedBox(width: 10),
          Expanded(
              child: RichText(
            text: TextSpan(children: [
              const TextSpan(text: "hello ", style: heading1Light),
              TextSpan(text: userProfile.name, style: heading1),
              //T//extSpan(text: userProfile)
            ]),
          ))
        ]),
        const SizedBox(height: 5),
        //const Text("This is your home page."),
      ],
    );
  }
}

void _showLogoutConfirmation(BuildContext context, AppStateModel appStateModel) {
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
        _doLogout(context, appStateModel);
      });

  AlertDialog alert = AlertDialog(
    title: const Text("Logout"),
    content: Text("${appStateModel.username}, would you like to logout?"),
    actions: [cancelButton, logoutButton],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void _doLogout(BuildContext context, AppStateModel appStateModel) {
  appStateModel.logout();
  Navigator.of(context, rootNavigator: false).pushReplacement(MaterialPageRoute(
    builder: (context) => const LoginPage(),
  ));
}

Future<void> _launchHomePage(String username) async {
  if (!await launchUrl(Uri.parse('https://myclub.run/$username'), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch home page');
  }
}

Future<void> _launchPage(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch home page');
  }
}

Future<bool> fetchUserProfile(AppStateModel appStateModel, UserProfileModel userProfileModel) async {
  var delay = Future<int>.delayed(const Duration(seconds: simulatedDelay), () => 0);
  // todo - run these requests in parallel
  final profileResponse = await delay.then((value) => http.get(
      Uri.parse('https://myclub.run/api/${appStateModel.username}/profile'),
      headers: {"JWT": appStateModel.token}));

  if (profileResponse.statusCode == 200) {
    final upcomingResponse = await delay.then((value) => http.get(
        Uri.parse('https://myclub.run/api/${appStateModel.username}/duties/upcoming'),
        headers: {"JWT": appStateModel.token}));

    if (upcomingResponse.statusCode == 200) {
      List<UpcomingDuty> deserialisedDuties = List.empty(growable: true);
      for (var item in jsonDecode(upcomingResponse.body) as Iterable) {
        deserialisedDuties.add(UpcomingDuty.fromJson(item));
      }

      var profile = UserProfile.fromJson(jsonDecode(profileResponse.body));
      userProfileModel.initialLoad(profile, deserialisedDuties);
      return true;
    }
  }
  return false;
}

Future<String> downloadImage(String url) {
  return ImageDownloader.downloadImage(url).then((value) => value != null ? value : "missing");
}
