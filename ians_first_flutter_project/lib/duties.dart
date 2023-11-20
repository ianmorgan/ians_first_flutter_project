import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'const.dart';
import 'types.dart';
import 'volunteer.dart';

class DutiesPageRoute extends StatelessWidget {
  const DutiesPageRoute({super.key, required this.login});

  final LoginState login;

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarModel>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home Page'),
          ),
          body: ListView(children: [
            DutyPage(title: "foo", login: login),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            )
          ]),
        );
      },
    );
  }
}

class DutyPage extends StatefulWidget {
  const DutyPage({super.key, required this.login, required this.title});

  final String title;
  final LoginState login;

  @override
  State<DutyPage> createState() => _DutyPageState(login: login);
}

class _DutyPageState extends State<DutyPage> {
  _DutyPageState({required this.login});

  final LoginState login;
  late Future<List<CalendarEntry>> futureEntries;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CalendarEntry>>(
        future: futureEntries,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(children: _createEventsList(login, snapshot.data!));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          // By default, show a loading spinner.
          return const Text("loading...");
        });
  }

  @override
  void initState() {
    super.initState();
    futureEntries = fetchDuties(login);
  }
}

class CalendarEntryCard extends StatelessWidget {
  const CalendarEntryCard({super.key, required this.login, required this.entry});

  final CalendarEntry entry;
  final LoginState login;

  List<Widget> _createButton(BuildContext context, CalendarEntry entry, Duty duty) {
    List<Widget> widgets = List.empty(growable: true);
    switch (duty.status) {
      case DutyStatus.Unassigned:
        widgets.add(TextButton(
            child: const Text('Volunteer'),
            onPressed: () => {
                  volunteerDialogBuilder(context, login, entry, duty),
                }));
      case DutyStatus.Assigned:
        widgets.add(TextButton(child: const Text('Swap'), onPressed: () {}));
      case DutyStatus.Completed:
        widgets.add(TextButton(child: const Text('Completed'), onPressed: () {}));
      default:
        widgets.add(TextButton(child: const Text(''), onPressed: () {}));
    }
    return widgets;
  }

  List<Widget> _createDutyInfo(BuildContext context, Duty duty, String currentUser) {
    List<Widget> widgets = List.empty(growable: true);
    widgets.add(Text(duty.name));
    if (duty.assignedUserName != "???") {
      widgets.add(const Text("  "));
      if (duty.assignedUserName != currentUser) {
        widgets.add(
          Container(
            height: 20,
            color: Colors.grey.shade700,
            child: Text(
              " ${duty.assignedUserName} ",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        widgets.add(
          Container(
            height: 20,
            color: baseColour,
            child: const Text(
              " Me ",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }

    //ElevatedButton(child: Text("aa"), onPressed: () {});
    return widgets;
  }

  List<Widget> _createDutiesList(BuildContext context, LoginState login) {
    List<Widget> widgets = List.filled(entry.duties.length, const Text(""), growable: false);
    int i = 0;
    for (var duty in entry.duties) {
      widgets[i] = Table(columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(100),
      }, children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Wrap(children: _createDutyInfo(context, duty, login.username))),
          Text(""),
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.top,
              child: Wrap(children: _createButton(context, entry, duty)))
        ])
      ]);
      i++;
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: baseColourLight3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ListTile(
              textColor: baseAnalogous1,
              leading: Icon(Icons.calendar_month),
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              title: Text(entry.name),
              subtitle: Text(entry.dateTime),
              subtitleTextStyle: TextStyle(fontSize: 16),
            ),
            Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: _createDutiesList(context, login))),
          ],
        ),
      ),
    );
  }
}

Future<List<CalendarEntry>> fetchDuties(LoginState login) async {
  List<CalendarEntry> result = List.empty(growable: true);

  final response = await http.get(Uri.parse('https://myclub.run/api/clubs/hampton/duties'));

  if (response.statusCode == 200) {
    Iterable jsonList = jsonDecode(response.body);

    for (var element in jsonList) {
      result.add(CalendarEntry.fromJson(element));
    }
    //jsonList.forEach((e) => result.add(CalendarEntry.fromJson(e)));

    // If the server did return a 200 OK response,
    // then parse the JSON.
    return result;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
// curl  https://myclub.run/api/clubs/hampton/duties | jq

List<Widget> _createEventsList(LoginState login, List<CalendarEntry> data) {
  List<Widget> result = List.empty(growable: true);
  result.add(Text("loaded ${data.length} entries"));

  for (var entry in data) {
    result.add(CalendarEntryCard(key: UniqueKey(), login: login, entry: entry));
  }
  return result;
}
