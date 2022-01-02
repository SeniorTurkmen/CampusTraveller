import 'dart:io';

import 'package:campus_traveller/core/core.dart';
import 'package:campus_traveller/core/models/anounce_model.dart';
import 'package:campus_traveller/pages/web_view/web_view_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnounceDetailPage extends StatelessWidget {
  final AnounceModel anounceModel;
  const AnounceDetailPage({Key? key, required this.anounceModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(anounceModel.title),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text("İlan Detayına Git"),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => WebViewPages(
                      title: anounceModel.title,
                      url: anounceModel.anounceLink))),
        ),
        body: Column(
          children: [
            _imageSection(context),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(anounceModel.detail),
                ),
              ),
            ),
          ],
        ));
    ;
  }

  Card _imageSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: Colors.grey[400],
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .3,
        width: double.infinity,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Hero(
              tag: anounceModel,
              child: Image.network(
                anounceModel.image!,
                fit: BoxFit.fitWidth,
              ),
            )),
      ),
    );
  }
}
