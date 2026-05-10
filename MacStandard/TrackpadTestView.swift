import SwiftUI

struct TrackpadTestView: View {
    @Binding var isPassed: Bool
    @Binding var result: String
    @Environment(\.dismiss) var dismiss

    @State private var targets: [CGPoint] = []
    @State private var hitCount = 0
    @State private var totalTargets = 10
    @State private var currentTarget: CGPoint = .zero
    @State private var showHit = false
    @State private var isFinished = false
    @State private var missCount = 0

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            VStack(spacing: 8) {
                Text("트랙패드 테스트")
                    .font(.system(size: 18, weight: .semibold))
                Text("원을 클릭해주세요")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                ProgressView(value: Double(hitCount), total: Double(totalTargets))
                    .tint(.green)
                Text("\(hitCount)/\(totalTargets) 클릭됨")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(20)

            Divider()

            if isFinished {
                // 완료 화면
                VStack(spacing: 16) {
                    Image(systemName: missCount < 3 ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 52))
                        .foregroundColor(missCount < 3 ? .green : .orange)

                    Text(missCount < 3 ? "트랙패드 정상!" : "정확도 낮음")
                        .font(.system(size: 20, weight: .semibold))

                    HStack(spacing: 24) {
                        VStack {
                            Text("\(hitCount)")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.green)
                            Text("성공")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        VStack {
                            Text("\(missCount)")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(missCount > 0 ? .red : .secondary)
                            Text("미스")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    Button("완료 ✓") {
                        isPassed = missCount < 3
                        result = "성공 \(hitCount)/\(totalTargets) · 미스 \(missCount)"
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                // 게임 영역
                GeometryReader { geo in
                    ZStack {
                        // 배경 클릭 = 미스
                        Color(NSColor.controlBackgroundColor)
                            .onTapGesture {
                                missCount += 1
                                spawnTarget(in: geo.size)
                            }

                        // 타겟 원
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.green, lineWidth: 2.5)
                                    .frame(width: 70, height: 70)
                            )
                            .overlay(
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 12, height: 12)
                            )
                            .scaleEffect(showHit ? 1.3 : 1.0)
                            .animation(.spring(duration: 0.2), value: showHit)
                            .position(currentTarget)
                            .onTapGesture {
                                withAnimation {
                                    showHit = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    showHit = false
                                    hitCount += 1
                                    if hitCount >= totalTargets {
                                        isFinished = true
                                    } else {
                                        spawnTarget(in: geo.size)
                                    }
                                }
                            }
                    }
                    .onAppear {
                        spawnTarget(in: geo.size)
                    }
                }
                .cornerRadius(12)
                .padding(16)
            }

            Divider()

            HStack {
                Button("건너뛰기") {
                    isPassed = false
                    result = "테스트 건너뜀"
                    dismiss()
                }
                Spacer()
                Text("미스: \(missCount)")
                    .font(.system(size: 13))
                    .foregroundColor(missCount > 0 ? .red : .secondary)
            }
            .padding(16)
        }
        .frame(width: 500, height: 520)
        .background(Color(NSColor.windowBackgroundColor))
    }

    func spawnTarget(in size: CGSize) {
        let margin: CGFloat = 50
        let x = CGFloat.random(in: margin...(size.width - margin))
        let y = CGFloat.random(in: margin...(size.height - margin))
        currentTarget = CGPoint(x: x, y: y)
    }
}

struct TrackpadTest: Identifiable {
    let id = UUID()
    let name: String
    let instruction: String
    let icon: String
    var passed: Bool? = nil
}
