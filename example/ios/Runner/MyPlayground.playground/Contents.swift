import TensorFlowLite
import Flutter
import Foundation
import PlaygroundSupport
import TensorFlowLiteC


var result: Array<Any> = []

let labels = ["background",
             "tench",
             "goldfish",
             "great white shark",
             "tiger shark",
             "hammerhead",
             "electric ray",
             "stingray",
             "cock",
             "hen",
             "ostrich",
             "brambling",
             "goldfinch",
             "house finch",
             "junco",
             "indigo bunting",
             "robin",
             "bulbul",
             "jay",
             "magpie",
             "chickadee",
             "water ouzel",
             "kite",
             "bald eagle",
             "vulture"]

for label in labels {
    result.append(label)
}
print(result)

result.length

let tensor = Tensor(
  name: "input",
  dataType: Float16,
  shape: (512,512,3),
  data: data,
  quantizationParameters: quantizationParameters
)
