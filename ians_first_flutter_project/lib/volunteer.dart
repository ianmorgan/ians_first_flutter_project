import 'package:flutter/material.dart';
import 'package:ians_first_flutter_project/models.dart';
import 'package:http/http.dart' as http;

/// Flutter code sample for [showDialog].

Future<void> volunteerDialogBuilder(
    BuildContext context, LoginState login, String entryId, String dutyId, CalendarModel model) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      var entry = model.entryById(entryId);
      var duty = model.dutyById(dutyId);
      return AlertDialog(
        title: Text('Volunteer for ${duty.name}'),
        content: Text('Hi ${login.username}, you are volunteering for "${duty.name}" duty at ${entry.name} '
            'on ${entry.dateTime}\n\n'
            'Please accept by pressing the "Confirm" button below.\n'),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Confirm'),
            onPressed: () {
              volunteerForDuties(login, duty, model).then((value) {
                print("in callback");
                //print("aa");
                if (value.$1) duty.status = DutyStatus.Assigned;
              });

              //.then((bool, String)) => {});

              //duty.status = DutyStatus.Assigned;

              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<(bool, String)> volunteerForDuties(LoginState login, Duty duty, CalendarModel model) async {
  List<CalendarEntry> result = List.empty(growable: true);
//            "/api/clubs/{club}/duties/duty/{duty}/doVolunteer" bind Method.POST to {
  print("user name is: ${login.username}");
  print("duty is: ${duty.name}");
  print("calendar entry is: ${model.entryForDutyId(duty.id).name}");
  final response = await http.post(Uri.parse(
      'https://myclub.run/api/clubs/hampton/duties/duty/${duty.id}/doVolunteer?username=${login.username}&doubleSubmitToken=123456'));
  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 200){
    model.assignDuty(duty.id, login.username);
  }
  return (response.statusCode == 200, response.body);
}
