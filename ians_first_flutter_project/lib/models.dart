// should match Kotlin equivalent in back end
import 'dart:collection';

import 'package:flutter/foundation.dart';

enum DutyStatus { Unassigned, Assigned, Completed, Cancelled }

class AuthModel extends ChangeNotifier {
  bool isLoggedIn = false;
  bool isReturningUser = false;
  String username = "";
  String authToken = "???";
  String token = "???";
  bool isCallingApi = false;
  String attemptedUsername = "";
  String attemptedPassword = "";

  void completeLogin(String token) {
    isLoggedIn = true;
    isReturningUser = true;
    isCallingApi = false;
    username = attemptedUsername;
    attemptedUsername = "";
    attemptedPassword = "";
    this.token = token;
    notifyListeners();
  }

  void startLogin(String username, String password) {
    isCallingApi = true;
    attemptedUsername = username;
    attemptedPassword = password;
    authToken = "";
    token = "";
    notifyListeners();
  }

  void cancelLogin() {
    isCallingApi = false;
    attemptedPassword = "";
    notifyListeners();
  }

  void logout() {
    if (isLoggedIn) {
      //isCallingApi = false;
      isLoggedIn = false;
      //attemptedPassword = "";
      notifyListeners();
    }
  }

  String displayableUserName() {
    if (isLoggedIn) return username;
    return attemptedUsername;
  }

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

    for (var item in json['duties'] as Iterable) {
      deserialisedDuties.add(Duty.fromJson(item));
    }

    return CalendarEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        dateTime: json['dateTime'] as String,
        duties: deserialisedDuties);
  }
}

class DutiesModel extends ChangeNotifier {
  List<CalendarEntry> _entries = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<CalendarEntry> get entries => UnmodifiableListView(_entries);

  void initialLoad(List<CalendarEntry> entries) {
    // note, no notifications here as it all called in part of the initState
    _entries = entries;
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
    throw ("No Duty with id: '$id' ");
  }

  CalendarEntry entryForDutyId(String dutyId) {
    for (var entry in _entries) {
      var index = entry.duties.indexWhere((element) => element.id == dutyId);
      if (index != -1) {
        return entry;
      }
    }
    throw ("No CalendarEntry with a Duty of id: '$dutyId' ");
  }

  void notifyAll() {
    notifyListeners();
  }
}
