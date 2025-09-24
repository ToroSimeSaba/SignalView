import SwiftUI
import Vision

struct DetectionOverlayView: View {
    @Binding var detectedObjects: [VNRecognizedObjectObservation]
    @Binding var signalColors: [(label: String, color: String)]
    
    var body: some View {
        // 検出枠とラベル
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            ForEach(detectedObjects.indices, id: \.self) { i in
                let obj = detectedObjects[i]
                let box = obj.boundingBox
                let x = box.midX * screenWidth
                let y = (1 - box.midY) * screenHeight

                if let label = obj.labels.first {
                    let base = JapaneseLabels.translate(label.identifier)
                    let color = signalColors.first(where: { $0.label == base })?.color
                    let translated = (color != nil) ? "\(base)（\(color!)）" : base

                    
                    let style = classStyles[translated] ?? classStyles["default"]!

                    // 枠線
                    Rectangle()
                        .stroke(style.color, lineWidth: style.lineWidth)
                        .frame(width: box.width * screenWidth,
                               height: box.height * screenHeight)
                        .position(x: x, y: y)

                    // ラベル
                    Text("\(translated) \(String(format: "%.2f", label.confidence))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(4)
                        .background(.yellow.opacity(0.7))
                        .cornerRadius(4)
                        .position(
                            x: x,
                            y: y - (box.height * screenHeight / 2) + CGFloat(15 + (i * 20))
                        )
                }
            }
        }
        
    }
}
