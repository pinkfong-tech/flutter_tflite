package com.example.flutter_super_resolution

import android.content.res.AssetFileDescriptor
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.gpu.GpuDelegate
import org.tensorflow.lite.nnapi.NnApiDelegate;
import java.io.File
import java.io.FileInputStream
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel


/** FlutterSuperResolutionPlugin */
class FlutterSuperResolutionPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var interpreter: Interpreter
  private lateinit var binding: FlutterPlugin.FlutterPluginBinding

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_super_resolution")
    channel.setMethodCallHandler(this)
    binding = flutterPluginBinding
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "setupModel" -> {
        val args: HashMap<String, *> = call.arguments as HashMap<String, *>
        setupModel(result, args)
      }
    }
  }

  private fun setupModel(result: Result, args: HashMap<String, *>) {
    val model: String = args["model"].toString()
    val isAssetObj = args["isAsset"]
    val isAsset = if (isAssetObj == null) false else isAssetObj as Boolean
    val key: String
    val buffer: MappedByteBuffer


    if (isAsset) {
      key = binding.flutterAssets.getAssetFilePathBySubpath(model)
      val fileDescriptor: AssetFileDescriptor = binding.applicationContext.assets.openFd(key)
      val inputStream: FileInputStream = FileInputStream(fileDescriptor.fileDescriptor)
      val fileChannel: FileChannel = inputStream.channel
      val startOffset: Long = fileDescriptor.startOffset
      val declaredLength = fileDescriptor.declaredLength
      buffer = fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
    } else {
      val inputStream: FileInputStream = FileInputStream(File(model))
      val fileChannel: FileChannel = inputStream.channel
      val declaredLength = fileChannel.size()
      buffer = fileChannel.map(FileChannel.MapMode.READ_ONLY, 0, declaredLength)
    }

    val numThread = args["numThreads"]
    val tfliteOptions = Interpreter.Options()
    when (args["accelerator"] as String) {
      "cpu" -> { }
      "gpu" -> {
        val delegate = GpuDelegate()
        tfliteOptions.addDelegate(delegate)
      }
      "npu" -> {
        val delegate = NnApiDelegate()
        tfliteOptions.addDelegate(delegate)
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)

  }
}
