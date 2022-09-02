import Flutter
import UIKit
import TensorFlowLite
import Accelerate
import CoreImage


public class SwiftFlutterSuperResolutionPlugin: NSObject, FlutterPlugin {
    private var interpreter: Interpreter!
    var registrar: FlutterPluginRegistrar? = nil
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_tflite", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterSuperResolutionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.registrar = registrar
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method{
        case "setupModel":
            setupModel(result: result, args: call.arguments as! NSDictionary)
            break
        case "runModel":
            
            break
        default:
            return
        }
    }
    
    func setupModel(result: FlutterResult, args: NSDictionary) {
        var graph_path: String
        var key: String
        
        if (args["isAsset"] as! Bool) {
            key = (registrar?.lookupKey(forAsset: args["model"] as! String))!
            graph_path = Bundle.main.path(forResource: key, ofType: nil)!
        } else {
            graph_path = args["model"] as! String
        }
        
        let num_threads: Int = args["numThreads"] as! Int
        
        var options = Interpreter.Options()
        options.threadCount = num_threads
        
        
        let accelator: String = args["accelator"] as? String ?? "cpu"
        
        
        var delegates: [Delegate]
        
        switch accelator {
        case "cpu":
            delegates = []
        case "gpu":
            delegates = [MetalDelegate()]
        case "npu":
            if let delegate = CoreMLDelegate() {
                delegates = [delegate]
            } else {
                delegates = [MetalDelegate()]
                print("not support Neural Engine. Using Metal api")
            }
        default:
            delegates = []
        }
        
        DispatchQueue.global().async{
            guard let interpreter = try? Interpreter(modelPath: graph_path, options: options, delegates: delegates) else {
                return
            }
            self.interpreter = interpreter
        }
        
        result("Success")
    }
    
    func runModel(pixelBuffer: CVPixelBuffer) {
        
    }
    
}
