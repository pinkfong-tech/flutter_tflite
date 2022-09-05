import Flutter
import UIKit
import TensorFlowLite
import Accelerate
import CoreImage


public class SwiftFlutterSuperResolutionPlugin: NSObject, FlutterPlugin {
    private var interpreter: Interpreter!
    private let label_string: [[Any]] = [[]]
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
        
        //      TFLite options
        var options = Interpreter.Options()
        options.threadCount = num_threads
        
        let accelerator: String = args["accelerator"] as? String ?? "cpu"
        
        
        createInterpreter(accelerator: accelerator, graph_path: graph_path, options: options)
        
        
        let labels = args["labels"] as! NSString
        
        if (labels.length > 0) {
            var label_path: String
            
            if (args["isAsset"] as! Bool) {
                key = (registrar?.lookupKey(forAsset: labels as String))!
                label_path = Bundle.main.path(forResource: key, ofType: nil)!
            } else {
                label_path = labels as String
            }
            
            LoadLabel(label_path: label_path)
        }
        result("Success")
    }
    
    func createInterpreter(accelerator: String, graph_path: String, options: Interpreter.Options ) {
        var delegates: [Delegate]
        
        switch accelerator {
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
    }
    
    func LoadLabel(label_path: String) -> [[Any]] {
        var label_string = [[Any]]()
        if label_path.isEmpty {
            print("Failed to find label file at \(label_path)")
        }
        let contents = try! String(contentsOfFile: label_path)
        let lines = contents.split(separator: "\n")
        
        for line in lines {
            label_string.append([line])
        }
        
        return label_string
        
    }
    
    
    func runModel(pixelBuffer: CVPixelBuffer) {
        
    }
    
}
