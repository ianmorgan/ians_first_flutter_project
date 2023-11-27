import 'package:flutter/material.dart';
import 'package:ians_first_flutter_project/duties.dart';
import 'package:provider/provider.dart';

import 'const.dart';
import 'models.dart';

class AppPageRoute extends StatefulWidget {
  const AppPageRoute({super.key});

  @override
  State<AppPageRoute> createState() => _AppPageRouteState();
}

class _AppPageRouteState extends State<AppPageRoute> with TickerProviderStateMixin {
  late TabController _myController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: baseColour,
          //title: Text("a title", textAlign: TextAlign.center),
          bottom: TabBar(
            tabs: [
              const Tab(icon: Icon(Icons.home), text: 'Home'),
              const Tab(icon: Icon(Icons.task), text: 'Tasks'),
              const Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
            controller: _myController,
          ),
        ),
        body: TabBarView(controller: _myController, children: [
          buildHomePage(context),
          buildDutiesPage(context),
          Text("tab 3"),
        ]));
  }

  @override
  void initState() {
    super.initState();
    _myController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _myController.dispose();
  }
}

Widget buildHomePage(BuildContext context) {
  return Consumer<AuthModel>(builder: (context, authModel, child) {
    return Center(
        child: Column(children: [
      Text("Login page was here !!!!"),
      ElevatedButton(
        onPressed: () {}, //_launchHomePage,
        child: Text('Show the homepage'),
      )
    ]));
  });
}
