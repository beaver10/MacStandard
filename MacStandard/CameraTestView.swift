import SwiftUI
import AVFoundation

struct CameraTestView: View {
    @Binding var isPassed: Bool
    @Binding var result: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            VStack(spacing: 8) {
                Text("카메라 테스트")
                    .font(.system(size: 18, weight: .semibold))
                Text("카메라 화질과 색감을 확인해주세요")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(20)

            Divider()

            // 카메라 미리보기
            CameraPreview()
                .frame(height: 300)
                .background(Color.black)

            Divider()

            // 체크리스트
            VStack(alignment: .leading, spacing: 10) {
                Text("확인 항목")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                CheckItem(text: "화면이 선명하게 보이나요?")
                CheckItem(text: "색감이 자연스럽나요?")
                CheckItem(text: "화면이 좌우 반전되어 있나요? (정상)")
                CheckItem(text: "이미지가 끊기지 않고 부드럽나요?")
            }
            .padding(20)

            Divider()

            HStack(spacing: 12) {
                Button("건너뛰기") {
                    isPassed = false
                    result = "테스트 건너뜀"
                    dismiss()
                }
                Spacer()
                Button("이상 있음") {
                    isPassed = false
                    result = "카메라 이상 발견"
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.red)

                Button("정상 ✓") {
                    isPassed = true
                    result = "카메라 정상"
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(20)
        }
        .frame(width: 600, height: 660)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct CheckItem: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green.opacity(0.7))
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }
}

struct CameraPreview: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor

        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return view
        }

        session.addInput(input)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer?.addSublayer(previewLayer)

        DispatchQueue.global().async {
            session.startRunning()
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let layer = nsView.layer?.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = nsView.bounds
        }
    }
}
