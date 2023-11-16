// should match Kotlin equivalent in back end
enum DutyStatus { Unassigned, Assigned, Completed, Cancelled }

class Duty {
  final String name;
  final DutyStatus status;

  Duty({required this.name, required this.status});

  factory Duty.fromJson(Map<String, dynamic> json) {
    var status = json['status'] as String;
    var statusEnum = DutyStatus.values.firstWhere((element) => element.name == status);
    return Duty(name: json['name'] as String, status: statusEnum);
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
    (json['duties'] as Iterable).forEach((e) => {deserialisedDuties.add(Duty.fromJson(e))});

    // xxx
    return CalendarEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        dateTime: json['dateTime'] as String,
        duties: deserialisedDuties);
  }
}

/*
"name": "General Sailing B",
    "id": "d250e277-185a-4bfd-aeea-dcfef5080200",
    "dateTime": "Jan 10, 2024, 11:00 AM",
    "hasDuties": true,
    "duties": [
      {
        "name": "Safety Boat Helm",
        "status": "Unassigned"
      },
      {
        "name": "Safety Boat Crew",
        "status": "Unassigned"
      },
      {
        "name": "Officer of the Day",
        "status": "Unassigned"
      }

 */
