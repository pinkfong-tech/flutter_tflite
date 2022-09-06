//
//  TFLiteExtensions.swift
//  flutter_super_resolution
//
//  Created by JaeUng Hyun on 2022/09/06.
//

import CoreGraphics
import Foundation
import UIKit

// MARK: - UIImage
extension UIImage {

  /// Returns the data representation of the image after scaling to the given `size` and converting
  /// to grayscale.
  ///
  /// - Parameters
  ///   - size: Size to scale the image to (i.e. image size used while training the model).
  /// - Returns: The scaled image as data or `nil` if the image could not be scaled.
  public func scaledData(with size: CGSize) -> Data? {
    guard let cgImage = self.cgImage, cgImage.width > 0, cgImage.height > 0 else { return nil }

    let bitmapInfo = CGBitmapInfo(
      rawValue: CGImageAlphaInfo.none.rawValue
    )
    let width = Int(size.width)
    guard let context = CGContext(
      data: nil,
      width: width,
      height: Int(size.height),
      bitsPerComponent: cgImage.bitsPerComponent,
      bytesPerRow: width * 1,
      space: CGColorSpaceCreateDeviceGray(),
      bitmapInfo: bitmapInfo.rawValue)
      else {
        return nil
    }
    context.draw(cgImage, in: CGRect(origin: .zero, size: size))
    guard let scaledBytes = context.makeImage()?.dataProvider?.data as Data? else { return nil }
    let scaledFloats = scaledBytes.map { Float32($0) / Constant.maxRGBValue }

    return Data(copyingBufferOf: scaledFloats)
  }

}

// MARK: - Data
extension Data {
  /// Creates a new buffer by copying the buffer pointer of the given array.
  ///
  /// - Warning: The given array's element type `T` must be trivial in that it can be copied bit
  ///     for bit with no indirection or reference-counting operations; otherwise, reinterpreting
  ///     data from the resulting buffer has undefined behavior.
  /// - Parameter array: An array with elements of type `T`.
  init<T>(copyingBufferOf array: [T]) {
    self = array.withUnsafeBufferPointer(Data.init)
  }

  func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
    var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
    _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
    return array
  }
}

// MARK: - Constants
private enum Constant {
  static let maxRGBValue: Float32 = 255.0
}
