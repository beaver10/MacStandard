import SwiftUI
import AVFoundation

enum AudioChannel {
    case left, right
}

struct SpeakerTestView: View {
    @Binding var isPassed: Bool
    @Binding var result: String
    @Environment(\.dismiss) var dismiss

    @State private var step = 0 // 0: 왼쪽, 1: 오른쪽, 2: 완료
    @State private var leftPassed: Bool? = nil
    @State private var rightPassed: Bool? = nil
    @State private var isPlaying = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("스피커 테스트")
                .font(.system(size: 18, weight: .semibold))

            // 진행 표시
            HStack(spacing: 8) {
                stepDot(index: 0, label: "왼쪽")
                Rectangle()
                    .fill(step > 0 ? Color.green : Color.gray.opacity(0.3))
                    .frame(height: 1)
                stepDot(index: 1, label: "오른쪽")
            }
            .padding(.vertical, 8)

            if step == 0 {
                // 왼쪽 채널 테스트
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "speaker.wave.1.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("왼쪽 채널")
                                .font(.system(size: 18, weight: .medium))
                            Text("왼쪽 스피커에서 소리가 들리나요?")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }

                    Button {
                        playTone(channel: .left)
                    } label: {
                        HStack {
                            Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            Text(isPlaying ? "재생 중..." : "왼쪽 소리 재생")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isPlaying)

                    HStack(spacing: 12) {
                        Button {
                            leftPassed = false
                            step = 1
                        } label: {
                            Label("안 들려요", systemImage: "xmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)

                        Button {
                            leftPassed = true
                            step = 1
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                playTone(channel: .right)
                            }
                        } label: {
                            Label("잘 들려요", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
                .padding(20)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(14)

            } else if step == 1 {
                // 오른쪽 채널 테스트
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("오른쪽 채널")
                                .font(.system(size: 18, weight: .medium))
                            Text("오른쪽 스피커에서 소리가 들리나요?")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }

                    Button {
                        playTone(channel: .right)
                    } label: {
                        HStack {
                            Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            Text(isPlaying ? "재생 중..." : "오른쪽 소리 재생")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isPlaying)

                    HStack(spacing: 12) {
                        Button {
                            rightPassed = false
                            step = 2
                        } label: {
                            Label("안 들려요", systemImage: "xmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)

                        Button {
                            rightPassed = true
                            step = 2
                        } label: {
                            Label("잘 들려요", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
                .padding(20)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(14)

            } else {
                // 완료
                VStack(spacing: 12) {
                    Image(systemName: (leftPassed == true && rightPassed == true) ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor((leftPassed == true && rightPassed == true) ? .green : .orange)

                    Text((leftPassed == true && rightPassed == true) ? "스피커 정상!" : "일부 채널 이상")
                        .font(.system(size: 18, weight: .semibold))

                    HStack(spacing: 20) {
                        Label(leftPassed == true ? "왼쪽 정상" : "왼쪽 이상",
                              systemImage: leftPassed == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(leftPassed == true ? .green : .red)
                        Label(rightPassed == true ? "오른쪽 정상" : "오른쪽 이상",
                              systemImage: rightPassed == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(rightPassed == true ? .green : .red)
                    }
                    .font(.system(size: 14))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(14)
            }

            Spacer()

            HStack {
                Button("건너뛰기") {
                    isPassed = false
                    result = "테스트 건너뜀"
                    dismiss()
                }
                Spacer()
                if step == 2 {
                    Button("완료 ✓") {
                        let passed = leftPassed == true && rightPassed == true
                        isPassed = passed
                        result = passed ? "좌우 채널 정상" : "일부 채널 이상"
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
        .padding(24)
        .frame(width: 440, height: 400)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                playTone(channel: .left)
            }
        }
    }

    func stepDot(index: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(step >= index ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 12, height: 12)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    func playTone(channel: AudioChannel) {
        isPlaying = true
        DispatchQueue.global().async {
            let engine = AVAudioEngine()
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
            let frameCount = AVAudioFrameCount(44100 * 2)
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
            buffer.frameLength = frameCount
            let frequency: Float = 440.0
            for i in 0..<Int(frameCount) {
                let sample = sin(2.0 * Float.pi * frequency * Float(i) / 44100.0) * 0.5
                switch channel {
                case .left:
                    buffer.floatChannelData?[0][i] = sample
                    buffer.floatChannelData?[1][i] = 0
                case .right:
                    buffer.floatChannelData?[0][i] = 0
                    buffer.floatChannelData?[1][i] = sample
                }
            }
            try? engine.start()
            playerNode.play()
            playerNode.scheduleBuffer(buffer, completionHandler: nil)
            Thread.sleep(forTimeInterval: 2.0)
            engine.stop()
            DispatchQueue.main.async { isPlaying = false }
        }
    }
}
