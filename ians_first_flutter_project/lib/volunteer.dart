import 'package:flutter/material.dart';
import 'package:ians_first_flutter_project/models.dart';
import 'package:http/http.dart' as http;
import 'package:ians_first_flutter_project/widgets.dart';

import 'const.dart';

Future<void> volunteerDialogBuilder(
    BuildContext context, AppStateModel appStateModel, String entryId, String dutyId, DutiesModel model) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      var entry = model.entryById(entryId);
      var duty = model.dutyById(dutyId);
      return AlertDialog(
        title: Text('Volunteer for ${duty.name}'),
        content: Text('Hi ${appStateModel.username}, you are volunteering for "${duty.name}" duty at ${entry.name} '
            'on ${entry.dateTime}\n\n'
            'Please accept by pressing the "Confirm" button below.\n'),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Confirm'),
            onPressed: () {
              volunteerForDuties(appStateModel, duty, model).then((value) {
                //print("aa");
                if (value.$1) {
                  duty.status = DutyStatus.Assigned;
                  SuccessSnackBar("You have volunteered for ${duty.name}. Please check your email for full details.")
                      .show();
                } else {
                  ErrorSnackBar("There was a problem:\n '${value.$2}'").show();
                }
              });

              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

Future<(bool, String)> volunteerForDuties(AppStateModel appStateModel, Duty duty, DutiesModel model) async {
  final response = await http.post(
      Uri.parse(
          '$apiLocation/api/clubs/${appStateModel.selectedClub}/duties/duty/${duty.id}/doVolunteer?username=${appStateModel.username}&doubleSubmitToken=123456'),
      headers: {"JWT": appStateModel.token});

  if (response.statusCode == 200) {
    model.assignDuty(duty.id, appStateModel.username);
  }
  return (response.statusCode == 200, response.body);
}
