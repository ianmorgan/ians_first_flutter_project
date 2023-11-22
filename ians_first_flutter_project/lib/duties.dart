import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'const.dart';
import 'models.dart';
import 'volunteer.dart';

class DutiesPageRoute extends StatelessWidget {
  const DutiesPageRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarModel>(
      builder: (context, duties, child) {
        return Scaffold(
          appBar: AppBar(
            title: Consumer<AuthModel>(builder: (context, authModel, child) {
              return Text('Duties Page ${authModel.username}');
            }),
          ),
          body: ListView(children: [
            DutyPage(title: "foo", model: duties),
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
  const DutyPage({super.key, required this.title, required this.model});

  final String title;
  final CalendarModel model;

  @override
  State<DutyPage> createState() => _DutyPageState(model: model);
}

class _DutyPageState extends State<DutyPage> {
  _DutyPageState({required this.model});

  final CalendarModel model;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(builder: (context, authModel, child) {
      return FutureBuilder<int>(
          future: fetchDuties(authModel, model),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(children: _createEventsList(authModel, model));
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return const Text("loading...");
          });
    });
  }

  @override
  void initState() {
    super.initState();
  }
}

class CalendarEntryCard extends StatelessWidget {
  const CalendarEntryCard({super.key, required this.authModel, required this.entryId});

  final String entryId;
  final AuthModel authModel;

  List<Widget> _createButton(BuildContext context, CalendarModel model, String entryId, String dutyId) {
    List<Widget> widgets = List.empty(growable: true);
    var duty = model.dutyById(dutyId);
    switch (duty.status) {
      case DutyStatus.Unassigned:
        widgets.add(TextButton(
            child: const Text('Volunteer'),
            onPressed: () => {
                  volunteerDialogBuilder(context, authModel, entryId, dutyId, model),
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

    return widgets;
  }

  List<Widget> _createDutiesList(BuildContext context, CalendarModel model, AuthModel authModel) {
    List<Widget> widgets = List.filled(model.entryById(entryId).duties.length, const Text(""), growable: false);
    int i = 0;
    for (var duty in model.entryById(entryId).duties) {
      widgets[i] = Table(columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(100),
      }, children: [
        TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Wrap(children: _createDutyInfo(context, duty, authModel.username))),
          const Text(""),
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.top,
              child: Wrap(children: _createButton(context, model, entryId, duty.id)))
        ])
      ]);
      i++;
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarModel>(builder: (context, model, child) {
      return Center(
        child: Card(
          color: baseColourLight3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ListTile(
                textColor: baseAnalogous1,
                leading: const Icon(Icons.calendar_month),
                titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                title: Text(model.entryById(entryId).name),
                subtitle: Text(model.entryById(entryId).dateTime),
                subtitleTextStyle: const TextStyle(fontSize: 16),
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _createDutiesList(context, model, authModel))),
            ],
          ),
        ),
      );
    });
  }
}

Future<int> fetchDuties(AuthModel authModel, CalendarModel model) async {
  List<CalendarEntry> result = List.empty(growable: true);

  final response =
      await http.get(Uri.parse('https://myclub.run/api/clubs/hampton/duties'), headers: {"JWT": authModel.token});

  if (response.statusCode == 200) {
    Iterable jsonList = jsonDecode(response.body);

    for (var element in jsonList) {
      result.add(CalendarEntry.fromJson(element));
    }
    model.load(result);

    // don' really need anything here, as all we need is in the model which is AppState
    return result.length;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load the duties ${response.body} (${response.statusCode})');
  }
}

// curl  https://myclub.run/api/clubs/hampton/duties | jq

List<Widget> _createEventsList(AuthModel authModel, CalendarModel model) {
  List<Widget> result = List.empty(growable: true);
  result.add(Text("loaded ${model.entries.length} entries"));

  for (var entry in model.entries) {
    result.add(CalendarEntryCard(
      key: UniqueKey(),
      authModel: authModel,
      entryId: entry.id,
    ));
  }
  return result;
}
