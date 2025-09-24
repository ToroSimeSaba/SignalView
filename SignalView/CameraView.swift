import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewRepresentable {
    @Binding var detectedObjects: [VNRecognizedObjectObservation]
    @Binding var currentFrameImage: UIImage?
    
    func makeUIView(context: Context) -> PreviewView {
        let preview = PreviewView()
        context.coordinator.startCameraSession(on: preview)
        return preview
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        private var model: VNCoreMLModel!
        private var request: VNCoreMLRequest!
        private var session: AVCaptureSession?

        init(_ parent: CameraView) {
            self.parent = parent
            super.init()
            setupModel()
        }

        func setupModel() {
            guard let modelURL = Bundle.main.url(forResource: "yolo11s", withExtension: "mlmodelc"),
                  let coreMLModel = try? MLModel(contentsOf: modelURL) else { return }
            model = try? VNCoreMLModel(for: coreMLModel)
            request = VNCoreMLRequest(model: model) { [weak self] request, _ in
                self?.processDetections(for: request)
            }
        }

        func startCameraSession(on view: PreviewView) {
            session = AVCaptureSession()
            guard let session = session else { return }
            
            session.sessionPreset = .high
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else { return }
            session.addInput(input)

            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
            session.addOutput(output)

            view.videoPreviewLayer.session = session
            view.videoPreviewLayer.videoGravity = .resizeAspectFill

                DispatchQueue.global(qos: .userInitiated).async {
                    session.startRunning()
                }
            
            
        }
        private var lastInferenceTime: Date = Date()
        private let inferenceQueue = DispatchQueue(label: "inferenceQueue")

        func captureOutput(_ output: AVCaptureOutput,
                           didOutput sampleBuffer: CMSampleBuffer,
                           from connection: AVCaptureConnection) {
            
            let currentTime = Date()
            if currentTime.timeIntervalSince(lastInferenceTime) < 0.1 {
                return // ✅ 0.1秒経過するまではスキップ
            }
            lastInferenceTime = currentTime
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            inferenceQueue.async { [weak self] in
                guard let self = self else { return }
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                try? handler.perform([request])
                
                if let uiImage = pixelBuffer.toUIImage() {
                    DispatchQueue.main.async {
                        self.parent.currentFrameImage = uiImage
                    }
                }
            }
        }
        func processDetections(for request: VNRequest) {
            if let results = request.results as? [VNRecognizedObjectObservation] {
                DispatchQueue.main.async {
                    self.parent.detectedObjects = results
                }
            }
        }
        func stopCameraSession() {
            session?.stopRunning()
            session = nil
        }
    }
}

/// ✅ カメラプレビュー専用UIView
class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
    }
}

extension CVPixelBuffer {
    func toUIImage() -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: self)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
