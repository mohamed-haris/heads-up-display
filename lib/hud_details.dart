import 'dart:async';
import 'dart:math';

import 'package:battery/battery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heads_up_display/speedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sensors/sensors.dart';

import 'mapUtils.dart';
import 'package:location/location.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(13.172455360701715, 80.24790202647446);

class HUDDetails extends StatefulWidget {
  @override
  _HUDDetailsState createState() => _HUDDetailsState();
}

class _HUDDetailsState extends State<HUDDetails> {
  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  double velocity = 0;
  double highestVelocity = 0.0;

  final battery = Battery();
  int batteryLvl = 100;

  Timer? timer;

  CameraPosition initialCameraPosition = CameraPosition(
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING,
          target: SOURCE_LOCATION);

  var lat;
  var long;

  @override
  void initState() {
    super.initState();
    listenBatteryLvl();
    // initPlatformState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
      onAccelerate(event);
    }));
    setCurrentLocation();
  }

  Future setCurrentLocation() async {
    Location _location = Location();
    LocationData currentLocation = await _location.getLocation();
    setState(() {
      lat = currentLocation.latitude;
    long = currentLocation.longitude;
    });
  }

  void onAccelerate(UserAccelerometerEvent event) {
    double newVelocity =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    if ((newVelocity - velocity).abs() < 1) {
      return;
    }

    setState(() {
      velocity = newVelocity;

      if (velocity > highestVelocity) {
        highestVelocity = velocity;
      }
    });
  }

  void listenBatteryLvl() {
    timer = Timer.periodic(Duration(seconds: 10), (_) async {
      updateBatteryLvl();
    });
  }

  Future updateBatteryLvl() async {
    final batteryLvl = await battery.batteryLevel;
    setState(() {
      this.batteryLvl = batteryLvl;
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  //map setup

  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final List<String>? accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final List<String>? gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final List<String>? userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();

    setCurrentLocation();

    initialCameraPosition = CameraPosition(
        zoom: 16,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: LatLng(lat, long));

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      // padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
      child: Column(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xff87D3E2).withOpacity(0.35),
              ),
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    accelerometer != null
                        ? 'Acc: $accelerometer'
                        : 'Acc: [0.0, 0.0, 0.0]',
                    style: TextStyle(shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9),
                        offset: Offset(3, 3),
                        blurRadius: 7,
                      ),
                    ], color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    gyroscope != null
                        ? 'Gyro: $gyroscope'
                        : 'Gyro: [0.0, 0.0, 0.0]',
                    style: TextStyle(shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9),
                        offset: Offset(3, 3),
                        blurRadius: 7,
                      ),
                    ], color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(130)),
                  color: Color(0xff87D3E2).withOpacity(0.3),
                ),
                child: CircularPercentIndicator(
                  radius: 130.0,
                  animation: true,
                  animationDuration: 1200,
                  lineWidth: 15.0,
                  percent: batteryLvl / 100,
                  center: Text(
                    "$batteryLvl%",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white,
                        shadows: [
                          BoxShadow(
                              blurRadius: 5,
                              offset: Offset(3, 3),
                              color: Colors.black)
                        ]),
                  ),
                  circularStrokeCap: CircularStrokeCap.butt,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  progressColor: Color(0xff01738E).withOpacity(0.3),
                ),
              ),
            ],
          ),
          Center(
            child: Image.asset('assets/axis.png'),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff87D3E2).withOpacity(0.45),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(3, 3),
                                blurRadius: 5)
                          ]),
                      child: Speedometer(
                        speed: velocity,
                        speedRecord: highestVelocity,
                      ),
                    ),
                    Opacity(
                      opacity: 0.55,
                      child: Container(
                        height: 130,
                        width: 230,
                        child: GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: initialCameraPosition,
                            onMapCreated: (GoogleMapController controller) {
                              controller.setMapStyle(MapUtils.mapStyles);
                              _controller.complete(controller);
                            }),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
