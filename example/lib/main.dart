import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_super_resolution/flutter_super_resolution.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterSuperResolutionPlugin = FlutterSuperResolution();

  @override
  void initState() {
    super.initState();
    setupModel();
  }

  Future<void> setupModel() async {
    await _flutterSuperResolutionPlugin.setupModel(
      model: "assets/lite-model_esrgan-tf2_1.tflite",
      accelerator: "npu",
    );
  }

  Future<void> runModel() async {
    await _flutterSuperResolutionPlugin.runModel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                onPressed: () {
                  runModel();
                  setupModel();
                },
                child: const Text("Setup Model"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
