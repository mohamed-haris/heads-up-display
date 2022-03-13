import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final Callback setRecognitions;
  final String model;

  Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras!.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras![0],
        ResolutionPreset.high,
      );
      controller?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller?.lockCaptureOrientation();

        controller?.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = new DateTime.now().millisecondsSinceEpoch;

            // Tflite.detectObjectOnFrame(
            //   rotation: 0,
            //   bytesList: img.planes.map((plane) {
            //     return plane.bytes;
            //   }).toList(),
            //   model: widget.model == yolo ? "YOLO" : "SSDMobileNet",
            //   imageHeight: img.height,
            //   imageWidth: img.width,
            //   imageMean: widget.model == yolo ? 0 : 127.5,
            //   imageStd: widget.model == yolo ? 255.0 : 127.5,
            //   numResultsPerClass: 1,
            //   threshold: widget.model == yolo ? 0.2 : 0.4,
            // ).then((recognitions) {
            //   // print(recognitions);

            //   int endTime = new DateTime.now().millisecondsSinceEpoch;
            //   print("Detection took ${endTime - startTime}");

            //   widget.setRecognitions(recognitions!, img.height, img.width);

            //   isDetecting = false;
            // });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller!.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

//     final size = MediaQuery.of(context).size;
// final deviceRatio = size.width / size.height;
// double xScale = controller!.value.aspectRatio / deviceRatio;
// final yScale = 1.0;

// if (MediaQuery.of(context).orientation == Orientation.landscape) {
//   xScale = 1.0;
// }

return Container(
  height: MediaQuery.of(context).size.height,
  width: MediaQuery.of(context).size.width,
  child: CameraPreview(controller!));

//     return RotatedBox(
//   quarterTurns: MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 0,
//   child: Container(
//     child: Transform(
//         alignment: Alignment.center,
//         transform: Matrix4.diagonal3Values(xScale, yScale, 1),
//         child: CameraPreview(controller!),
//       ),
//   ),
// );
  }
}
