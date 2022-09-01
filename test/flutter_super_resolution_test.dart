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
}

void main() {
  final FlutterSuperResolutionPlatform initialPlatform = FlutterSuperResolutionPlatform.instance;

  test('$MethodChannelFlutterSuperResolution is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSuperResolution>());
  });

  test('getPlatformVersion', () async {
    FlutterSuperResolution flutterSuperResolutionPlugin = FlutterSuperResolution();
    MockFlutterSuperResolutionPlatform fakePlatform = MockFlutterSuperResolutionPlatform();
    FlutterSuperResolutionPlatform.instance = fakePlatform;

    expect(await flutterSuperResolutionPlugin.getPlatformVersion(), '42');
  });
}
