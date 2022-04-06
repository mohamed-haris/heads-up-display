import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:heads_up_display/fbase_user.dart';
import 'package:heads_up_display/firebase_auth_service.dart';
import 'package:heads_up_display/hud_details.dart';
import 'package:heads_up_display/onboard_view.dart';
import 'package:provider/provider.dart';
import 'home.dart';

List<CameraDescription>? cameras;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    await Firebase.initializeApp();
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
    return MultiProvider(
      providers:[
        StreamProvider<FBaseUser>(
            initialData: FBaseUser(uid: null),
            create: (context) => FirebaseAuthService().user),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Heads-up-Display',
        // home: HomePage(cameras),
        home: OnboardView(),
      ),
    );
  }
}
