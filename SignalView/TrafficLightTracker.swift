import SwiftUI
import Vision
import Combine

struct TrackedObject: Identifiable {
    let id: Int
    var bbox: CGRect
    var lastSeen: Date
    var stableCount: Int 
}
func iou(_ rect1: CGRect, _ rect2: CGRect) -> CGFloat {
    let intersection = rect1.intersection(rect2)
    if intersection.isNull { return 0 }
    let interArea = intersection.width * intersection.height
    let unionArea = rect1.width * rect1.height + rect2.width * rect2.height - interArea
    return interArea / unionArea
}

class TrafficLightTracker: ObservableObject {
    @Published var trackedTrafficLights: [TrackedObject] = []
    private var nextID = 0
    private let iouThreshold: CGFloat = 0.3 // 同じオブジェクトとみなす閾値
    
    func update(with detections: [VNRecognizedObjectObservation]) {
        let now = Date()
        let trafficLights = detections.filter { $0.labels.first?.identifier == "traffic light" }
        
        for detection in trafficLights {
            let bbox = detection.boundingBox
            if let index = trackedTrafficLights.firstIndex(where: {
                iou($0.bbox, bbox) > iouThreshold
            }) {
                trackedTrafficLights[index].bbox = bbox
                trackedTrafficLights[index].lastSeen = now
                trackedTrafficLights[index].stableCount += 1
            } else {
                trackedTrafficLights.append(
                    TrackedObject(id: nextID, bbox: bbox, lastSeen: now, stableCount: 1)
                )
                nextID += 1
            }
        }
        trackedTrafficLights.removeAll { now.timeIntervalSince($0.lastSeen) > 1.0 }
    }
}
