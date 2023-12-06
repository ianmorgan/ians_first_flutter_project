import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  var currentTab = -1;

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
                tabs: [
                  Tab(icon: Icon(Icons.home), text: 'Home'),
                  Tab(icon: _loadIcon(context, "duties.svg"), text: 'Duties'),
                  Tab(icon: _loadIcon(context, "sailing.svg"), text: 'Sailing'),
                  Tab(icon: Icon(Icons.person), text: 'Settings'),
                ],
                onTap: (index) {
                  currentTab = index;
                },
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

  Widget _loadIcon(BuildContext context, String iconName) {
    var index = currentTab;
    //print("index is $index");
    //var color = index == 2? Colors.white : baseColourLight1;
    //var color2 = Theme.of(context).iconTheme.color;
    String assetName = 'assets/icons/$iconName';
    Widget svg = SvgPicture.asset(
      assetName,
      semanticsLabel: iconName,
      color: baseColourLight1,
      //colorFilter: ColorFilter(),
      width: 24.0,
      height: 24.0,
    );
    return svg;
  }

  @override
  void initState() {
    super.initState();
    _myController = TabController(length: 4, vsync: this);
    _myController.addListener(_setActiveTabIndex);
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

  void _setActiveTabIndex() {
    setState(() {
      currentTab = _myController.index;
    });
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
