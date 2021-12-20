import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/core.dart';
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
        child: Consumer<WebViewVm>(
            builder: (_, value, __) => value.status != LoadingProcess.error
                ? Stack(
                    children: [
                      WebView(
                        initialUrl: url,
                        backgroundColor: Colors.black26,
                        javascriptMode: JavascriptMode.unrestricted,
                        onProgress: (val) => log(val.toString()),
                        onPageStarted: (val) => value.setLoading(),
                        onPageFinished: (val) => value.setComplete(),
                        onWebResourceError: (error) => value.setError(),
                      ),
                      if (value.status == LoadingProcess.loading)
                        Container(
                          color: Colors.black26,
                          height: MediaQuery.of(context).size.height,
                          child: const Center(
                            child: SizedBox(
                              height: 35,
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                    ],
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Bir hata oluştu lütfen daha sonra tekrar deneyiniz.',
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new),
                            label: const Text('Geri Gön'))
                      ],
                    ),
                  )),
      ),
    );
  }
}
