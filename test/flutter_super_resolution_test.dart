import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_super_resolution/flutter_super_resolution.dart';
import 'package:flutter_super_resolution/flutter_super_resolution_platform_interface.dart';
import 'package:flutter_super_resolution/flutter_super_resolution_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSuperResolutionPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSuperResolutionPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
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
    // TODO: implement detectObjectOnFrame
    throw UnimplementedError();
  }

  @override
  Future<List?> detectOnFrame(
      {required bytesList,
      String model = "SSDMobileNet",
      int imageHeight = 1280,
      int imageWidth = 720,
      double imageMean = 127.5,
      double imageStd = 127.5,
      double threshold = 0.1,
      int numResultsPerClass = 1,
      int rotation = 90,
      required List anchors,
      int blockSize = 32,
      int numBoxesPerBlock = 5,
      bool asynch = true}) {
    // TODO: implement detectOnFrame
    throw UnimplementedError();
  }

  @override
  Future<List?> runModel(
      {required Uint8List binary, double threshold = 0.1, bool asynch = true}) {
    // TODO: implement runModel
    throw UnimplementedError();
  }

  @override
  Future<List?> runModelOnFrame(
      {required Uint8List binary, double threshold = 0.1, bool asynch = true}) {
    // TODO: implement runModelOnFrame
    throw UnimplementedError();
  }

  @override
  Future<void> setupModel(
      {required String model,
      String labels = "",
      int numThreads = 1,
      bool isAsset = true,
      String accelerator = "cpu"}) {
    // TODO: implement setupModel
    throw UnimplementedError();
  }
}

void main() {
  final FlutterSuperResolutionPlatform initialPlatform =
      FlutterSuperResolutionPlatform.instance;

  test('$MethodChannelFlutterSuperResolution is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelFlutterSuperResolution>());
  });

  test('getPlatformVersion', () async {
    FlutterSuperResolution flutterSuperResolutionPlugin =
        FlutterSuperResolution();
    MockFlutterSuperResolutionPlatform fakePlatform =
        MockFlutterSuperResolutionPlatform();
    FlutterSuperResolutionPlatform.instance = fakePlatform;
  });
}
