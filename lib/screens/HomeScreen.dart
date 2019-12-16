import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moneyvox/utils/i18n/multiling_global_translations.dart';
import 'package:moneyvox/values/colors.dart';
import 'package:moneyvox/values/dimens.dart';
import 'package:moneyvox/views/MyWebView.dart';
import 'package:moneyvox/widgets/ColoredTabBar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


const String URL_PREFIX = "http://app-mobile-webview.mobizel.com";

const URLS_CATEGORY = {
  'category_news': URL_PREFIX + "/webview_flutter/long_html_with_scroll_position.html",
  'category_compare': URL_PREFIX + "/webview_flutter/long_html_with_scroll_position.html",
  'category_bank': URL_PREFIX + "/webview_flutter/long_html_with_scroll_position.html",
  'category_credit': URL_PREFIX + "/webview_flutter/long_html_with_scroll_position.html",
  'category_placement': URL_PREFIX + "/webview_flutter/long_html_with_scroll_position.html",
  'category_insurance': URL_PREFIX + "/webview_flutter/long_html_with_scroll_position.html",
  'category_energy': URL_PREFIX + "/webview_flutter/long_html_with_scroll_position.html",
};

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

    tabs = URLS_CATEGORY.entries
        .map((url) => Tab(text: allTranslations.text(url.key).toUpperCase()))
        .toList();

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

    webviews = URLS_CATEGORY.entries
        .map((url) => MyWebView(
              url: url.value,
              initialHeight: max(200, height),
              preventNavigation: true,
              onChangeTabIndex: (tabIndex) {
                goToTab(tabIndex);
              },
            ))
        .toList();

    appBar = AppBar(
      key: _appBarKey,
      leading: IconButton(
        icon:
            SvgPicture.asset('assets/images/ic_menu.svg', color: MyColors.blue),
        onPressed: () {
        },
      ),
      title: SvgPicture.asset(
        'assets/images/logo_moneyvox.svg',
        width: home_logo_width,
        height: home_logo_height,
        fit: BoxFit.cover,
      ),
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
      length: 5,
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
