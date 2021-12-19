import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'web_view_vm.dart';

class WebViewPages extends StatelessWidget {
  final String title;
  final String url;

  const WebViewPages({Key? key, required this.title, required this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ChangeNotifierProvider(
        create: (_) => WebViewVm(),
        child: Consumer(
            builder: (_, value, __) => WebView(
                  initialUrl: url,
                )),
      ),
    );
  }
}
