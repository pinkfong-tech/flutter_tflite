import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_super_resolution/flutter_super_resolution.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterSuperResolutionPlugin = FlutterSuperResolution();

  File? _image;
  List _recognitions = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> predictImagePicker() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    setState(() {});
    // predictImage(image);
  }

  @override
  void initState() {
    super.initState();
    setupModel();
  }

  Future<void> setupModel() async {
    await _flutterSuperResolutionPlugin.setupModel(
      model: "assets/lite-model_esrgan-tf2_1.tflite",
      isAsset: true,
      accelerator: "npu",
      numThreads: 2,
    );
  }

  // Future<void> runModel() async {
  //   await _flutterSuperResolutionPlugin.runModel();
  // }

  Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel);
        buffer[pixelIndex++] = img.getGreen(pixel);
        buffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _flutterSuperResolutionPlugin = FlutterSuperResolution();

  File? _image;
  List _recognitions = [];
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;
  late double _imageHeight;
  late double _imageWidth;
  String _model = "real_esgan";

  Future predictImagePicker() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);
  }

  Future predictImage(XFile image) async {
    // Image.file(File(image.path));
    var fileImage = File(image.path);
    if (image == null) return;

    switch (_model) {
      case "real_esgan":
        await RealESRGAN(fileImage);
        break;
      default:
        break;
      // await recognizeImageBinary(image);
    }

    FileImage(fileImage)
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));

    setState(() {
      _image = fileImage;
      _busy = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setupModel();
  }

  Future<void> setupModel() async {
    await _flutterSuperResolutionPlugin.setupModel(
      model: "assets/lite-model_esrgan-tf2_1.tflite",
      labels: "assets/mobilenet_v1_1.0_224.txt",
      isAsset: true,
      accelerator: "npu",
      numThreads: 2,
    );
  }

  // Future<void> runModel() async {
  //   await _flutterSuperResolutionPlugin.runModel();
  // }

  // ignore: non_constant_identifier_names
  Future RealESRGAN(File image) async {
    var recognitions = await _flutterSuperResolutionPlugin.runModel(
      binary: image.readAsBytesSync(),
      threshold: 0.4,
    );
    setState(() {
      _recognitions = recognitions!;
    });
  }

  Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel);
        buffer[pixelIndex++] = img.getGreen(pixel);
        buffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: MediaQuery.of(context).size.width,
      child: _image == null
          ? const Text("No image selected.")
          : Container(
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //       alignment: Alignment.topCenter,
              //       image: MemoryImage(_recognitions),
              //       fit: BoxFit.fill),
              // ),
              child: Opacity(
                opacity: 0.3,
                child: Image.file(_image!),
              ),
            ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('TFLite Plugin example app'),
      ),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: predictImagePicker,
        tooltip: 'Pick Image',
        child: const Icon(Icons.image),
      ),
    );
  }
}
