import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'const.dart';
import 'models.dart';
import 'main.dart';
import 'home.dart';
import 'duties.dart';

class AppPageRoute extends StatefulWidget {
  const AppPageRoute({super.key});

  @override
  State<AppPageRoute> createState() => _AppPageRouteState();
}

class _AppPageRouteState extends State<AppPageRoute> with TickerProviderStateMixin {
  late TabController _myController;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
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
              HomePage(),
              buildDutiesPage(context),
              Text("tab 3"),
            ])));
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
