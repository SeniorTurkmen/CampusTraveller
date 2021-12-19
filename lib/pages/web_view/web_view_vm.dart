import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewVm extends ChangeNotifier {
  WebViewVm() {
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
  }
}
