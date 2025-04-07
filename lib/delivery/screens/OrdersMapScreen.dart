import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mighty_delivery/main/network/http_utils.dart';
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

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
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
  void initState() {
      super.initState();
      setMarkerIcons();
      // getLatLngOfOrdersApi();

      // test bglocator
      _isMoving = false;
      _enabled = false;
      _content = '';
      _motionActivity = 'UNKNOWN';
      _odometer = '0';    

      // 1.  Listen to events (See docs for all 12 available events).
      // bg.BackgroundGeolocation.onLocation(_onLocation);
      bg.BackgroundGeolocation.onLocation(
        (bg.Location location) {
          print("[onLocation] success: $location");
          _onLocation(location);
        },
        (bg.LocationError error) {
          print("[onLocation] ERROR: $error");
        },
      );      
      bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
      bg.BackgroundGeolocation.onActivityChange(_onActivityChange);

      // 2.  Configure the plugin
      bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        reset: true,
      )).then((bg.State state) {
        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving == true;
        });

      // 启动定位服务
      bg.BackgroundGeolocation.start().then((bg.State state) {
        print('[start] 定位已启动: $state');
      });

      // 启动_onClickChangePace
      _onClickChangePace();

    });
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


      // value.data!.forEach((element) {
      //   if (element.status == ORDER_ASSIGNED) {
      //     InfoWindow item = new InfoWindow(
      //         id: element.id.toString(),
      //         startTime: element.pickupPoint!.startTime,
      //         endTime: element.pickupPoint!.endTime,
      //         status: element.status,
      //         address: element.pickupPoint!.address,
      //         title: language.pendingPickup);

      //     markers.add(
      //       Marker(
      //         markerId: MarkerId(element.id.toString()),
      //         position: LatLng(element.pickupPoint!.latitude.toDouble(), element.pickupPoint!.longitude.toDouble()),
      //         icon: assignedMarkerIcon!,
      //         onTap: () => _onMarkerTapped(
      //             position: LatLng(element.pickupPoint!.latitude.toDouble(), element.pickupPoint!.longitude.toDouble()),
      //             id: element.id!),
      //       ),
      //     );
      //     infoWindowItems.add(item);
      //     // assignedOrders
      //     //     .add(LatLng(element.pickupPoint!.latitude!.toDouble(), element.pickupPoint!.longitude!.toDouble()));
      //   } else if (element.status == ORDER_ACCEPTED ||
      //       element.status == ORDER_PICKED_UP ||
      //       element.status == ORDER_ARRIVED ||
      //       element.status == ORDER_DEPARTED) {
      //     InfoWindow item = new InfoWindow(
      //         id: element.id.toString(),
      //         startTime: element.deliveryPoint!.startTime,
      //         endTime: element.deliveryPoint!.endTime,
      //         status: element.status,
      //         address: element.deliveryPoint!.address,
      //         title: language.pendingDelivery);

      //     markers.add(
      //       Marker(
      //         markerId: MarkerId(element.id.toString()),
      //         position: LatLng(element.deliveryPoint!.latitude.toDouble(), element.deliveryPoint!.longitude.toDouble()),
      //         onTap: () => _onMarkerTapped(
      //           position: LatLng(
      //             element.deliveryPoint!.latitude.toDouble(),
      //             element.deliveryPoint!.longitude.toDouble(),
      //           ),
      //           id: element.id!,
      //         ),
      //         icon: acceptedMarkerIcon!,
      //       ),
      //     );
      //     infoWindowItems.add(item);
      //     // acceptedOrders
      //     //     .add(LatLng(element.deliveryPoint!.latitude!.toDouble(), element.deliveryPoint!.longitude!.toDouble()));
      //   }
      // });

      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      print("-----------------${error.toString()}");
    });
  }

  void _onMarkerTapped({required LatLng position, required int id}) async {
    final screenCoordinate = await googleMapController!.getScreenCoordinate(position);
    final RenderBox mapBox = context.findRenderObject() as RenderBox;
    final Offset mapPosition = mapBox.localToGlobal(Offset.zero);

    setState(() {
      _selectedMarkerPosition = position;
      selectedInfoWindow = infoWindowItems.firstWhere((infoWindow) => infoWindow.id == id.toString());
      _isInfoWindowVisible = true;
      infoWindowOffset = Offset(
        screenCoordinate.x.toDouble() - mapPosition.dx,
        screenCoordinate.y.toDouble() - mapPosition.dy - 100,
      );
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _isInfoWindowVisible = false;
      _selectedMarkerPosition = null; // Close the currently open InfoWindow
    });
  }

  // test geolocator
  void _onLocation(bg.Location location) async{
    print('-----------------[location] - $location');

    final String odometerKM = (location.odometer / 1000.0).toStringAsFixed(1);
    LatLng currentLocation = LatLng(location.coords.latitude, location.coords.longitude);

    setState(() {
      _content = encoder.convert(location.toMap());
      _odometer = odometerKM;

      // 移除之前的定位marker
      markers.removeWhere((marker) => marker.markerId.value == "currentLocation");
      markers.add(
        Marker(
          markerId: MarkerId("currentLocation"),
          position: currentLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () {
            // 测试点击 marker 显示 infoWindow
            _onMarkerTapped(
              position: currentLocation,
              id: 1, 
            );
          },
        )
      );

    });

    // TODO
    var token = SpUtil.token.val;
    SpUtil.token.val = "";

    // send the location to the server
    var r = await HttpUtils.post("/mobile/locations/create", data: {
      "latitude": location.coords.latitude,
      "longitude": location.coords.longitude,
      "timeStamp": location.timestamp,
      "identityUserId": token,
      "address": "location."
    });
    if(r.code == 0){
      print("success");
    }else{
      print("error");
    }
  }

  void _onMotionChange(bg.Location location) {
    print('[motionchange] - $location');
  }
  
  Future<void> _onActivityChange(bg.ActivityChangeEvent event) async {
    print('[activitychange] - $event');
    // 获取当前位置信息
    
    // try {
    //   bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(
    //     persist: false,
    //     // desiredAccuracy: 0,
    //     desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW, // 降低精度要求    
    //     timeout: 60000,
    //     samples: 3,
    //   );
    //   print('[activitychange-current-location] - lat: ${location.coords.latitude}, lon: ${location.coords.longitude}');
    // } catch (error) {
    //   print('[activitychange] 获取 location 出错: $error');
    // }

    // setState(() {
    //   _motionActivity = event.activity;
    // });
    if (!mounted) return; // 检查是否仍然挂载
    setState(() {
      _motionActivity = event.activity;
    });
  }

  // Manually toggle the tracking state:  moving vs stationary
  void _onClickChangePace() {
    setState(() {
      _isMoving = !_isMoving;
    });
    print('[onClickChangePace] -> $_isMoving');

    bg.BackgroundGeolocation.changePace(_isMoving).then((bool isMoving) {
      print('[changePace] success $isMoving');
    }).catchError((e) {
      print('[changePace] ERROR: ${e.code}');
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
              markers.isNotEmpty?
                  // GoogleMap(
                  //     markers: markers.map((e) => e).toSet(),
                  //     polylines: _polylines,
                  //     mapType: MapType.normal,
                  //     cameraTargetBounds: CameraTargetBounds.unbounded,
                  //     initialCameraPosition: CameraPosition(
                  //       target: markers.first.position,
                  //       zoom: 12.0,
                  //     ),
                  //     onMapCreated: onMapCreated,
                  //     onTap: _onMapTapped,
                  //     tiltGesturesEnabled: true,
                  //     scrollGesturesEnabled: true,
                  //     zoomGesturesEnabled: true,
                  //     // trafficEnabled: true,
                  //   ).expand()
                    GoogleMap(
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
          if (appStore.isLoading && !markers.isNotEmpty) Center(child: loaderWidget()),
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
                    color: statusColor(selectedInfoWindow!.status.validate()).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(orderStatus(selectedInfoWindow!.status!),
                    style: primaryTextStyle(size: 14, color: statusColor(selectedInfoWindow!.status.validate()))),
              ),
              5.width,
              Container(
                decoration: BoxDecoration(
                    color: statusColor(selectedInfoWindow!.title.validate()).withOpacity(0.08),
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
                decoration: BoxDecoration(color: ColorUtils.colorPrimary, borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(language.view, style: primaryTextStyle(size: 14, color: white)).onTap(() {
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
