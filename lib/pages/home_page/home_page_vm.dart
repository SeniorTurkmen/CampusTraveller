import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../core/core.dart';
import '../../core/models/actions_model.dart';

class HomeVm extends ChangeNotifier {
  late List<PageActions> actionsOnPage;
  LoadingProcess status = LoadingProcess.done;
  late FirebaseFirestore fS;

  HomeVm() {
    actionsOnPage = <PageActions>[];

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        status = LoadingProcess.loading;
        notifyListeners();
        fS = FirebaseFirestore.instance;
        getAllActions();

        status = LoadingProcess.done;
        notifyListeners();
      } catch (e) {
        status = LoadingProcess.error;
        notifyListeners();
      }
    });
  }

  Future<void> getAllActions() async {
    var _dataOnFire = await fS.collection('actions').get();

    for (var element in _dataOnFire.docs) {
      actionsOnPage.add(PageActions.fromMap(element.data()));
      log(element.data().toString());
    }

    actionsOnPage.sort((a, b) => a.id.compareTo(b.id));
  }
}
