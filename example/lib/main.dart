import 'dart:core';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_super_resolution/flutter_super_resolution.dart';
import 'package:flutter_super_resolution_example/boundingbox.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import 'camera.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logger.d(e.code, e.description);
  }

  await FlutterSuperResolution.instance.setupModel(
    model: "assets/yolov2_tiny.tflite",
    labels: "assets/yolov2_tiny.txt",
    isAsset: true,
    accelerator: "npu",
    numThreads: 2,
  );

  runApp(MyApp(cameras: cameras));
}

List<CameraDescription> cameras = [];

class MyApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(cameras: widget.cameras),
    );
  }
}

class Home extends StatefulWidget {
  final List<CameraDescription> cameras;
  const Home({super.key, required this.cameras});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "yolo";

  Future<void> setupModel() async {
    switch (_model) {
      case "real_esgan":
        await FlutterSuperResolution.instance.setupModel(
          model: "assets/lite-model_esrgan-tf2_1.tflite",
          labels: "assets/mobilenet_v1_1.0_224.txt",
          isAsset: true,
          accelerator: "npu",
          numThreads: 2,
        );
        break;
      case "ssd_mobilenet":
        await FlutterSuperResolution.instance.setupModel(
          model: "assets/ssd_mobilenet.tflite",
          labels: "assets/ssd_mobilenet.txt",
          isAsset: true,
          accelerator: "npu",
          numThreads: 2,
        );
        break;
      case "yolo":
        logger.d("setup yolo");
        await FlutterSuperResolution.instance.setupModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
          isAsset: true,
          accelerator: "npu",
          numThreads: 2,
        );
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
        title: const Text('TFLite Plugin example app'),
      ),
      body: Stack(
        children: [
          Camera(
            widget.cameras,
            _model,
            setRecognitions,
          ),
          BndBox(
              _recognitions,
              math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth),
              screen.height,
              screen.width,
              _model)
        ],
      ),
    );
  }
}
