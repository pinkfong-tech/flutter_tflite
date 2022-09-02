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
      int numThreads = 1,
      bool isAsset = true,
      bool useGpuDelegate = false}) async {
    await methodChannel.invokeMethod('setupModel', {
      "model": model,
      "labels": labels,
      "numThreads": numThreads,
      "isAsset": isAsset,
      'useGpuDelegate': useGpuDelegate
    });
  }

  @override
  Future<void> runModel() async {
    await methodChannel.invokeMethod('runModel');
  }
}
