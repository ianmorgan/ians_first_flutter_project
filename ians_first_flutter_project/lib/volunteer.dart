import 'package:flutter/material.dart';
import 'package:ians_first_flutter_project/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Flutter code sample for [showDialog].

Future<void> volunteerDialogBuilder(
    BuildContext context, LoginState login, CalendarEntry calendarEntry, Duty duty, CalendarModel model) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Volunteer for ${duty.name}'),
        content: Text('You are volunteering for "${duty.name}" duty at ${calendarEntry.name} '
            'on ${calendarEntry.dateTime}\n\n'
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
  final response = await http.post(Uri.parse(
      'https://myclub.run/api/clubs/hampton/duties/duty/${duty.id}/doVolunteer?username=${login.username}&doubleSubmitToken=123456'));
  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 200){
    model.load(List.empty());
  }
  return (response.statusCode == 200, response.body);
}
