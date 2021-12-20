import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../core/core.dart';
import '../../core/models/actions_model.dart';
import '../../core/models/location.dart';

class HomeVm extends ChangeNotifier {
  late List<PageActions> actionsOnPage;
  LoadingProcess status = LoadingProcess.done;
  late FirebaseFirestore fS;
  List<Location> locations = [];
  Location? _selected;

  Location get selected => _selected ?? locations[0];

  final Completer<GoogleMapController> controller = Completer();
  final PanelController panelController = PanelController();

  HomeVm() {
    actionsOnPage = <PageActions>[];

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        status = LoadingProcess.loading;
        notifyListeners();
        fS = FirebaseFirestore.instance;
        await getAllActions();

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
    var _dataonFireLocation = await fS.collection('locations').get();
    actionsOnPage.clear();
    locations.clear();

    for (var element in _dataOnFire.docs) {
      actionsOnPage.add(PageActions.fromMap(element.data()));
    }

    for (var item in _dataonFireLocation.docs) {
      locations.add(Location.fromJson(item.data()));
    }
    _selected = locations[0];

    actionsOnPage.sort((a, b) => a.id.compareTo(b.id));
  }

  Future<void> selectLocation(Location location) async {
    (await controller.future)
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            //bearing: 192.8334901395799,
            target: LatLng(location.longtidue, location.latidute),
            tilt: 59.440717697143555,
            zoom: 18)));
    _selected = location;
    if (panelController.panelPosition > 0.5) togglePanel();

    notifyListeners();
  }

  togglePanel() {
    if (panelController.panelPosition < 0.5) {
      panelController.open();
    } else {
      panelController.close();
    }
  }
}
