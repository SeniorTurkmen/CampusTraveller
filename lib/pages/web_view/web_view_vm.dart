import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/core.dart';

class WebViewVm extends ChangeNotifier {
  WebViewVm() {
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
  }
  LoadingProcess status = LoadingProcess.done;
  int progresPercent = 0;

  void setComplete() {
    status = LoadingProcess.done;
    notifyListeners();
  }

  setLoading() {
    status = LoadingProcess.loading;
    notifyListeners();
  }

  setError() {
    status = LoadingProcess.error;
    notifyListeners();
  }

  setPercent(int val) {
    progresPercent = val;
    notifyListeners();
  }
}
