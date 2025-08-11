/// flutter_background_geolocation Hello World
/// https://github.com/transistorsoft/flutter_background_geolocation
////
// For pretty-printing location JSON.  Not a requirement of flutter_background_geolocation
//
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/utils/storage.dart';

JsonEncoder encoder = const JsonEncoder.withIndent('     ');

//
////
class MyTestHomePage extends StatefulWidget {
  const MyTestHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyTestHomePageState createState() => _MyTestHomePageState();
}

class _MyTestHomePageState extends State<MyTestHomePage> {
  late bool _isMoving;
  late bool _enabled;
  late String _motionActivity;
  late String _odometer;
  late String _content;

  @override
  void initState() {
    _isMoving = false;
    _enabled = false;
    _content = '';
    _motionActivity = 'UNKNOWN';
    _odometer = '0';

    // 1.  Listen to events (See docs for all 12 available events).
    bg.BackgroundGeolocation.onLocation(_onLocation);
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
    bg.BackgroundGeolocation.onActivityChange(_onActivityChange);
    bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
    bg.BackgroundGeolocation.onConnectivityChange(_onConnectivityChange);

    // 2.  Configure the plugin
    bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 1,
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
    });
  }

  void _onClickEnable(enabled) {
    if (enabled) {
      bg.BackgroundGeolocation.start().then((bg.State state) {
        print('[start] success $state');
        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving == true;
        });
      });
    } else {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        print('[stop] success: $state');
        // Reset odometer.
        bg.BackgroundGeolocation.setOdometer(0.0);

        setState(() {
          _odometer = '0.0';
          _enabled = state.enabled;
          _isMoving = state.isMoving == true;
        });
      });
    }
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

  // Manually fetch the current position.
  void _onClickGetCurrentPosition() {
    bg.BackgroundGeolocation.getCurrentPosition(
            persist: false, // <-- do not persist this location
            desiredAccuracy: 0, // <-- desire best possible accuracy
            timeout: 30000, // <-- wait 30s before giving up.
            samples: 3 // <-- sample 3 location before selecting best.
            )
        .then((bg.Location location) {
      print('[getCurrentPosition] - $location');
    }).catchError((error) {
      print('[getCurrentPosition] ERROR: $error');
    });
  }

  ////
  // Event handlers
  //

  void _onLocation(bg.Location location) async{
    print('[location] - $location');

    final String odometerKM = (location.odometer / 1000.0).toStringAsFixed(1);

    setState(() {
      _content = encoder.convert(location.toMap());
      _odometer = odometerKM;
    });

    // TODO
    var token = SpUtil.token.val;
    SpUtil.token.val = "";
// {
//   "address": "string",
//   "latitude": 0,
//   "longitude": 0,
//   "timeStamp": "2025-03-11T07:15:44.235Z",
//   "identityUserId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
// }


    // send the location to the server
    var r = await HttpUtils.post("/api/mobile/locations/create", data: {
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

    // use it for testing internet connection
    // var l = await HttpUtils.get("/account/login", params: {
    //   "UserNameOrEmailAddress": "Admin",
    //   "password": "1q2w3E*"
    // });
    // print(l);
  }

  void _onMotionChange(bg.Location location) {
    print('[motionchange] - $location');
  }

  Future<void> _onActivityChange(bg.ActivityChangeEvent event) async {
    print('[activitychange] - $event');
    // 获取当前位置信息
    
    try {
      bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(
        persist: false,
        desiredAccuracy: 0,
        timeout: 30000,
        samples: 3,
      );
      print('[activitychange-current-location] - lat: ${location.coords.latitude}, lon: ${location.coords.longitude}');
    } catch (error) {
      print('[activitychange] 获取 location 出错: $error');
    }

    setState(() {
      _motionActivity = event.activity;
    });
  }

  void _onProviderChange(bg.ProviderChangeEvent event) {
    print('$event');

    setState(() {
      _content = encoder.convert(event.toMap());
    });
  }

  void _onConnectivityChange(bg.ConnectivityChangeEvent event) {
    print('$event');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Background Geolocation'), actions: <Widget>[
        Switch(value: _enabled, onChanged: _onClickEnable),
      ]),
      body: SingleChildScrollView(child: Text(_content)),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.gps_fixed),
                onPressed: _onClickGetCurrentPosition,
              ),
              Text('$_motionActivity · $_odometer km'),
              MaterialButton(
                  minWidth: 50.0,
                  color: _isMoving ? Colors.red : Colors.green,
                  onPressed: _onClickChangePace,
                  child: Icon(_isMoving ? Icons.pause : Icons.play_arrow,
                      color: Colors.white))
            ],
          ),
        ),
      ),
    );
  }
}
