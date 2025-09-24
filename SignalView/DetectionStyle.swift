import SwiftUI

struct DetectionStyle {
    var color: Color
    var lineWidth: CGFloat
}

let classStyles: [String: DetectionStyle] = [
    "人": DetectionStyle(color: .red, lineWidth: 4),
    "犬": DetectionStyle(color: .blue, lineWidth: 3),
    "猫": DetectionStyle(color: .green, lineWidth: 3),
    "信号機": DetectionStyle(color: .yellow, lineWidth: 5),
    "default": DetectionStyle(color: .white, lineWidth: 2)
]
