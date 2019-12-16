import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview/values/colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef TitleLoadedCallback = void Function(String title);
typedef ImageHeaderLoadedCallback = void Function(String urlImage);
typedef URLToShareLoadedCallback = void Function(String urlToShare);

class MyWebView extends StatefulWidget {
  final String url;
  final bool preventNavigation;
  final TitleLoadedCallback onTitleLoaded;
  final ImageHeaderLoadedCallback onImageHeaderLoaded;
  final URLToShareLoadedCallback onURLToShareLoaded;
  final bool needPullToRefresh;
  final double initialHeight;
  static final double topZonePullToRefresh = 50;
  final Function onChangeTabIndex;

  const MyWebView(
      {Key key,
      this.url,
      this.preventNavigation,
      this.onTitleLoaded,
      this.onImageHeaderLoaded,
      this.onURLToShareLoaded,
      this.initialHeight,
      this.needPullToRefresh,
        this.onChangeTabIndex,
      })
      : super(key: key);

  @override
  MyWebViewState createState() => MyWebViewState(height: initialHeight);
}

class MyWebViewState extends State<MyWebView>
    with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController = RefreshController();
  var countNavigate = 0;
  WebViewController webViewController;
  var isLoadingPage = true;
  bool isNetworkAvailable = true;
  DateTime lastUrlChange = DateTime.now();
  var height = 0.0;
  final Map<String, String> _headers = {};

  @override
  bool get wantKeepAlive => true;

  MyWebViewState({this.height});

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  // FIXME smoreau: useless
  @override
  void initState() {
    super.initState();
  }

  void refreshHeight(newHeight) {
    setState(() {
      height = newHeight;
    });
  }

  // FIXME smoreau: "This method overrides a method annotated as @mustCallSuper"
  @override
  Widget build(BuildContext context) {
    WebView webview = WebView(
      // initialUrl: DO NOT SET initialUrl because webView.loadUrl(url); will be called without headers (duplicate call at init)
      javascriptMode: JavascriptMode.unrestricted,
      debuggingEnabled: true,
      onWebViewCreated: (WebViewController webViewController) {
        this.webViewController = webViewController;
        if (!_controller.isCompleted) {
          _controller.complete(webViewController);
        }
        webViewController.loadUrl(widget.url, headers: _headers);
      },
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      ].toSet(),
      navigationDelegate: (NavigationRequest request) {
        return NavigationDecision.navigate;
      },
      onPageFinished: (String url) {
        isLoadingPage = false;
        setState(() {});
      },
    );

    return SmartRefresher(
        header: MaterialClassicHeader(color: MyColors.blue),
        controller: _refreshController,
        enablePullDown: true,
        child: ClipRect(
          child: Container(
            child: widgetWebView(webview)
          ),
        ),
        // 3000
        onLoading: () {
          _refreshController.loadComplete();
        },
        onRefresh: () async {
          forceRefresh();
          _refreshController.refreshCompleted();
        });
  }

  Stack widgetWebView(WebView webview) {
    return Stack(children: [
                Container(
                    height: height,
                    child: Stack(children: [
                      // ClipRect is required
                      // https://github.com/flutter/flutter/issues/41592
                      ClipRect(child: webview),
                      Visibility(
                          visible: isLoadingPage,
                          child: Center(child: CircularProgressIndicator()))
                    ])),
                Container(
                    color: Colors.transparent,
                    height: MyWebView.topZonePullToRefresh)
              ]);
  }

  void forceRefresh({bool openInDedicatedView = false}) {
    isLoadingPage = true;
    webViewController.loadUrl(widget.url, headers: _headers);
  }
}
