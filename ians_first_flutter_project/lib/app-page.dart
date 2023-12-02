import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'const.dart';
import 'models.dart';
import 'main.dart';
import 'home.dart';
import 'duties.dart';

class AppPageRoute extends StatefulWidget {
  const AppPageRoute({super.key, required this.persistedState});

  final PersistedState persistedState;

  @override
  State<AppPageRoute> createState() => _AppPageRouteState(persistedState: persistedState);
}

class _AppPageRouteState extends State<AppPageRoute> with TickerProviderStateMixin {
  _AppPageRouteState({required this.persistedState});

  late TabController _myController;
  final PersistedState persistedState;

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
                labelColor: Colors.white,
                unselectedLabelColor: baseColourLight1,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(icon: Icon(Icons.home), text: 'Home'),
                  Tab(icon: Icon(Icons.task), text: 'Duties'),
                  Tab(icon: Icon(Icons.directions_boat), text: 'Sailing'),
                  Tab(icon: Icon(Icons.person), text: 'Settings'),
                ],
                controller: _myController,
              ),
            ),
            body: TabBarView(controller: _myController, children: [
              HomePage(persistedState: persistedState),
              buildDutiesPage(context),
              Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Text("Sailing and racing page goes here"),
                  )),
              Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Text("User Options and setting page goes here"),
                  )),
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
  return Consumer<AppStateModel>(builder: (context, appStateModel, child) {
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
