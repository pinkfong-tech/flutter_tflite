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
    await methodChannel.invokeMethod('runModel');
    return null;
  }

  @override
  Future<List?> runModelOnFrame(
      {required Uint8List binary,
      double threshold = 0.1,
      bool asynch = true}) async {
    await methodChannel.invokeMethod('runModelOnFrame');
    return null;
  }
}
