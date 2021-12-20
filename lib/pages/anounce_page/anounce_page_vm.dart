import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/core.dart';

class AnouncePageVm extends ChangeNotifier {
  late LoadingProcess status = LoadingProcess.loading;
  late FirebaseFirestore fS;
  AnouncePageVm() {
    fS = FirebaseFirestore.instance;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      checkAnounce();
    });
  }

  void checkAnounce() async {
    var _snapshot = fS.collection('anounces').get().asStream();

    _snapshot.listen((event) {
      for (var item in event.docs.toList()) {
        log(item.data().toString());
      }
    });
  }
}
