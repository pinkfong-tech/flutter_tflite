import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlutterSuperResolution {
  static const MethodChannel _channel = const MethodChannel('tflite');
  Future<void> setupModel({
    required String model,
    String labels = "",
    int numThreads = 1,
    bool isAsset = true,
    String accelerator = "cpu",
  }) {
    return _channel.invokeMethod('setupModel', {
      model: model,
      labels: labels,
      numThreads: numThreads,
      isAsset: isAsset,
      accelerator: accelerator,
    });
  }

  // Future<List?> runModel(
  //     {required Uint8List binary, double threshold = 0.1, bool asynch = true}) {
  //   return FlutterSuperResolutionPlatform.instance.runModel(
  //     binary: binary,
  //     threshold: threshold,
  //     asynch: asynch,
  //   );
  // }

  // Future<List?> runModelOnFrame(
  //     {required Uint8List binary, double threshold = 0.1, bool asynch = true}) {
  //   return FlutterSuperResolutionPlatform.instance.runModelOnFrame(
  //     binary: binary,
  //     threshold: threshold,
  //     asynch: asynch,
  //   );
  // }

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

  Future<List?> detectObjectOnFrame({
    required List<Uint8List> bytesList,
    String model = "SSDMobileNet",
    int imageHeight = 1280,
    int imageWidth = 720,
    double imageMean = 127.5,
    double imageStd = 127.5,
    double threshold = 0.1,
    int numResultsPerClass = 1,
    int rotation = 90, // Android only
    // Used in YOLO only
    List anchors = anchors,
    int blockSize = 32,
    int numBoxesPerBlock = 5,
    bool asynch = true,
  }) {
    return _channel.invokeMethod('runModel', {
      bytesList: bytesList,
      model: model,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      imageMean: imageMean,
      imageStd: imageStd,
      threshold: threshold,
      numResultsPerClass: numResultsPerClass,
      rotation: rotation,
      anchors: anchors,
      blockSize: blockSize,
      numBoxesPerBlock: numBoxesPerBlock,
      asynch: asynch,
    });
  }
}
