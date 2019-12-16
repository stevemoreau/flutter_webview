# flutter_webview

This application is a demonstration example for flutter issue:
https://github.com/flutter/flutter/issues/47139

- create project
```
$ flutter create .
```
- edit ios/Runner/Info.plist
```
  <key>io.flutter.embedded_views_preview</key>
  <true/>
```
- open ios/Runner.xcworkspace and set your provisioning profile
- build and run project on a real iOS 13.x iPhone