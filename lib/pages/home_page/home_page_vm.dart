import 'dart:async';
import 'dart:developer';

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
  List<Location> searchedLocations = [];
  Location? _selected;
  String? banner;
  ScrollController? scrollController;
  late final TextEditingController searchController;

  Location? get selected => _selected;

  GoogleMapController? controller;
  final PanelController panelController = PanelController();

  HomeVm() {
    actionsOnPage = <PageActions>[];

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        status = LoadingProcess.loading;
        notifyListeners();
        searchController = TextEditingController();
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

  deSelect() {
    _selected = null;
    controller!.animateCamera(CameraUpdate.newCameraPosition(kHarranOsmanBey));
    togglePanel();
    notifyListeners();
  }

  setGoogleMapController(GoogleMapController _controller) {
    controller = _controller;
    notifyListeners();
  }

  Future<void> getAllActions() async {
    try {
      var _dataOnFire = await fS.collection('actions').get();
      var _dataonFireLocation = await fS.collection('locations').get();
      var _dataonFireBanner = await fS.collection('banner').get();
      actionsOnPage.clear();
      locations.clear();
      banner = _dataonFireBanner.docs.first.data()['link'];
      for (var element in _dataOnFire.docs) {
        actionsOnPage.add(PageActions.fromMap(element.data()));
      }

      for (var item in _dataonFireLocation.docs) {
        locations.add(Location.fromJson(item.data()));
      }
      locations.sort((a, b) => a.name.compareTo(b.name));
      searchedLocations.addAll(locations);
      actionsOnPage.sort((a, b) => a.id.compareTo(b.id));
    } catch (e) {
      log('error: ${e.toString()}');
    }
  }

  Future<void> selectLocation(Location location) async {
    print('${location.toJson()}');
    try {
      if (controller != null) {
        controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            //bearing: 192.8334901395799,
            target: LatLng(location.longtidue, location.latidute),
            tilt: 59.440717697143555,
            zoom: 18)));
        _selected = location;
        if (panelController.panelPosition > 0.5) togglePanel();
      }
    } catch (e) {
      log(e.toString());
    }

    notifyListeners();
  }

  togglePanel() {
    if (panelController.panelPosition < 0.5) {
      panelController.open();
    } else {
      panelController.close();
      scrollController?.animateTo(0,
          duration: Duration(seconds: 1), curve: Curves.linear);
    }
  }

  searchSection(String keyword) {
    if (keyword != '') {
      searchedLocations.clear();
      for (var item in locations) {
        if (item.name.toLowerCase().contains(keyword)) {
          if (!searchedLocations.contains(item)) {
            searchedLocations.add(item);
          }
          ;
        }
      }
    } else {
      searchedLocations.addAll(locations);
    }
    notifyListeners();
  }

  void setScrollController(ScrollController sc) {
    scrollController = sc;
  }

  final CameraPosition kHarranOsmanBey = const CameraPosition(
    target: LatLng(37.1726807268333, 38.99753561100098),
    zoom: 15.4746,
  );
}
