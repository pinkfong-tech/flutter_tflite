import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_super_resolution/flutter_super_resolution.dart';
import 'dart:math' as math;

import 'package:logger/logger.dart';

typedef Callback = void Function(List<dynamic> list, int h, int w);

var logger = Logger(
  printer: PrettyPrinter(),
);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;

  const Camera(this.cameras, this.model, this.setRecognitions, {super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  bool isDetecting = false;

  static const anchors = [
    0.57273,
    0.677385,
    1.87446,
    2.06253,
    3.33843,
    5.47434,
    7.88282,
    3.52778,
    9.77052,
    9.16828
  ];

  @override
  Future<void> initState() async {
    super.initState();

    if (widget.cameras.isEmpty) {
      logger.d('No camera is found');
    } else {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.yuv420,
        enableAudio: false,
      );

      // await _flutterSuperResolutionPlugin.setupModel(
      //   model: "assets/yolov2_tiny.tflite",
      //   labels: "assets/yolov2_tiny.txt",
      //   isAsset: true,
      //   accelerator: "npu",
      //   numThreads: 2,
      // );

      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = DateTime.now().millisecondsSinceEpoch;
            FlutterSuperResolution.instance
                .detectObjectOnFrame(
                    bytesList: img.planes.map((plane) {
                      return plane.bytes;
                    }).toList(),
                    imageHeight: img.height,
                    imageWidth: img.width,
                    imageMean: 0,
                    imageStd: 255.0,
                    numResultsPerClass: 1,
                    threshold: 0.2,
                    anchors: anchors)
                .then((recognitions) {
              logger.d(recognitions);
              int endTime = DateTime.now().millisecondsSinceEpoch;
              widget.setRecognitions(recognitions!, img.height, img.width);
              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    Size? tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
