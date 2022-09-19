import 'package:flutter/foundation.dart';

import 'flutter_super_resolution_platform_interface.dart';

class FlutterSuperResolution {
  Future<void> setupModel({
    required String model,
    String labels = "",
    int numThreads = 1,
    bool isAsset = true,
    String accelerator = "cpu",
  }) {
    return FlutterSuperResolutionPlatform.instance.setupModel(
      model: model,
      labels: labels,
      numThreads: numThreads,
      isAsset: isAsset,
      accelerator: accelerator,
    );
  }

  Future<List?> runModel(
      {required Uint8List binary, double threshold = 0.1, bool asynch = true}) {
    return FlutterSuperResolutionPlatform.instance.runModel(
      binary: binary,
      threshold: threshold,
      asynch: asynch,
    );
  }

  Future<List?> runModelOnFrame(
      {required Uint8List binary, double threshold = 0.1, bool asynch = true}) {
    return FlutterSuperResolutionPlatform.instance.runModelOnFrame(
      binary: binary,
      threshold: threshold,
      asynch: asynch,
    );
  }
}
