import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../core/core.dart';
import '../pages.dart';
import 'home_page_vm.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  final PanelController panelController = PanelController();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.1660632, 38.9923299),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake =
      CameraPosition(target: LatLng(37.1660632, 38.9923299), zoom: 18);

  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 95.0;

  togglePanel() {
    if (panelController.panelPosition < 0.5) {
      panelController.open();
    } else {
      panelController.close();
    }
  }

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
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Material(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    SlidingUpPanel(
                      controller: panelController,
                      maxHeight: _panelHeightOpen,
                      minHeight: _panelHeightClosed,
                      parallaxEnabled: true,
                      parallaxOffset: .5,
                      body: _body(),
                      panelBuilder: (sc) => _panel(sc, value),
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
                    Positioned(
                      right: 20.0,
                      bottom: _fabHeight,
                      child: FloatingActionButton(
                        child: Icon(
                          Icons.gps_fixed,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {},
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
              );
      }),
    );
  }

  Widget _panel(ScrollController sc, HomeVm value) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            const SizedBox(
              height: 12.0,
            ),
            dragHandle(),
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
                  crossAxisCount: 3),
              children: value.actionsOnPage
                  .map((e) => _button(e.name, e.icon.icon!, e.color, () {
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
                            case 'more':
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const MorePage()));

                              break;
                            default:
                          }
                        }
                      }))
                  .toList(),
            ),
            const SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text("Images",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text("About",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                  Text(
                    """Pittsburgh is a city in the state of Pennsylvania in the United States, and is the county seat of Allegheny County. A population of about 302,407 (2018) residents live within the city limits, making it the 66th-largest city in the U.S. The metropolitan population of 2,324,743 is the largest in both the Ohio Valley and Appalachia, the second-largest in Pennsylvania (behind Philadelphia), and the 27th-largest in the U.S.\n\nPittsburgh is located in the southwest of the state, at the confluence of the Allegheny, Monongahela, and Ohio rivers. Pittsburgh is known both as "the Steel City" for its more than 300 steel-related businesses and as the "City of Bridges" for its 446 bridges. The city features 30 skyscrapers, two inclined railways, a pre-revolutionary fortification and the Point State Park at the confluence of the rivers. The city developed as a vital link of the Atlantic coast and Midwest, as the mineral-rich Allegheny Mountains made the area coveted by the French and British empires, Virginians, Whiskey Rebels, and Civil War raiders.\n\nAside from steel, Pittsburgh has led in manufacturing of aluminum, glass, shipbuilding, petroleum, foods, sports, transportation, computing, autos, and electronics. For part of the 20th century, Pittsburgh was behind only New York City and Chicago in corporate headquarters employment; it had the most U.S. stockholders per capita. Deindustrialization in the 1970s and 80s laid off area blue-collar workers as steel and other heavy industries declined, and thousands of downtown white-collar workers also lost jobs when several Pittsburgh-based companies moved out. The population dropped from a peak of 675,000 in 1950 to 370,000 in 1990. However, this rich industrial history left the area with renowned museums, medical centers, parks, research centers, and a diverse cultural district.\n\nAfter the deindustrialization of the mid-20th century, Pittsburgh has transformed into a hub for the health care, education, and technology industries. Pittsburgh is a leader in the health care sector as the home to large medical providers such as University of Pittsburgh Medical Center (UPMC). The area is home to 68 colleges and universities, including research and development leaders Carnegie Mellon University and the University of Pittsburgh. Google, Apple Inc., Bosch, Facebook, Uber, Nokia, Autodesk, Amazon, Microsoft and IBM are among 1,600 technology firms generating \$20.7 billion in annual Pittsburgh payrolls. The area has served as the long-time federal agency headquarters for cyber defense, software engineering, robotics, energy research and the nuclear navy. The nation's eighth-largest bank, eight Fortune 500 companies, and six of the top 300 U.S. law firms make their global headquarters in the area, while RAND Corporation (RAND), BNY Mellon, Nova, FedEx, Bayer, and the National Institute for Occupational Safety and Health (NIOSH) have regional bases that helped Pittsburgh become the sixth-best area for U.S. job growth.
                  """,
                    softWrap: true,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ));
  }

  Widget _button(
      String label, IconData icon, Color color, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
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
          const SizedBox(
            height: 12.0,
          ),
          Text(label),
        ],
      ),
    );
  }

  Widget _body() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kGooglePlex,
      myLocationEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  Widget dragHandle() => GestureDetector(
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
