import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_super_resolution/flutter_super_resolution.dart';
import 'package:flutter_super_resolution_example/boundingbox.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
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
  final _flutterSuperResolutionPlugin = FlutterSuperResolution();
  File? _image;
  late List _recognitions;
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;
  late int _imageHeight;
  late int _imageWidth;
  String _model = "yolo";

  Future<void> setupModel() async {
    switch (_model) {
      case "real_esgan":
        await _flutterSuperResolutionPlugin.setupModel(
          model: "assets/lite-model_esrgan-tf2_1.tflite",
          labels: "assets/mobilenet_v1_1.0_224.txt",
          isAsset: true,
          accelerator: "npu",
          numThreads: 2,
        );
        break;
      case "ssd_mobilenet":
        await _flutterSuperResolutionPlugin.setupModel(
          model: "assets/ssd_mobilenet.tflite",
          labels: "assets/ssd_mobilenet.txt",
          isAsset: true,
          accelerator: "npu",
          numThreads: 2,
        );
        break;
      case "yolo":
        await _flutterSuperResolutionPlugin.setupModel(
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

  Future predictImagePicker() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);
  }

  Future predictImage(XFile image) async {
    var fileImage = File(image.path);
    if (image == null) return;

    switch (_model) {
      case "real_esgan":
        _image = await RealESRGAN(fileImage);
        break;
      case "ssd_mobilenet":
        // TODO : implement ssd_mobilenet
        break;
      case "yolo":
        // TODO : implement ssd_mobilenet
        break;
      default:
        break;
      // await recognizeImageBinary(image);
    }
  }

  @override
  void initState() {
    super.initState();
    setupModel();
  }

  Future RealESRGAN(File image) async {
    var recognitions = await _flutterSuperResolutionPlugin.runModel(
      binary: image.readAsBytesSync(),
      threshold: 0.4,
    );
    setState(() {
      _recognitions = recognitions!;
    });
  }

  Future runModelonFrame() async {
    await _flutterSuperResolutionPlugin.runModelOnFrame(
      binary: _image!.readAsBytesSync(),
      threshold: 0.4,
    );
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
