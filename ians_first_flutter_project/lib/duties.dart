import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'const.dart';
import 'types.dart';

class DutiesPageRoute extends StatelessWidget {
  const DutiesPageRoute({super.key});

  List<Widget> createEventsList() {
    List<Duty> duties1 = List.filled(3, Duty(name: "Race Officer", status: DutyStatus.Assigned), growable: true);
    List<Duty> duties2 = List.filled(5, Duty(name: "ARO", status: DutyStatus.Unassigned), growable: true);

    List<Widget> widgets = List.empty(growable: true);
    widgets.add(const CardExample(eventTitle: "Race 1", eventDate: "14 November 2023", duties: <Duty>[]));
    widgets.add(CardExample(eventTitle: "Race 2", eventDate: "15 November 2023", duties: duties1));
    widgets.add(CardExample(eventTitle: "Race 3", eventDate: "16 November 2023", duties: duties2));
    widgets.add(CardExample(eventTitle: "Race 4", eventDate: "17 November 2023", duties: duties1));
    widgets.add(CardExample(eventTitle: "Race 5", eventDate: "18 November 2023", duties: duties2));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: ListView(children: [
        DutyPage(title: "foo"),
        Column(children: createEventsList()),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        )
      ]),
    );
  }
}

class DutyPage extends StatefulWidget {
  const DutyPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<DutyPage> createState() => _DutyPageState();
}

class _DutyPageState extends State<DutyPage> {
  late Future<List<CalendarEntry>> futureEntries;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //return Text("DutyPage goes here " + widget.title);
    return FutureBuilder<List<CalendarEntry>>(
        future: futureEntries,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(children: _createEventsList(snapshot.data!));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          //return Text("loadinh");

          // By default, show a loading spinner.
          return const Text("loading...");
        });
  }

  @override
  void initState() {
    super.initState();
    futureEntries = fetchDuties();
  }
}

class CardExample extends StatelessWidget {
  const CardExample({super.key, required this.eventTitle, required this.eventDate, required this.duties});

  final String eventTitle;
  final String eventDate;
  final List<Duty> duties;

  Widget _createButton(DutyStatus state) {
    switch (state) {
      case DutyStatus.Unassigned:
        return TextButton(child: const Text('Volunteer'), onPressed: () {});
      case DutyStatus.Assigned:
        return TextButton(child: const Text('Swap'), onPressed: () {});
      default:
        return TextButton(child: const Text('???'), onPressed: () {});
    }
  }

  List<Widget> _createDutiesList() {
    List<Widget> widgets = List.filled(duties.length, const Text(""), growable: false);
    int i = 0;
    for (var duty in duties) {
      widgets[i] = Row(children: [
        Text(duty.name),
        Text(" [${duty.status.name}] ", style: const TextStyle(color: Colors.grey)),
        const Expanded(child: Text("")),
        _createButton(duty.status)
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
              title: Text(eventTitle),
              subtitle: Text(eventDate),
              subtitleTextStyle: TextStyle(fontSize: 16),
            ),
            Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: _createDutiesList())),
          ],
        ),
      ),
    );
  }
}

Future<List<CalendarEntry>> fetchDuties() async {
  List<CalendarEntry> result = List.empty(growable: true);

  final response = await http.get(Uri.parse('https://myclub.run/api/clubs/hampton/duties'));

  if (response.statusCode == 200) {
    print("processing result!!!");
    Iterable jsonList = jsonDecode(response.body);

    jsonList.forEach((e) => {result.add(CalendarEntry.fromJson(e))});

    print(result.length);

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

List<Widget> _createEventsList(List<CalendarEntry> data) {
  List<Widget> result = List.empty(growable: true);

  result.add( Text("loaded ${data.length} entries"));

  for (var d in data) {
    result.add (CardExample(eventTitle: d.name, eventDate: d.dateTime, duties: d.duties));
  }
  return result;
}
