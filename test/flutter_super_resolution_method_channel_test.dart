import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_super_resolution/flutter_super_resolution_method_channel.dart';

void main() {
  MethodChannelFlutterSuperResolution platform = MethodChannelFlutterSuperResolution();
  const MethodChannel channel = MethodChannel('flutter_super_resolution');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
