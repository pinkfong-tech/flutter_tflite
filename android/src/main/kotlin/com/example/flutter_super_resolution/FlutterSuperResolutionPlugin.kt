package com.example.flutter_super_resolution


import android.content.res.AssetFileDescriptor
import android.content.res.AssetManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.gpu.GpuDelegate
import org.tensorflow.lite.gpu.CompatibilityList
import org.tensorflow.lite.nnapi.NnApiDelegate
import org.tensorflow.lite.nnapi.NnApiDelegateImpl
import java.io.*
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel
import java.util.*


/** FlutterSuperResolutionPlugin */
class FlutterSuperResolutionPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var tflite: Interpreter
  private lateinit var binding: FlutterPlugin.FlutterPluginBinding
  private var labelProb =  emptyArray<Float>()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_tflite")
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

  private fun setupModel(result: Result, args: HashMap<String, *>): String {
    val model: String = args["model"].toString()
    val isAssetObj = args["isAsset"]
    val isAsset = if (isAssetObj == null) false else isAssetObj as Boolean
    var key: String
    val buffer: MappedByteBuffer
    var assetManager: AssetManager? = null


    if (isAsset) {
      assetManager = binding.applicationContext.assets
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

    val numThread: Int = args["numThreads"] as Int
    val tfliteOption = selectDelegate(args["accelerator"] as String)
    tfliteOption.numThreads = numThread

    tflite = Interpreter(buffer, tfliteOption)

    val label: String = args["labels"].toString()

    if (label.isNotEmpty()) {
      if (isAsset) {
        key = binding.flutterAssets.getAssetFilePathBySubpath(label)
        if (assetManager != null) {
          loadLabels(assetManager, key)
        }
      } else {
        loadLabels(null, label)
      }
    }
    result.success("Success")
    return "success"
  }

  private fun selectDelegate(accelerator: String): Interpreter.Options {
    val tfliteOptions = Interpreter.Options()
    when (accelerator) {
      "cpu" -> { }
      "gpu" -> {
        val compatList = CompatibilityList()
        if (compatList.isDelegateSupportedOnThisDevice) {
          val delegate = GpuDelegate()
          tfliteOptions.addDelegate(delegate)
        }
      }
      "npu" -> {
        try {
          val delegate = NnApiDelegate()
          tfliteOptions.addDelegate(delegate)
        }  catch (e: java.lang.RuntimeException) {
          val compatList = CompatibilityList()
          if (compatList.isDelegateSupportedOnThisDevice) {
            val delegate = GpuDelegate()
            tfliteOptions.addDelegate(delegate)
          }
        }
      }
    }
    return tfliteOptions
  }


  private fun loadLabels(assetManager: AssetManager?, labelPath: String) {
    var br: BufferedReader
    try {
      if (assetManager != null) {
        br = BufferedReader(InputStreamReader(assetManager.open(labelPath)))
      } else {
        br = BufferedReader(InputStreamReader(FileInputStream(File(labelPath))))
      }
      var line: String
      val labels = Vector<Any>()

      while ( (br.readLine().also { line = it }) != null) {
        labels.add(line)
      }
      labelProb = Array(1) { labels.size as Float }
      br.close()
    } catch (e: IOException) {
      throw RuntimeException("Failed to read label file", e)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)

  }
}
