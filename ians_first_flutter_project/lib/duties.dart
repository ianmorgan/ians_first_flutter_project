import 'package:flutter/material.dart';
import 'const.dart';

enum DutyState { filled, available, completed, cancelled }

class Duty {
  final String name;
  final DutyState state;

  Duty(this.name, this.state);
}

class DutiesPageRoute extends StatelessWidget {
  const DutiesPageRoute({super.key});

  List<Widget> createEventsList() {
    List<Duty> duties1 = List.filled(3, Duty("Race Officer", DutyState.filled), growable: true);
    List<Duty> duties2 = List.filled(5, Duty("ARO", DutyState.available), growable: true);

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

class CardExample extends StatelessWidget {
  const CardExample({super.key, required this.eventTitle, required this.eventDate, required this.duties});

  final String eventTitle;
  final String eventDate;
  final List<Duty> duties;

  Widget _createButton(DutyState state) {
    switch (state) {
      case DutyState.available:
        return TextButton(child: const Text('Volunteer'), onPressed: () {});
      case DutyState.filled:
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
        Text(" [${duty.state.name}] ", style: const TextStyle(color: Colors.grey)),
        const Expanded(child: Text("")),
        _createButton(duty.state)
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
