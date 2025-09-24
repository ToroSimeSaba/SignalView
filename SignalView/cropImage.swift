import UIKit

func cropImage(originalImage: UIImage, boundingBox: CGRect) -> UIImage? {
    let width = originalImage.size.width
    let height = originalImage.size.height
    
    // YOLO座標系をUIImage座標に変換
    let rect = CGRect(
        x: boundingBox.origin.x * width,
        y: (1 - boundingBox.origin.y - boundingBox.size.height) * height,
        width: boundingBox.size.width * width,
        height: boundingBox.size.height * height
    )
    
    if let cgImage = originalImage.cgImage?.cropping(to: rect) {
        return UIImage(cgImage: cgImage)
    }
    return nil
}
