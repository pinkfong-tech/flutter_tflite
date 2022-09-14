import Flutter
import UIKit
import TensorFlowLite
import Accelerate
import CoreImage


public class SwiftFlutterSuperResolutionPlugin: NSObject, FlutterPlugin {
    private var interpreter: Interpreter!
    private var label_string: [Any] = []
    private var interpreter_busy = false
    private var result: Array<Any> = []
    
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
            
            label_string = LoadLabel(label_path: label_path)
            print(label_string)
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
        
        DispatchQueue.global(qos: .background).async{
            guard let interpreter = try? Interpreter(modelPath: graph_path, options: options, delegates: delegates) else {
                return
            }
            self.interpreter = interpreter
        }
    }
    
    func LoadLabel(label_path: String) -> [Any] {
        var label_string = [Any]()
        if label_path.isEmpty {
            print("Failed to find label file at \(label_path)")
        }
        let contents = try! String(contentsOfFile: label_path)
        let lines = contents.split(separator: "\n")
        
        for line in lines {
            label_string.append(line)
        }
        
        return label_string
        
    }
    
    
    func runModel(image: UIImage, completion: @escaping ( (Result<String>) -> ())) {
        DispatchQueue.global(qos: .background).async{
            let outputTensor: Tensor
            
            do {
                try self.interpreter.allocateTensors()
                let inputShape = try self.interpreter.input(at: 0).shape
                let inputWidth = inputShape.dimensions[1]
                let inputHeight = inputShape.dimensions[2]
                
                guard let rgbData = image.scaledData(with: CGSize(width: inputWidth, height: inputHeight))
                else {
                    DispatchQueue.main.async {
                        completion(.error(ClassificationError.invalidImage))
                    }
                    print("Failed to convert the image buffer to RGB data.")
                    return
                }
                
                try self.interpreter.copy(rgbData, toInputAt: 0)
                try self.interpreter.invoke()
                
                outputTensor = try self.interpreter.output(at: 0)
                
                
            } catch let error {
                print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.error(ClassificationError.internalError(error)))
                }
                return
            }
            let results = outputTensor.data.toArray(type: Float32.self)
            self.result = results
            let maxConfidence = results.max() ?? -1
            let maxIndex = results.firstIndex(of: maxConfidence) ?? -1
            let humanReadableResult = "Predicted: \(maxIndex)\nConfidence: \(maxConfidence)"
            
            DispatchQueue.main.async {
                completion(.success(humanReadableResult))
            }
        }
    }
    
}

enum Result<T> {
    case success(T)
    case error(Error)
}

enum ClassificationError: Error {
    // Invalid input image
    case invalidImage
    // TF Lite Internal Error when initializing
    case internalError(Error)
}

