import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/services/LocationTrackingService.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';
import '../../user/screens/OrderDetailScreen.dart';

import '../../extensions/colors.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

JsonEncoder encoder = const JsonEncoder.withIndent('     ');

class OrdersMapScreen extends StatefulWidget {
  const OrdersMapScreen({super.key});

  @override
  State<OrdersMapScreen> createState() => _OrdersMapScreenState();
}

class _OrdersMapScreenState extends State<OrdersMapScreen> {
  List<Marker> markers = [];
  GoogleMapController? googleMapController;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> assignedOrders = [];
  List<LatLng> acceptedOrders = [];
  BitmapDescriptor? assignedMarkerIcon;
  BitmapDescriptor? acceptedMarkerIcon;
  LatLng? _selectedMarkerPosition;
  bool _isInfoWindowVisible = false;
  Offset? infoWindowOffset;
  InfoWindow? selectedInfoWindow;
  List<InfoWindow> infoWindowItems = [];

  StreamSubscription? _locSub;

  // LatLng? _center;
  void onMapCreated(GoogleMapController controller) async {
    setState(() {
      googleMapController = controller;
      // setPolylines().then((_) => setMapFitToCenter(_polylines));
    });
  }

  // test bglocator
  late bool _isMoving;
  late bool _enabled;
  late String _motionActivity;
  late String _odometer;
  late String _content;

  @override
  void dispose() {
    bg.BackgroundGeolocation.removeListeners();
    super.dispose();
  }

  void _updateCurrentMarker(bg.Location location) {
    if (!mounted) return;
    final LatLng current =
        LatLng(location.coords.latitude, location.coords.longitude);
    setState(() {
      markers.removeWhere((m) => m.markerId.value == "currentLocation");
      markers.add(Marker(
        markerId: const MarkerId("currentLocation"),
        position: current,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () => _onMarkerTapped(position: current, id: 1),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    setMarkerIcons();

    // 订阅统一服务的位置信息
    _locSub = LocationTrackingService.instance.locationStream.listen((loc) {
      _updateCurrentMarker(loc);
    });

    // 若需要初次显示最近一次缓存
    final last = LocationTrackingService.instance.lastLocation;
    if (last != null) {
      _updateCurrentMarker(last);
    }

    // test bglocator
    _isMoving = false;
    _enabled = false;
    _content = '';
    _motionActivity = 'UNKNOWN';
    _odometer = '0';
  }

  setMarkerIcons() async {
    assignedMarkerIcon = await createMarkerIconFromAsset(ic_assigned_marker);
    acceptedMarkerIcon = await createMarkerIconFromAsset(ic_accepted_marker);
  }

  getLatLngOfOrdersApi() async {
    appStore.setLoading(true);
    await getLatLngOfOrders().then((value) {
      // print("----------------------${value}");
      markers.clear();
      infoWindowItems.clear();

      //test
      markers.add(
        Marker(
          markerId: MarkerId("testMarker"),
          position: LatLng(37.4219999, -122.0840575), // 测试位置
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () {
            // 测试点击 marker 显示 infoWindow
            _onMarkerTapped(
              position: LatLng(37.4219999, -122.0840575),
              id: 1, // 测试 id
            );
          },
        ),
      );
      // 创建测试 infoWindow 数据
      infoWindowItems.clear();
      infoWindowItems.add(
        InfoWindow(
          id: "1",
          startTime: "10:00",
          endTime: "11:00",
          status: "Test Status",
          title: "Test Marker",
          address: "Test Address",
        ),
      );
      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      print("-----------------${error.toString()}");
    });
  }

  void _onMarkerTapped({required LatLng position, required int id}) async {
    final screenCoordinate =
        await googleMapController!.getScreenCoordinate(position);
    final RenderBox mapBox = context.findRenderObject() as RenderBox;
    final Offset mapPosition = mapBox.localToGlobal(Offset.zero);

    if (!mounted) return;

    setState(() {
      _selectedMarkerPosition = position;
      selectedInfoWindow = infoWindowItems
          .firstWhere((infoWindow) => infoWindow.id == id.toString());
      _isInfoWindowVisible = true;
      infoWindowOffset = Offset(
        screenCoordinate.x.toDouble() - mapPosition.dx,
        screenCoordinate.y.toDouble() - mapPosition.dy - 100,
      );
    });
  }

  void _onMapTapped(LatLng position) {
    if (!mounted) return;

    setState(() {
      _isInfoWindowVisible = false;
      _selectedMarkerPosition = null; // Close the currently open InfoWindow
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: commonAppBarWidget(language.trackOrder),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              markers.isNotEmpty
                  ? GoogleMap(
                      markers: markers.toSet(),
                      polylines: _polylines,
                      mapType: MapType.normal,
                      cameraTargetBounds: CameraTargetBounds.unbounded,
                      initialCameraPosition: CameraPosition(
                        target: markers.isNotEmpty
                            ? markers.first.position
                            : LatLng(37.4219999, -122.0840575), // 默认位置
                        zoom: 12.0,
                      ),
                      onMapCreated: (controller) {
                        onMapCreated(controller);
                        // 如果已有定位 marker，则把摄像头定位到当前位置
                        if (markers.isNotEmpty) {
                          controller.animateCamera(
                            CameraUpdate.newLatLng(markers.first.position),
                          );
                        }
                      },
                      onTap: _onMapTapped,
                      tiltGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                    ).expand()
                  : !appStore.isLoading
                      ? Center(child: Text("appstore${appStore.isLoading}"))
                      : SizedBox(),
            ],
          ),
          if (appStore.isLoading && !markers.isNotEmpty)
            Center(child: loaderWidget()),
          if (_isInfoWindowVisible && _selectedMarkerPosition != null)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 75,
              top: MediaQuery.of(context).size.height / 2 - 100,
              child: _isInfoWindowVisible && _selectedMarkerPosition != null
                  ? _customInfoWindow()
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.red,
                    ),
            ),
        ],
      ),
    );
  }

  Widget _customInfoWindow() {
    return Container(
      width: context.width() * 0.5,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: statusColor(selectedInfoWindow!.status.validate())
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(orderStatus(selectedInfoWindow!.status!),
                    style: primaryTextStyle(
                        size: 14,
                        color: statusColor(
                            selectedInfoWindow!.status.validate()))),
              ),
              5.width,
              Container(
                decoration: BoxDecoration(
                    color: statusColor(selectedInfoWindow!.title.validate())
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  selectedInfoWindow!.title!,
                  style: primaryTextStyle(size: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ).expand(),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${selectedInfoWindow!.id.toString()}',
                style: boldTextStyle(),
              ),
              Container(
                decoration: BoxDecoration(
                    color: ColorUtils.colorPrimary,
                    borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(language.view,
                        style: primaryTextStyle(size: 14, color: white))
                    .onTap(() {
                  OrderDetailScreen(
                    orderId: selectedInfoWindow!.id.toInt(),
                  ).launch(context);
                }),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(selectedInfoWindow!.address.toString()),
        ],
      ),
    );
  }
}

class InfoWindow {
  final String? id;
  final String? startTime;
  final String? endTime;
  final String? status;
  final String? title;
  final String? address;

  InfoWindow(
      {required this.id,
      required this.startTime,
      required this.endTime,
      required this.status,
      required this.title,
      required this.address});
}
