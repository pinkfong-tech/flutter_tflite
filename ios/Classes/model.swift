//
//  model.swift
//  flutter_super_resolution
//
//  Created by JaeUng Hyun on 2022/09/26.
//

import Flutter
import CoreImage
import UIKit
import TensorFlowLite

class Model {
    private var interpreter: Interpreter
    private var inputImageWidth: Int
    private var inputImageHeight: Int
    
    
    static func newInstance(args: NSDictionary, completion: @escaping ((Result<Model>) -> ())) {
        var options = Interpreter.Options()
        options.threadCount = args["num_threads"] as? Int
    }
    
    
    
    init(interpreter: Interpreter, inputImageWidth: Int, inputImageHeight: Int) {
        self.interpreter = interpreter
        self.inputImageWidth = inputImageWidth
        self.inputImageHeight = inputImageHeight
    }
}


/// Convenient enum to return result with a callback
enum Result<T> {
  case success(T)
  case error(Error)
}

/// Define errors that could happen in the initialization of this class
enum InitializationError: Error {
  // Invalid TF Lite model
  case invalidModel(String)
  // TF Lite Internal Error when initializing
  case internalError(Error)
}

/// Define errors that could happen in when doing image clasification
enum ClassificationError: Error {
  // Invalid input image
  case invalidImage
  // TF Lite Internal Error when initializing
  case internalError(Error)
}

// MARK: - Constants
private enum Constant {
  /// Specify the TF Lite model file
  static let modelFilename = "mnist"
  static let modelFileExtension = "tflite"
}
