import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';
import 'hud_details.dart';

const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";

class HUD extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final String model;

  HUD(this.cameras, this.model);

  @override
  _HUDState createState() => new _HUDState();
}

class _HUDState extends State<HUD> {
  List<dynamic>? _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;

  @override
  void initState() {
    super.initState();
    loadModel();
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
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Camera(
            widget.cameras,
            widget.model,
            setRecognitions,
          ),
          BndBox(
            _recognitions == null ? [] : _recognitions,
            math.max(_imageHeight, _imageWidth),
            math.min(_imageHeight, _imageWidth),
            screen.height,
            screen.width,
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      'assets/hud_bg.png'),
                  fit: BoxFit.cover),
            ),
          ),
          HUDDetails(),
        ],
      ),
    );
  }
}
