import 'dart:async';

import 'package:battery/battery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
// import 'package:pedometer/pedometer.dart';
import 'package:sensors/sensors.dart';

import 'mapUtils.dart';
// import 'package:location/location.dart';

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

  // Stream<StepCount> _stepCountStream;
  // Stream<PedestrianStatus> _pedestrianStatusStream;
  // String _status = '?', _steps = '?';

  final battery = Battery();
  int batteryLvl = 100;

  Timer? timer;

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
    }));
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

  // void initPlatformState() {
  //   _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
  //   _pedestrianStatusStream
  //       .listen(onPedestrianStatusChanged)
  //       .onError(onPedestrianStatusError);

  //   _stepCountStream = Pedometer.stepCountStream;
  //   _stepCountStream.listen(onStepCount).onError(onStepCountError);

  //   if (!mounted) return;
  // }

  // void onStepCount(StepCount event) {
  //   print(event);
  //   setState(() {
  //     _steps = event.steps.toString();
  //   });
  // }

  // void onPedestrianStatusChanged(PedestrianStatus event) {
  //   print(event);
  //   setState(() {
  //     _status = event.status;
  //   });
  // }

  // void onPedestrianStatusError(error) {
  //   print('onPedestrianStatusError: $error');
  //   setState(() {
  //     _status = 'Pedestrian Status not available';
  //   });
  //   print(_status);
  // }

  // void onStepCountError(error) {
  //   print('onStepCountError: $error');
  //   setState(() {
  //     _steps = 'Step Count not available';
  //   });
  // }

  //map setup

  Completer<GoogleMapController> _controller = Completer();

  // Location _location = Location();

  @override
  Widget build(BuildContext context) {
    final List<String>? accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final List<String>? gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final List<String>? userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();

         CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
      child: Column(
        children: [
          Opacity(
            opacity: 0.35,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xff87D3E2),
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
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      gyroscope != null
                          ? 'Gyro: $gyroscope'
                          : 'Gyro: [0.0, 0.0, 0.0]',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Opacity(
                opacity: 0.35,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(130)),
                    color: Color(0xff87D3E2),
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
                          color: Colors.red),
                    ),
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: Colors.white,
                    progressColor: Color(0xff01738E), //87D3E2
                  ),
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
                    GestureDetector(
                      onTap: () => print('hello'),
                      child: Opacity(
                        opacity: 0.35,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              color: Color(0xff87D3E2), shape: BoxShape.circle),
                          child: Center(
                              child: Text('SCAN',
                                  style: TextStyle(color: Colors.white))),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.35,
                      child: Container(
                        height: 150,
                        width: 230,
                        child: GoogleMap(
                      myLocationEnabled: true,
                      compassEnabled: false,
                      tiltGesturesEnabled: false,
                      mapType: MapType.normal,
                      zoomControlsEnabled: false,
                      initialCameraPosition: initialCameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        controller.setMapStyle(MapUtils.mapStyles);
                        _controller.complete(controller);
                      }),
                        ),
                      ),
                    // Opacity(
                    //   opacity: 0.65,
                    //   child: Container(
                    //     child: Column(
                    //       children: [
                    //         Icon(
                    //           _status == 'moving'
                    //               ? Icons.directions_walk
                    //               : _status == 'idle'
                    //                   ? Icons.accessibility_new
                    //                   : Icons.error,
                    //           size: 100,
                    //         ),
                    //         Text(
                    //           _status,
                    //           style:
                    //               _status == 'walking' || _status == 'stopped'
                    //                   ? TextStyle(fontSize: 30)
                    //                   : TextStyle(
                    //                       fontSize: 20, color: Colors.red),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
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





















// import 'dart:async';

// import 'package:battery/battery.dart';
// import 'package:flutter/material.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:pedometer/pedometer.dart';
// import 'dart:math' as math;

// class HUD extends StatefulWidget {
//   @override
//   _HUDState createState() => _HUDState();
// }

// class _HUDState extends State<HUD> {
//   Offset _offset = Offset(0.2, 0.6);

//   Stream<StepCount> _stepCountStream;
//   Stream<PedestrianStatus> _pedestrianStatusStream;
//   String _status = '?', _steps = '?';

//   final battery = Battery();
//   int batteryLvl = 100;

//   Timer timer;

//   @override
//   void initState() {
//     super.initState();
//     listenBatteryLvl();
//     initPlatformState();
//   }

//   void listenBatteryLvl() {
//     timer = Timer.periodic(Duration(seconds: 10), (_) async {
//       updateBatteryLvl();
//     });
//   }

//   Future updateBatteryLvl() async {
//     final batteryLvl = await battery.batteryLevel;
//     setState(() {
//       this.batteryLvl = batteryLvl;
//     });
//   }

//   @override
//   void dispose() {
//     timer.cancel();
//     super.dispose();
//   }

//   void initPlatformState() {
//     _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
//     _pedestrianStatusStream
//         .listen(onPedestrianStatusChanged)
//         .onError(onPedestrianStatusError);

//     _stepCountStream = Pedometer.stepCountStream;
//     _stepCountStream.listen(onStepCount).onError(onStepCountError);

//     if (!mounted) return;
//   }

//   void onStepCount(StepCount event) {
//     print(event);
//     setState(() {
//       _steps = event.steps.toString();
//     });
//   }

//   void onPedestrianStatusChanged(PedestrianStatus event) {
//     print(event);
//     setState(() {
//       _status = event.status;
//     });
//   }

//   void onPedestrianStatusError(error) {
//     print('onPedestrianStatusError: $error');
//     setState(() {
//       _status = 'Pedestrian Status not available';
//     });
//     print(_status);
//   }

//   void onStepCountError(error) {
//     print('onStepCountError: $error');
//     setState(() {
//       _steps = 'Step Count not available';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Transform(
//   transform: Matrix4.skewY(-0.05),
//   origin: Offset(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
//   child: Container(
//       height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//       padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
//       child: Column(
//         children: [
//           Opacity(
//             opacity: 0.65,
//             child: Center(
//               child: Container(
//                 padding: EdgeInsets.all(10),
//                 width: MediaQuery.of(context).size.width * 0.50,
//                 color: Color(0xff87D3E2),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Acc: -0.078 / -0.239',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     Text(
//                       'Gyro: 0.213 / 1.129',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Opacity(
//                 opacity: 0.65,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.all(Radius.circular(130)),
//                     color: Color(0xff87D3E2),
//                   ),
//                   child: CircularPercentIndicator(
//                     radius: 130.0,
//                     animation: true,
//                     animationDuration: 1200,
//                     lineWidth: 15.0,
//                     percent: batteryLvl / 100,
//                     center: Text(
//                       "$batteryLvl%",
//                       style: new TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20.0,
//                           color: Colors.white),
//                     ),
//                     circularStrokeCap: CircularStrokeCap.butt,
//                     backgroundColor: Colors.white,
//                     progressColor: Color(0xff01738E), //87D3E2
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Center(
//             child: Image.asset('images/axis.png'),
//           ),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: () => print('hello'),
//                       child: Opacity(
//                         opacity: 0.65,
//                         child: Container(
//                           width: 150,
//                           height: 150,
//                           decoration: BoxDecoration(
//                               color: Color(0xff87D3E2), shape: BoxShape.circle),
//                           child: Center(
//                               child: Text('SCAN',
//                                   style: TextStyle(color: Colors.white))),
//                         ),
//                       ),
//                     ),
//                     // Opacity(
//                     //   opacity: 0.65,
//                     //   child: Container(
//                     //     child: Column(
//                     //       children: [
//                     //         Icon(
//                     //           _status == 'moving'
//                     //               ? Icons.directions_walk
//                     //               : _status == 'idle'
//                     //                   ? Icons.accessibility_new
//                     //                   : Icons.error,
//                     //           size: 100,
//                     //         ),
//                     //         Text(
//                     //           _status,
//                     //           style:
//                     //               _status == 'walking' || _status == 'stopped'
//                     //                   ? TextStyle(fontSize: 30)
//                     //                   : TextStyle(
//                     //                       fontSize: 20, color: Colors.red),
//                     //         ),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
  
// ),
//     );
//   }

//   _app(BuildContext context) {
    
//   }
// }
