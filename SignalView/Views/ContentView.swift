import SwiftUI
import Vision
import AVFoundation

struct ContentView: View {
    @State  var currentFrameImage: UIImage? = nil
    @State  var zoomedImages: [UIImage] = []
    @State  var lastUpdateTime: Date = Date()
    @State  var detectedObjects: [VNRecognizedObjectObservation] = []
    @State  var signalColors: [(label: String, color: String)] = []
    @State  var lastSpokenColors: [String] = []
    @State var lastSpeechTime:Date = Date()
    @State  var recentSignalColors: [String] = [] // 直近フレームの色履歴
    @State  var lastDetectedColor: String = ""  // 最後に確定した色
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            // カメラ映像
            CameraView(detectedObjects: $detectedObjects, currentFrameImage: $currentFrameImage)
                .edgesIgnoringSafeArea(.all)
            // 検出オーバーレイ（サブViewに分割）
            DetectionOverlayView(
                detectedObjects: $detectedObjects,
                signalColors: $signalColors
            )
            
            // ✅ 拡大表示（右下に最大3つ並べる）
            if !zoomedImages.isEmpty {
                ZoomedImagesView(zoomedImages: zoomedImages)
            }
            
            // ✅ 画面下に信号機色ラベルを表示
            VStack {
                Spacer()
                SignalColorsView(signalColors: $signalColors, speak: speak )
            }
            // ✅ View構築外でzoomedImagesを更新
            .onChange(of: detectedObjects) {
                updateZoomedImages(objects: detectedObjects)
            }
        }
    }
}

