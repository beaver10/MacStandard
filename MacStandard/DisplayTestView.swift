import SwiftUI
import AppKit

struct DisplayTestView: View {
    let colors: [(String, Color)] = [
        ("빨강", .red),
        ("초록", .green),
        ("파랑", .blue),
        ("흰색", .white),
        ("검정", .black),
    ]
    @State private var currentIndex = 0
    @State private var showControls = true
    @Binding var isPassed: Bool
    @Binding var result: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // 풀스크린 색상
            colors[currentIndex].1
                .ignoresSafeArea(.all)

            // 컨트롤 UI
            if showControls {
                VStack {
                    Spacer()

                    VStack(spacing: 16) {
                        Text("\(currentIndex + 1)/\(colors.count) — \(colors[currentIndex].0)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(currentIndex == 3 ? .black : .white)

                        HStack(spacing: 12) {
                            Button("← 이전") {
                                if currentIndex > 0 { currentIndex -= 1 }
                            }
                            .disabled(currentIndex == 0)

                            Button("다음 →") {
                                if currentIndex < colors.count - 1 {
                                    currentIndex += 1
                                }
                            }
                            .disabled(currentIndex == colors.count - 1)

                            Spacer()

                            Button("불량 있음") {
                                isPassed = false
                                result = "불량 픽셀 발견됨"
                                dismiss()
                            }
                            .foregroundColor(.red)
                            .buttonStyle(.bordered)

                            Button("이상 없음 ✓") {
                                isPassed = true
                                result = "불량 픽셀 없음"
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }

                        Text("화면을 탭하면 컨트롤이 숨겨져요")
                            .font(.system(size: 12))
                            .foregroundColor(currentIndex == 3 ? .black.opacity(0.5) : .white.opacity(0.5))
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(14)
                    .padding(24)
                }
            }
        }
        .onTapGesture {
            withAnimation { showControls.toggle() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // 전체화면으로 전환
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.mainWindow?.toggleFullScreen(nil)
            }
        }
        .onDisappear {
            if NSApp.mainWindow?.styleMask.contains(.fullScreen) == true {
                NSApp.mainWindow?.toggleFullScreen(nil)
            }
        }
    }
}
