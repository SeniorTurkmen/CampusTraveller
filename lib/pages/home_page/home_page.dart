import 'dart:async';
import 'dart:ui';

import 'package:campus_traveller/core/const/map_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../core/core.dart';
import '../../core/models/location.dart';
import '../pages.dart';
import 'home_page_vm.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const CameraPosition _kLake =
      CameraPosition(target: LatLng(37.1660632, 38.9923299), zoom: 18);

  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 95.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      if (!await Permission.location.isGranted) {
        Permission.location.request();
      }
    });

    _fabHeight = _initFabHeight;
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

    return ChangeNotifierProvider(
      create: (_) => HomeVm(),
      child: Consumer<HomeVm>(builder: (_, value, __) {
        return value.status == LoadingProcess.loading
            ? SizedBox(
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
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Scaffold(
                  body: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      SlidingUpPanel(
                        controller: value.panelController,
                        maxHeight: _panelHeightOpen,
                        minHeight: _panelHeightClosed,
                        parallaxEnabled: true,
                        parallaxOffset: .5,
                        body: _body(
                            value.selected,
                            (item) => value.selectLocation(item),
                            value.setGoogleMapController,
                            value.kHarranOsmanBey),
                        panelBuilder: (sc) {
                          value.setScrollController(sc);
                          return _panel(value);
                        },
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0)),
                        onPanelSlide: (double pos) => setState(() {
                          _fabHeight =
                              pos * (_panelHeightOpen - _panelHeightClosed) +
                                  _initFabHeight;
                        }),
                      ),

                      // the fab
                      if (value.selected != null)
                        Positioned(
                          right: 20.0,
                          bottom: _fabHeight,
                          child: FloatingActionButton(
                            child: Icon(
                              Icons.navigation_rounded,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              value.selectLocation(value.selected!);
                            },
                            backgroundColor: Colors.white,
                          ),
                        ),

                      Positioned(
                          top: 0,
                          child: ClipRRect(
                              child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).padding.top,
                                    color: Colors.transparent,
                                  )))),
                    ],
                  ),
                ),
              );
      }),
    );
  }

  Widget _panel(HomeVm value) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: false,
        child: _homePanel(value));
  }

  ListView _homePanel(HomeVm value) {
    return ListView(
      controller: value.scrollController,
      padding: EdgeInsets.only(bottom: 250),
      children: value.selected == null
          ? _homePanelItems(value)
          : _locationsPanelItems(
              value.selected!, value.deSelect, value.togglePanel),
    );
  }

  List<Widget> _homePanelItems(HomeVm value) {
    return <Widget>[
      const SizedBox(
        height: 12.0,
      ),
      dragHandle(value.togglePanel),
      const SizedBox(
        height: 18.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text(
            "Kampüsü Keşfet",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 24.0,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 36.0,
      ),
      GridView(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 2 / 1),
        children: value.actionsOnPage
            .map(
              (e) => _button(
                e.name,
                e.icon.icon!,
                e.color,
                () {
                  if (e.isWebViev) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            WebViewPages(title: e.name, url: e.url!)));
                  } else {
                    switch (e.page) {
                      case 'calculate':
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const MyCalculator()));
                        break;
                      case 'anouncePage':
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const AnouncePage()));

                        break;
                      case 'logout':
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInPage()),
                        );

                        break;
                      default:
                    }
                  }
                },
              ),
            )
            .toList(),
      ),
      if (value.banner != null) ...{
        const SizedBox(
          height: 36.0,
        ),
        Container(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .3,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  value.banner!,
                  fit: BoxFit.fitWidth,
                ),
              ),
            )),
      },
      const SizedBox(
        height: 36.0,
      ),
      Container(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Lokasyonlar",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(
              height: 12.0,
            ),
            Card(
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Lokasyon Ara', labelText: 'Lokasyon Ara'),
                onChanged: value.searchSection,
              ),
            ),
            Column(
              children: value.searchedLocations
                  .map((e) => GestureDetector(
                        onTap: () {
                          value.selectLocation(e);
                          FocusScope.of(context).unfocus();
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          color: value.selected?.name == e.name
                              ? Colors.yellow
                              : Colors.white,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * .04,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on),
                                Text(e.name)
                              ],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 36.0,
      ),
    ];
  }

  List<Widget> _locationsPanelItems(
      Location selected, Function() deSelect, Function() togglePanel) {
    return <Widget>[
      const SizedBox(
        height: 12.0,
      ),
      dragHandle(togglePanel),
      const SizedBox(
        height: 18.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
              onTap: deSelect, child: Icon(Icons.keyboard_backspace)),
          Text(
            selected.name,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 24.0,
            ),
          ),
          Visibility(visible: false, child: Icon(Icons.keyboard_backspace))
        ],
      ),
      const SizedBox(
        height: 36.0,
      ),
      SizedBox(
          height: MediaQuery.of(context).size.height * .3,
          child: ClipRRect(
            child: Image.network(selected.image),
          ))
    ];
  }

  Widget _button(
      String label, IconData icon, Color color, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                icon,
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                      blurRadius: 8.0,
                    )
                  ]),
            ),
          ),
          Text(label),
        ],
      ),
    );
  }

  Widget _body(Location? selected, Function(Location) seter,
      Function(GoogleMapController) setController, CameraPosition initialPos) {
    return GoogleMap(
      onTap: (_) => FocusScope.of(context).unfocus(),
      mapType: MapType.normal,
      buildingsEnabled: true,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      myLocationButtonEnabled: true,
      markers: selected == null
          ? <Marker>{}
          // ignore: prefer_collection_literals
          : <Marker>[
              Marker(
                markerId: MarkerId(selected.name),
                position: LatLng(selected.longtidue, selected.latidute),
                infoWindow:
                    InfoWindow(title: selected.name, snippet: selected.detail),
                icon: selected.name == selected.name
                    ? BitmapDescriptor.defaultMarkerWithHue(50)
                    : BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure),
              )
            ].toSet(),
      initialCameraPosition: initialPos,
      myLocationEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle(MapStyle.customMap);
        setController(controller);
      },
    );
  }

  Widget dragHandle(Function() togglePanel) => GestureDetector(
        onTap: togglePanel,
        child: Center(
          child: Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}
