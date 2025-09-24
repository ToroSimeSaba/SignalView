import SwiftUI
import Vision
import AVFoundation

extension ContentView {
    /// 🔹信号機があれば最大3つ切り出してzoomedImagesにセット（2秒で消去）
    func updateZoomedImages(objects: [VNRecognizedObjectObservation]) {
        var newImages: [UIImage] = []
        var newSignalColors: [(label: String, color: String)] = []
        let maxHistoryCount = 10 // 直近10フレームで投票
        
        for obj in objects {
            if let label = obj.labels.first {
                let translated = JapaneseLabels.translate(label.identifier)
                if translated == "信号機",
                   let frame = currentFrameImage ,
                   let cropped = cropImage(originalImage: frame, boundingBox: obj.boundingBox) {
                    
                    // ✅ 色判定
                    let color = detectTrafficLightColor(from: cropped)
                    print("信号機色判定: \(color)")
                  
                    // ✅ 履歴更新
                    recentSignalColors.append(color)
                    if recentSignalColors.count > maxHistoryCount {
                        recentSignalColors.removeFirst()
                    }
                    
                    // ✅ 配列に追加
                    newSignalColors.append((label: translated, color: color))
                    
                    newImages.append(cropped)
                    if newImages.count >= 3 { break } // 最大3つ
                }
            }
        }
        
        // ✅ 投票による最終判断
        if !recentSignalColors.isEmpty {
            let mostCommonColor = recentSignalColors
                .reduce(into: [:]) { counts, c in counts[c, default: 0] += 1 }
                .max { $0.value < $1.value }?.key ?? ""
            
            // ✅ 切り替わり時のみ履歴リセット＋読み上げ
            if mostCommonColor != lastDetectedColor && mostCommonColor != "" {
                lastDetectedColor = mostCommonColor
                recentSignalColors = [mostCommonColor] // 新しい色が優勢になったので履歴リセット
                speak("信号機は、 \(mostCommonColor) です")
            }
        }
        
        // ✅ 新しい色ラベルを更新
        signalColors = newSignalColors
        
        if !newImages.isEmpty {
            zoomedImages = newImages
            signalColors = newSignalColors
            lastUpdateTime = Date()
            
            // ✅ 🔹「変化した色のみ読み上げる」
            let newColorsOnly = newSignalColors.map { $0.color }
            if newColorsOnly != lastSpokenColors { // 変化があれば
                if let latest = newSignalColors.first {
                    speak("信号機は \(latest.color) です")
                }
                lastSpokenColors = newColorsOnly
            }
            
            // ✅ 3秒後に「最後の更新から3秒経過しているか」を確認
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if Date().timeIntervalSince(lastUpdateTime) >= 3 {
                    zoomedImages = []
                    signalColors = []
//                    lastSpokenColors = []
                }
            }
        } else {
            // ✅ 検出がなくても、前回の更新から3秒経過するまでは残す
            if Date().timeIntervalSince(lastUpdateTime) >= 3 {
                zoomedImages = []
                signalColors = []
//                lastSpokenColors = []
            }
        }
    }
    
    // 読み上げ
    func speak(_ text: String) {
        if Date().timeIntervalSince(lastSpeechTime) < 2 { return } // 1秒以内は無視
        lastSpeechTime = Date()
        // ✅ すでに読み上げ中なら即座に停止
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.75  // ✅ 読み上げ速度（0.0〜1.0）
        speechSynthesizer.speak(utterance)
    }
}
