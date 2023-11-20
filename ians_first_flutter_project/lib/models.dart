// should match Kotlin equivalent in back end
import 'dart:collection';

import 'package:flutter/foundation.dart';

enum DutyStatus { Unassigned, Assigned, Completed, Cancelled }

class LoginState {
  final bool isLoggedIn;
  final String username;

  LoginState({required this.isLoggedIn, required this.username});
}

class Duty {
  String name;
  DutyStatus status;
  String assignedUserName;
  final String id;

  Duty({required this.id, required this.name, required this.status, required this.assignedUserName});

  factory Duty.fromJson(Map<String, dynamic> json) {
    var status = json['status'] as String;
    var statusEnum = DutyStatus.values.firstWhere((element) => element.name == status);
    return Duty(
        id: json['id'] as String,
        name: json['name'] as String,
        status: statusEnum,
        assignedUserName: json['assignedUserName'] as String);
  }
}

class CalendarEntry {
  final String id;
  final String name;
  final String dateTime;
  final List<Duty> duties;

  CalendarEntry({required this.id, required this.name, required this.dateTime, required this.duties});

  factory CalendarEntry.fromJson(Map<String, dynamic> json) {
    List<Duty> deserialisedDuties = List.empty(growable: true);

    // ignore: avoid_function_literals_in_foreach_calls
    (json['duties'] as Iterable).forEach((e) => deserialisedDuties.add(Duty.fromJson(e)));

    // xxx
    return CalendarEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        dateTime: json['dateTime'] as String,
        duties: deserialisedDuties);
  }
}

class CalendarModel extends ChangeNotifier {
  List<CalendarEntry> _entries = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<CalendarEntry> get entries => UnmodifiableListView(_entries);

  void load(List<CalendarEntry> entries) {
    _entries = entries;
    notifyListeners();
  }

  void assignDuty(String dutyId, String user) {
    for (var entry in _entries) {
      var index = entry.duties.indexWhere((element) => element.id == dutyId);
      if (index != -1) {
        var duty = entry.duties[index];
        duty.status = DutyStatus.Assigned;
        duty.assignedUserName = user;
      }
    }
    notifyListeners();
  }

  CalendarEntry entryById(String id) {
    return entries[entries.indexWhere((element) => element.id == id)];
  }

  Duty dutyById(String id) {
    for (var entry in _entries) {
      var index = entry.duties.indexWhere((element) => element.id == id);
      if (index != -1) {
        var duty = entry.duties[index];
        return duty;
      }
    }
    throw ("No Duty with id: '${id}' ");
  }
}
