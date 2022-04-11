import 'dart:async';
import 'dart:math';

import 'package:battery/battery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heads_up_display/fbase_user.dart';
import 'package:heads_up_display/firestore_service.dart';
import 'package:heads_up_display/speedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sensors/sensors.dart';
import 'package:shake/shake.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import 'mapUtils.dart';
import 'package:location/location.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(13.172455360701715, 80.24790202647446);

class HUDDetails extends StatefulWidget {
  final String name;
  final List emergencyContacts;
  HUDDetails(this.name, this.emergencyContacts);
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
  var speedInMPS;

  late TwilioFlutter twilioFlutter;

  @override
  void initState() {
    super.initState();

    twilioFlutter = TwilioFlutter(
        accountSid: 'AC39e63ec1f29edd760bbdc08f76314dce',
        authToken: 'bca45feaf0e19698b8fe01869ed71f9c',
        twilioNumber: '+18454787636');

    // ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
    //   print(widget.emergencyContacts);
    //   sendCrashSMS("+917401529298");
    // });

    listenBatteryLvl();
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
      // onAccelerate(event);
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

  // void onAccelerate(UserAccelerometerEvent event) {
  //   double newVelocity =
  //       sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

  //   if ((newVelocity - velocity).abs() < 1) {
  //     return;
  //   }

  //   setState(() {
  //     velocity = newVelocity;

  //     if (velocity > highestVelocity) {
  //       highestVelocity = velocity;
  //     }
  //   });
  // }

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

  void sendCrashSMS(String number) {
    twilioFlutter.sendSMS(
        toNumber: number,
        messageBody:
            'SOS! Your contact ${widget.name} might have had an accident. Please reach out as soon as possible.');
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
    // final List<String>? userAccelerometer = _userAccelerometerValues
    //     ?.map((double v) => v.toStringAsFixed(1))
    //     .toList();

    setCurrentLocation();

    geo.Geolocator.getPositionStream(
            locationSettings: geo.AndroidSettings(
                forceLocationManager: true,
                intervalDuration: Duration(seconds: 1),
                distanceFilter: 2,
                accuracy: geo.LocationAccuracy.best))
        .listen((position) {
      speedInMPS = (position.speed *3.6).toStringAsFixed(0);
    });

    initialCameraPosition = CameraPosition(
        zoom: 16,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: lat == null
            ? LatLng(13.172455360701715, 80.24790202647446)
            : LatLng(lat, long));

    updateCurrentLocation(lat == null
        ? LatLng(13.172455360701715, 80.24790202647446)
        : LatLng(lat, long));

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Column(
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
                      Container(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  '${widget.name}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: const [Color(0xff87D3E2), Colors.white],
                      ).createShader(Rect.fromLTWH(0.0, 0.0, 120.0, 70.0)),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9),
                        offset: Offset(3, 3),
                        blurRadius: 7,
                      ),
                    ],
                  ),
                ),
              ),
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
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        speedInMPS != null ? "$speedInMPS Km/h" : '0 Km/h',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: const [Color(0xff87D3E2), Colors.teal],
                            ).createShader(
                                Rect.fromLTWH(0.0, 0.0, 120.0, 70.0)),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.9),
                              offset: Offset(3, 3),
                              blurRadius: 7,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.55,
                      child: Container(
                        height: 130,
                        width: 230,
                        child: GoogleMap(
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            mapType: MapType.normal,
                            zoomControlsEnabled: false,
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

  void updateCurrentLocation(LatLng latLng) async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: latLng,
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }
}


// package com.baseflow.geolocator.location;

// import android.location.Location;
// import android.os.Build;

// import java.util.HashMap;
// import java.util.Map;

// @SuppressWarnings("deprecation")
// public class LocationMapper {
//   public static Map<String, Object> toHashMap(Location location) {
//     if (location == null) {
//       return null;
//     }

//     Map<String, Object> position = new HashMap<>();

//     position.put("latitude", location.getLatitude());
//     position.put("longitude", location.getLongitude());
//     position.put("timestamp", location.getTime());

//     if (location.hasAltitude()) position.put("altitude", location.getAltitude());
//     if (location.hasAccuracy()) position.put("accuracy", (double) location.getAccuracy());
//     if (location.hasBearing()) position.put("heading", (double) location.getBearing());
//     if (location.hasSpeed()) position.put("speed", (double) location.getSpeed());
//     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && location.hasSpeedAccuracy())
//       position.put("speed_accuracy", (double) location.getSpeedAccuracyMetersPerSecond());

//     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//       position.put("is_mocked", location.isMock());
//     } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
//       position.put("is_mocked", location.isFromMockProvider());
//     } else {
//       position.put("is_mocked", false);
//     }

//     return position;
//   }
// }
