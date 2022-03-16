import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:heads_up_display/hud_details.dart';
import 'home.dart';

List<CameraDescription>? cameras;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
 ));
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Heads-up-Display',
      home: HomePage(cameras),
      // home: Scaffold(
      //   backgroundColor: Colors.black,
      //   body: Stack(
      //     children: [
      //       Container(
      //       decoration: BoxDecoration(
      //         image: DecorationImage(
      //             image: AssetImage(
      //                 'assets/hud_bg.png'),
      //             fit: BoxFit.cover),
      //       ),
      //     ),
      //       HUDDetails(),
      //     ],
      //   ))
    );
  }
}
