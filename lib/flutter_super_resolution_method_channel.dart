import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_super_resolution_platform_interface.dart';

/// An implementation of [FlutterSuperResolutionPlatform] that uses method channels.
class MethodChannelFlutterSuperResolution
    extends FlutterSuperResolutionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_tflite');

  @override
  Future<void> setupModel(
      {required String model,
      String labels = "",
      int numThreads = 2,
      bool isAsset = true,
      String accelerator = "cpu"}) async {
    await methodChannel.invokeMethod('setupModel', {
      "model": model,
      "labels": labels,
      "numThreads": numThreads,
      "isAsset": isAsset,
      'accelerator': accelerator
    });
  }

  @override
  Future<List?> runModel(
      {required Uint8List binary,
      double threshold = 0.1,
      bool asynch = true}) async {
    return await methodChannel.invokeMethod('runModel', {
      "binary": binary,
      "threshold": threshold,
      "asynch": asynch,
    });
  }

  @override
  Future<List?> runModelOnFrame(
      {required Uint8List binary,
      double threshold = 0.1,
      bool asynch = true}) async {
    return await methodChannel.invokeMethod('runModelOnFrame', {
      "binary": binary,
      "threshold": threshold,
      "asynch": asynch,
    });
  }

  @override
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
    required List anchors,
    int blockSize = 32,
    int numBoxesPerBlock = 5,
    bool asynch = true,
  }) async {
    return await methodChannel.invokeMethod("detectObjectOnFrame", {
      "model": model,
      "imageHeight": imageHeight,
      "imageWidth": imageWidth,
      "imageMean": imageMean,
      "imageStd": imageStd,
      "threshold": threshold,
      "numResultsPerClass": numResultsPerClass,
      "rotation": rotation,
      "anchors": anchors,
      "blockSize": blockSize,
      "numBoxesPerBlock": numBoxesPerBlock,
      "asynch": asynch,
    });
  }
}
