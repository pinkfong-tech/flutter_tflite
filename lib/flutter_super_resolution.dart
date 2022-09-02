import 'flutter_super_resolution_platform_interface.dart';

class FlutterSuperResolution {
  Future<void> setupModel({
    required String model,
    String labels = "",
    int numThreads = 1,
    bool isAsset = true,
    bool useGpuDelegate = false,
  }) {
    return FlutterSuperResolutionPlatform.instance.setupModel(
        model: model,
        labels: labels,
        numThreads: numThreads,
        isAsset: isAsset,
        useGpuDelegate: useGpuDelegate);
  }

  Future<void> runModel() {
    return FlutterSuperResolutionPlatform.instance.runModel();
  }
}
