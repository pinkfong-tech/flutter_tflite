import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_super_resolution/flutter_super_resolution.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

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
  @override
  void initState() {
    super.initState();
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

  Future recognizeImageBinary(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var imageBytes = (await rootBundle.load(image.path)).buffer;
    img.Image oriImage = img.decodeImage(imageBytes.asUint8List())!;
    img.Image resizedImage = img.copyResize(oriImage, height: 224, width: 224);
    var recognitions = await _flutterSuperResolutionPlugin.runModel(
      binary: imageToByteListFloat32(resizedImage, 224, 127.5, 127.5),
      threshold: 0.05,
    );
    setState(() {
      _recognitions = recognitions!;
    });
    int endTime = DateTime.now().millisecondsSinceEpoch;
    logger.d("Inference took ${endTime - startTime}ms");
  }

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
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
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null
          ? const Text("No image selected.")
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    alignment: Alignment.topCenter,
                    image: MemoryImage(_recognitions as Uint8List),
                    fit: BoxFit.fill),
              ),
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
