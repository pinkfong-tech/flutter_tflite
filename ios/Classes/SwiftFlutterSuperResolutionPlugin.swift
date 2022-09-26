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
            setupModel(args: call.arguments as! NSDictionary, result: result)
            break
        case "runModel":
            runModel(args: call.arguments as! NSDictionary, result: result)
            break
        default:
            return
        }
    }
    
    func setupModel( args: NSDictionary, result: FlutterResult) {
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
        
        print(graph_path)
        print(options)
        
//        DispatchQueue.global(qos: .background).async{
//            guard let interpreter = try? Interpreter(modelPath: graph_path, options: options, delegates: delegates) else {
//                print("not init interpreter")
//                return
//            }
//
//            self.interpreter = interpreter
//        }
        
        self.interpreter = try? Interpreter(modelPath: graph_path, options: options, delegates: delegates)
//        self.interpreter = interpreter
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
    
    
    func runModel(args: NSDictionary, result: FlutterResult) {
        let data = args["bytesList"] as! NSArray
        guard let bytes = data[0] as? FlutterStandardTypedData else {
            return result(FlutterError.init())
        }
        
        let image = UIImage(data: bytes.data)
        
        DispatchQueue.global(qos: .background).async{
            let outputTensor: Tensor
            
            do {
                try self.interpreter.allocateTensors()
                let inputShape = try self.interpreter.input(at: 0).shape
                let inputWidth = inputShape.dimensions[1]
                let inputHeight = inputShape.dimensions[2]
                
                guard let rgbData = image?.scaledData(with: CGSize(width: inputWidth, height: inputHeight))
                else {
                    print("Failed to convert the image buffer to RGB data.")
                    return
                }
                
                try self.interpreter?.copy(rgbData, toInputAt: 0)
                try self.interpreter?.invoke()
                
                outputTensor = try self.interpreter.output(at: 0)
                
                
            } catch let error {
                print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
                return
            }
            let results = outputTensor.data.toArray(type: Float32.self)
            self.result = results
            let maxConfidence = results.max() ?? -1
            let maxIndex = results.firstIndex(of: maxConfidence) ?? -1
            let humanReadableResult = "Predicted: \(maxIndex)\nConfidence: \(maxConfidence)"
            
        }
        print(self.result)
        result(self.result)
    }
    
    //    func feedInputTensorBinary(typedData: FlutterStandardTypedData, input_size: Int) {
    //        var in_data:[NSData] = []
    //
    //
    //    }
    
    func detectObjectOnFrame(arguments: NSDictionary, result: FlutterResult) {
        
        let bytesList = arguments["bytesList"] as! FlutterStandardTypedData
        let bytes = Data(bytesList.data)
        let Uint8bytes = bytes.toArray(type: UInt8.self)
        
        let image_height = arguments["imageHeight"] as! Int
        let image_width = arguments["imageWidth"] as! Int
        let input_mean = arguments["imageMean"] as! Float
        let input_std = arguments["imageStd"] as! Float
        let threshold = arguments["threshold"] as! Float
        let num_results_per_class = arguments["numResultsPerClass"] as! Int
        
        let anchors = arguments["anchors"] as! NSArray
        let num_boxes_per_block = arguments["numBoxesPerBlock"] as! Int
        let block_size = arguments["blockSize"] as! Float
        
        let image_channels: Int = 4
        
        feedInputTensorFrame(typeddata: Uint8bytes, image_height: image_height, image_width: image_width, image_channels: image_channels, input_mean: input_mean, input_std: input_std)
        
    }
    
    func feedInputTensor() {
        
    }
    
    
    func feedInputTensorFrame(typeddata: [UInt8], image_height: Int, image_width: Int, image_channels: Int, input_mean: Float, input_std: Float) {
        
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

