import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:heads_up_display/fbase_user.dart';
import 'package:heads_up_display/firestore_service.dart';
import 'package:heads_up_display/hud.dart';
import 'package:heads_up_display/main.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';
import 'package:tflite/tflite.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';

const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";

class HomePage extends StatefulWidget {
  final List<CameraDescription>? cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
  ]);
  
    super.initState();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  String name = '';
  void setName(String s){
    setState(() {
      name = s;
    });
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<FBaseUser>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.blue,
                    child: const Text(
                      "Wake Up!!",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async {
                      var s = await FirestoreService().getName(user.uid!);
                      List emergencyContacts = await FirestoreService().getEmergencyContacts(user.uid!);
                      setName(s);
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HUD(cameras,ssd, name, emergencyContacts)),
                    );
                    }
                  ),
                  RaisedButton(
                    color: Colors.teal,
                    child: const Text(
                      yolo,
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async {
                      var s = await FirestoreService().getName(user.uid!);
                      List emergencyContacts = await FirestoreService().getEmergencyContacts(user.uid!);
                      setName(s);
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HUD(cameras,yolo, name, emergencyContacts)),
                    );
                    }
                  ),
                ],
              ),
            )
    );
  }
}
