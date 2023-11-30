// should match Kotlin equivalent in back end
import 'dart:collection';

import 'package:flutter/foundation.dart';

enum DutyStatus { Unassigned, Assigned, Completed, Cancelled }

class AppStateModel extends ChangeNotifier {
  bool isLoggedIn = false;
  bool isReturningUser = false;
  String username = "";
  String authToken = "???";
  String token = "???";
  bool isCallingApi = false;
  String attemptedUsername = "";
  String attemptedPassword = "";
  String selectedClub = "";

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

  void selectClub(String club) {
    selectedClub = club;
    notifyListeners();
  }

  void logout() {
    if (isLoggedIn) {
      //isCallingApi = false;
      isLoggedIn = false;
      selectedClub = "";
      //attemptedPassword = "";
      notifyListeners();
    }
  }

  String displayableUserName() {
    if (isLoggedIn) return username;
    return attemptedUsername;
  }

  bool hasSelectedClub() {
    return selectedClub != "";
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

class UserProfile {
  final String name;
  final String email;
  final List<ClubProfile> clubs;

  UserProfile({required this.name, required this.email, required this.clubs});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    List<ClubProfile> deserialisedClubs = List.empty(growable: true);

    for (var item in json['clubs'] as Iterable) {
      deserialisedClubs.add(ClubProfile.fromJson(item));
    }
    deserialisedClubs.sort((a, b) => a.name.compareTo(b.name));

    return UserProfile(name: json['name'] as String, email: json['email'] as String, clubs: deserialisedClubs);
  }

  ClubProfile lookupClub(String clubSlug) {
    for (var club in clubs) {
      if (club.slug == clubSlug) return club;
    }
    throw Exception("no club with the slug of $clubSlug");
  }
}

class ClubProfile {
  final String name;
  final String slug;
  final String description;

  ClubProfile({required this.name, required this.slug, required this.description});

  factory ClubProfile.fromJson(Map<String, dynamic> json) {
    return ClubProfile(
        name: json['name'] as String, slug: json['slug'] as String, description: json['description'] as String);
  }
}

class UpcomingDuty {
  final String name;
  final String date;
  final String distanceInTime;
  final String eventId;

  UpcomingDuty({required this.eventId, required this.name, required this.date, required this.distanceInTime});

  factory UpcomingDuty.fromJson(Map<String, dynamic> json) {
    return UpcomingDuty(
        eventId: json['eventId'] as String,
        name: json['name'] as String,
        date: json['date'] as String,
        distanceInTime: json['distanceInTime'] as String);
  }
}

class UserProfileModel extends ChangeNotifier {
  late UserProfile profile;

  void initialLoad(UserProfile profile) {
    // note, no notifications here as it all called in part of the initState
    this.profile = profile;
  }
}
