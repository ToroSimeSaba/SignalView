import UIKit

/// 🔹信号機画像の平均色から赤・青を判定
func detectTrafficLightColor(from image: UIImage) -> String {
    guard let cgImage = image.cgImage else { return "不明" }
    let ciImage = CIImage(cgImage: cgImage)
    let context = CIContext(options: nil)

    // 1x1に縮小して平均色を取得
    let extent = ciImage.extent
    let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
    guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: inputExtent]),
          let outputImage = filter.outputImage,
          let bitmap = context.createCGImage(outputImage, from: CGRect(x: 0, y: 0, width: 1, height: 1)) else {
        return "不明"
    }

    var pixel = [UInt8](repeating: 0, count: 4)
    let context2 = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    context2?.draw(bitmap, in: CGRect(x: 0, y: 0, width: 1, height: 1))

    let r = CGFloat(pixel[0]) / 255.0
    let g = CGFloat(pixel[1]) / 255.0
    let b = CGFloat(pixel[2]) / 255.0

    // 🔹単純な色判定
    if r > g && r > b && r > 0.4 {
        return "赤、赤"
    } else if b > r && b > g {
        return "青"
    } else if g > r && g > b {
        return "青" // 歩行者信号は青っぽい緑が多いので「青」として扱う
    }
    return "不明"
}
