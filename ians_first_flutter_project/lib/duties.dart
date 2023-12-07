import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ians_first_flutter_project/widgets.dart';
import 'package:provider/provider.dart';
import 'const.dart';
import 'models.dart';
import 'volunteer.dart';

Widget buildDutiesPage(BuildContext buildContext) {
  return Consumer<AppStateModel>(builder: (context, appStateModel, child) {
    return Consumer<DutiesModel>(builder: (context, dutiesModel, child) {
      return Consumer<UserProfileModel>(builder: (context, userProfileModel, child) {
        return FutureBuilder<int>(
            future: fetchDuties(appStateModel, dutiesModel),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return RefreshIndicator(
                    onRefresh: () async {
                      // Handle the refresh action here (e.g., fetch new data)
                      // You can call an API, update data, or perform any necessary tasks
                      // Remember to use asynchronous functions when performing async operations

                      // Example of a delay to simulate an asynchronous operation
                      await fetchDuties(appStateModel, dutiesModel);
                      dutiesModel.notifyAll();
                    },
                    child: ListView(children: [
                      Column(children: _createEventsList(appStateModel, dutiesModel, userProfileModel.profile))
                    ]));
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
  });
}

class CalendarEntryCard extends StatelessWidget {
  const CalendarEntryCard({super.key, required this.appStateModel, required this.entryId});

  final String entryId;
  final AppStateModel appStateModel;

  List<Widget> _createButton(BuildContext context, DutiesModel model, String entryId, String dutyId) {
    List<Widget> widgets = List.empty(growable: true);
    var duty = model.dutyById(dutyId);
    switch (duty.status) {
      case DutyStatus.Unassigned:
        widgets.add(TextButton(
            child: const Text('Volunteer'),
            onPressed: () => {
                  volunteerDialogBuilder(context, appStateModel, entryId, dutyId, model),
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

  List<Widget> _createDutiesList(BuildContext context, DutiesModel model, AppStateModel appStateModel) {
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
              child: Wrap(children: _createDutyInfo(context, duty, appStateModel.username))),
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
    return Consumer<DutiesModel>(builder: (context, dutiesModel, child) {
      return Center(
        child: Card(
          color: baseColourLight2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ListTile(
                textColor: baseAnalogous1,
                leading: const Icon(Icons.calendar_month, color: baseAnalogous1),
                titleTextStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                title: Text(dutiesModel.entryById(entryId).name),
                subtitle: Text(dutiesModel.entryById(entryId).dateTime),
                subtitleTextStyle: const TextStyle(fontSize: 16),
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _createDutiesList(context, dutiesModel, appStateModel))),
            ],
          ),
        ),
      );
    });
  }
}

Future<int> fetchDuties(AppStateModel appStateModel, DutiesModel model) async {
  print("**** fetchDuties for ${appStateModel.username} ****");
  List<CalendarEntry> result = List.empty(growable: true);

  if (appStateModel.hasSelectedClub()) {
    final response = await http.get(Uri.parse('$apiLocation/api/clubs/${appStateModel.selectedClub}/duties'),
        headers: {"JWT": appStateModel.token});

    if (response.statusCode == 200) {
      Iterable jsonList = jsonDecode(response.body);

      for (var element in jsonList) {
        result.add(CalendarEntry.fromJson(element));
      }
      model.initialLoad(result);

      // don' really need anything here, as all we need is in the model which is AppState
      return result.length;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load the duties ${response.body} (${response.statusCode})');
    }
  }
  else {
    return -1; // Timer(const Duration(seconds: simulatedDelay), () {
  }
}

// curl  https://myclub.run/api/clubs/hampton/duties | jq

List<Widget> _createEventsList(AppStateModel appStateModel, DutiesModel model, UserProfile userProfile) {
  List<Widget> result = List.empty(growable: true);

  if (!appStateModel.hasSelectedClub()) {
    result.add(buildAlertMessage("There is no club selected. Switch to the Home tab and choose a club"));
  } else {
    //result.add(Text("loaded ${model.entries.length} entries"));

    result.add(buildClubPanel(userProfile.lookupClub(appStateModel.selectedClub)));

    for (var entry in model.entries) {
      result.add(CalendarEntryCard(
        key: UniqueKey(),
        appStateModel: appStateModel,
        entryId: entry.id,
      ));
    }
  }
  return result;
}
