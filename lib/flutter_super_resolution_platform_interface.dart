import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_super_resolution_method_channel.dart';

abstract class FlutterSuperResolutionPlatform extends PlatformInterface {
  /// Constructs a FlutterSuperResolutionPlatform.
  FlutterSuperResolutionPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSuperResolutionPlatform _instance =
      MethodChannelFlutterSuperResolution();

  /// The default instance of [FlutterSuperResolutionPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSuperResolution].
  static FlutterSuperResolutionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSuperResolutionPlatform] when
  /// they register themselves.
  static set instance(FlutterSuperResolutionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> setupModel(
      {required String model,
      String labels = "",
      int numThreads = 1,
      bool isAsset = true,
      String accelerator = "cpu"}) {
    throw UnimplementedError('setupModel() has not been implemented.');
  }

  Future<List?> runModel(
      {required Uint8List binary, double threshold = 0.1, bool asynch = true}) {
    throw UnimplementedError('runModel() has not been implemented.');
  }

  Future<List?> runModelOnFrame(
      {required Uint8List binary, double threshold = 0.1, bool asynch = true}) {
    throw UnimplementedError('runModelOnFrame() has not been implemented.');
  }

  Future<List?> detectOnFrame({
    required bytesList,
    String model = "SSDMobileNet",
    int imageHeight = 1280,
    int imageWidth = 720,
    double imageMean = 127.5,
    double imageStd = 127.5,
    double threshold = 0.1,
    int numResultsPerClass = 1,
    int rotation = 90, // Android only
    required List anchors,
    int blockSize = 32,
    int numBoxesPerBlock = 5,
    bool asynch = true,
  }) {
    throw UnimplementedError('detectOnFrame() has not been implemented.');
  }

  Future<List?> detectObjectOnFrame(
      {required List<Uint8List> bytesList,
      required String model,
      required int imageHeight,
      required int imageWidth,
      required double imageMean,
      required double imageStd,
      required double threshold,
      required int numResultsPerClass,
      required int rotation,
      required List anchors,
      required int blockSize,
      required int numBoxesPerBlock,
      required bool asynch}) {
    throw UnimplementedError('detectObjectOnFrame() has not been implemented.');
  }
}
