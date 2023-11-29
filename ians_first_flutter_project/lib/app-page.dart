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
    const TextStyle headerStyle = TextStyle(color: baseColourLight3, fontSize: 30, fontWeight: FontWeight.w400);
    const TextStyle headerStyleLight = TextStyle(color: baseColourLight3, fontSize: 30, fontWeight: FontWeight.w100);
    Widget title = const Row(
      children: [
        Text("MyClub ", style: headerStyle),
        Text("dot ", style: headerStyleLight),
        Text("Run ", style: headerStyle)
      ],
    );
    return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: baseColour,
              title: title,
              bottom: TabBar(
                labelColor: Colors.white, //<-- selected text color
                unselectedLabelColor: baseColourLight1, //
                tabs: [
                  const Tab(icon: Icon(Icons.home), text: 'Home'),
                  const Tab(icon: Icon(Icons.task), text: 'Duties'),
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
