import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:heads_up_display/hud.dart';
import 'package:heads_up_display/main.dart';
import 'package:tflite/tflite.dart';
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
    super.initState();
  }

  loadModel() async {
    String res;
    res = (await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt"))!;

    print(res);
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HUD(cameras,ssd)),
                    ),
                  ),
                  // RaisedButton(
                  //   color: Colors.teal,
                  //   child: const Text(
                  //     yolo,
                  //     style: TextStyle(color: Colors.black),
                  //   ),
                  //   onPressed: () =>  Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => HUD(cameras,yolo)),
                  //   ),
                  // ),
                ],
              ),
            )
    );
  }
}
