import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:webview/values/colors.dart';
import 'package:webview/views/MyWebView.dart';
import 'package:webview/widgets/ColoredTabBar.dart';

const String URL_PREFIX = "https://app-mobile-webview.mobizel.com";
const int TABS_COUNT = 5;
const URL_WITH_LONG_CONTENT = URL_PREFIX + "/webview_flutter/html_with_scroll_position.html";

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RefreshController _refreshController = RefreshController();
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _tabBarKey = GlobalKey();
  var tabs = List<Tab>();
  var webviews = List<Widget>();
  TabController tabController;
  Timer timer;
  double toolbarHeight = 0;
  double drawerHeight = 0;
  AppBar appBar;

  double height = 0.0;
  double appBarMaxHeight = 130.0;
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < TABS_COUNT; i++) {
      tabs.add(Tab(text: "Tab $i"));
    }

    tabController = new TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (height == 0.0) {
      height = screenHeight - appBarMaxHeight;
    }

    print('Building webviews with height $height');
    for (var i = 0; i < TABS_COUNT; i++) {
      webviews.add(MyWebView(
        url: URL_WITH_LONG_CONTENT,
        initialHeight: height,
        preventNavigation: true,
        onChangeTabIndex: (tabIndex) {
          goToTab(tabIndex);
        },
      ));
    }

    appBar = AppBar(
      key: _appBarKey,
      title: Text("Webview scroll middle instead of top", style: TextStyle(
        fontSize: 14,
        color: Colors.black
      )),
      centerTitle: false,
      brightness: Brightness.light,
      actions: <Widget>[],
      backgroundColor: MyColors.white,
      bottom: ColoredTabBar(
        color: MyColors.blue,
        width: screenWidth,
        tabBar: TabBar(
            key: _tabBarKey,
            controller: tabController,
            labelColor: Colors.white,
            labelStyle: TextStyle(fontFamily: 'Bold'),
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            isScrollable: true,
            tabs: tabs.map((tab) => tab).toList()),
      ),
    );

    tabController.addListener(_handleTabSelection);

    return DefaultTabController(
      length: webviews.length,
      child: Scaffold(
        drawerScrimColor: Colors.transparent,
        key: _scaffoldKey,
        appBar: appBar,
        body: IndexedStack(children: webviews, index: tabController.index),
      ),
    );
  }

  void _handleTabSelection() {
    setState(() {});
  }

  goToTab(int index) {
    tabController.animateTo(index);
  }

  refreshCurrentTab() async {
    var webview =
        (webviews[tabController.index].key as GlobalKey<MyWebViewState>)
            .currentState;
    webview.webViewController.reload();
    _refreshController.refreshCompleted();
  }

  showHideOverlay(BuildContext context) async {
    _scaffoldKey.currentState.openDrawer();
    setState(() {});
  }
}
