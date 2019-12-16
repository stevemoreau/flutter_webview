import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview/screens/HomeScreen.dart';
import 'package:webview/utils/i18n/bloc_provider_new.dart';
import 'package:webview/utils/i18n/multiling_bloc.dart';
import 'package:webview/utils/i18n/multiling_global_translations.dart';

Future main() async {
  //await allTranslations.init();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TranslationsBloc translationsBloc;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  _MyAppState();

  @override
  void initState() {
    super.initState();
    translationsBloc = TranslationsBloc();
  }

  @override
  void dispose() {
    translationsBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget defaultHome = HomeScreen();

    return BlocProvider<TranslationsBloc>(
        bloc: translationsBloc,
        child: StreamBuilder<Locale>(
            stream: translationsBloc.currentLocale,
            initialData: allTranslations.locale,
            builder: (BuildContext context, AsyncSnapshot<Locale> snapshot) {
              return MaterialApp(
                  navigatorObservers: <NavigatorObserver>[],
                  title: allTranslations.text("webview"),
                  theme: ThemeData(fontFamily: 'Regular'),
                  home: defaultHome);
            }));
  }
}
