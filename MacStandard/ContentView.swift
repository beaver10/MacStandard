import SwiftUI
import IOKit.ps
import Darwin

struct TestItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    var status: TestStatus = .pending
    var result: String = "테스트 전"
    var isPassed: Bool = false
}

enum TestStatus {
    case pending, running, passed, failed
}

struct ContentView: View {
    @State private var tests: [TestItem] = [
        TestItem(title: "디스플레이", description: "픽셀 불량 · 밝기 균일성", icon: "display"),
        TestItem(title: "키보드", description: "모든 키 입력 확인", icon: "keyboard"),
        TestItem(title: "스피커", description: "좌우 채널 · 음질 테스트", icon: "speaker.wave.2"),
        TestItem(title: "배터리", description: "사이클 수 · 용량 상태", icon: "battery.100"),
        TestItem(title: "카메라", description: "화질 · 색감 확인", icon: "camera"),
        TestItem(title: "SSD 속도", description: "읽기 · 쓰기 속도 측정", icon: "internaldrive"),
        TestItem(title: "트랙패드", description: "클릭 · 스크롤 · 제스처", icon: "rectangle.and.hand.point.up.left.fill"),
        TestItem(title: "WiFi 속도", description: "네트워크 속도 측정", icon: "wifi"),
        TestItem(title: "CPU 상태", description: "사용률 · 메모리 · 업타임", icon: "thermometer"),
    ]

    @State private var showDisplay = false
    @State private var showKeyboard = false
    @State private var showSpeaker = false
    @State private var showTrackpad = false
    @State private var showCamera = false
    @State private var showReport = false
    @State private var displayWindow: NSWindow?

    var completedCount: Int {
        tests.filter { $0.status == .passed || $0.status == .failed }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MacStandard")
                        .font(.system(size: 22, weight: .semibold))
                    Text(getMacInfo())
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("진단 진행률")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(completedCount)/\(tests.count) 완료")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                ProgressView(value: Double(completedCount), total: Double(tests.count))
                    .tint(.green)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(tests.indices, id: \.self) { i in
                    TestCard(test: tests[i]) {
                        startTest(index: i)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            HStack(spacing: 12) {
                Button(action: runAllTests) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("전체 진단 시작")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button(action: { showReport = true }) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("보고서 저장")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .disabled(completedCount == 0)
            }
            .padding(24)
        }
        .frame(width: 720, height: 680)
        .background(Color(NSColor.windowBackgroundColor))
        .onChange(of: showDisplay) { _, newValue in
            if newValue { openDisplayTest() }
        }
        .sheet(isPresented: $showKeyboard) {
            KeyboardTestView(
                isPassed: Binding(
                    get: { tests[1].isPassed },
                    set: { tests[1].isPassed = $0 }
                ),
                result: Binding(
                    get: { tests[1].result },
                    set: {
                        tests[1].result = $0
                        tests[1].status = tests[1].isPassed ? .passed : .failed
                    }
                )
            )
        }
        .sheet(isPresented: $showSpeaker) {
            SpeakerTestView(
                isPassed: Binding(
                    get: { tests[2].isPassed },
                    set: { tests[2].isPassed = $0 }
                ),
                result: Binding(
                    get: { tests[2].result },
                    set: {
                        tests[2].result = $0
                        tests[2].status = tests[2].isPassed ? .passed : .failed
                    }
                )
            )
        }
        .sheet(isPresented: $showTrackpad) {
            TrackpadTestView(
                isPassed: Binding(
                    get: { tests[6].isPassed },
                    set: { tests[6].isPassed = $0 }
                ),
                result: Binding(
                    get: { tests[6].result },
                    set: {
                        tests[6].result = $0
                        tests[6].status = tests[6].isPassed ? .passed : .failed
                    }
                )
            )
        }
        .sheet(isPresented: $showCamera) {
            CameraTestView(
                isPassed: Binding(
                    get: { tests[4].isPassed },
                    set: { tests[4].isPassed = $0 }
                ),
                result: Binding(
                    get: { tests[4].result },
                    set: {
                        tests[4].result = $0
                        tests[4].status = tests[4].isPassed ? .passed : .failed
                    }
                )
            )
        }
        .sheet(isPresented: $showReport) {
            ReportView(tests: tests)
        }
    }

    func openDisplayTest() {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.isOpaque = true
        window.collectionBehavior = [.fullScreenAuxiliary]
        window.contentView = NSHostingView(rootView:
            DisplayTestView(
                isPassed: Binding(
                    get: { tests[0].isPassed },
                    set: { tests[0].isPassed = $0 }
                ),
                result: Binding(
                    get: { tests[0].result },
                    set: {
                        tests[0].result = $0
                        tests[0].status = tests[0].isPassed ? .passed : .failed
                        showDisplay = false
                        window.orderOut(nil)
                        window.close()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            for win in NSApp.windows {
                                if win != window {
                                    win.makeKeyAndOrderFront(nil)
                                }
                            }
                        }
                    }
                )
            )
        )
        window.setFrame(screen.frame, display: true)
        window.makeKeyAndOrderFront(nil)
        displayWindow = window
    }

    func startTest(index: Int) {
        switch index {
        case 0: showDisplay = true
        case 1: showKeyboard = true
        case 2: showSpeaker = true
        case 3: runBatteryTest()
        case 4: showCamera = true
        case 5: runSSDTest()
        case 6: showTrackpad = true
        case 7: runWifiTest()
        case 8: runCPUTest()
        default: break
        }
    }

    func runAllTests() {
        showDisplay = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            runBatteryTest()
            runSSDTest()
            runWifiTest()
            runCPUTest()
        }
    }

    func runBatteryTest() {
        tests[3].status = .running
        tests[3].result = "측정 중..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let info = getBatteryInfo()
            tests[3].result = info
            tests[3].isPassed = !info.contains("없음")
            tests[3].status = tests[3].isPassed ? .passed : .failed
        }
    }


    func runSSDTest() {
        tests[5].status = .running
        tests[5].result = "측정 중..."
        DispatchQueue.global().async {
            let speed = measureSSDSpeed()
            DispatchQueue.main.async {
                tests[5].result = "읽기 \(speed.read) · 쓰기 \(speed.write) MB/s"
                tests[5].isPassed = speed.write > 500
                tests[5].status = tests[5].isPassed ? .passed : .failed
            }
        }
    }

    func runWifiTest() {
        tests[7].status = .running
        tests[7].result = "측정 중..."

        DispatchQueue.global().async {
            let downloadStart = Date()
            let downloadURL = URL(string: "https://speed.cloudflare.com/__down?bytes=10000000")!
            var downloadSpeed = 0
            if let data = try? Data(contentsOf: downloadURL) {
                let elapsed = Date().timeIntervalSince(downloadStart)
                downloadSpeed = Int(Double(data.count) * 8 / elapsed / 1_000_000)
            }

            let uploadURL = URL(string: "https://speed.cloudflare.com/__up")!
            var request = URLRequest(url: uploadURL)
            request.httpMethod = "POST"
            request.httpBody = Data(repeating: 0, count: 5_000_000)
            let uploadStart = Date()
            var uploadSpeed = 0
            let semaphore = DispatchSemaphore(value: 0)
            URLSession.shared.dataTask(with: request) { _, _, _ in
                let elapsed = Date().timeIntervalSince(uploadStart)
                uploadSpeed = Int(Double(5_000_000) * 8 / elapsed / 1_000_000)
                semaphore.signal()
            }.resume()
            semaphore.wait()

            let pingStart = Date()
            let pingURL = URL(string: "https://speed.cloudflare.com/__down?bytes=1")!
            var ping = 0
            if (try? Data(contentsOf: pingURL)) != nil {
                ping = Int(Date().timeIntervalSince(pingStart) * 1000)
            }

            DispatchQueue.main.async {
                tests[7].result = "↓\(downloadSpeed)Mbps ↑\(uploadSpeed)Mbps 핑\(ping)ms"
                tests[7].isPassed = downloadSpeed > 10
                tests[7].status = tests[7].isPassed ? .passed : .failed
            }
        }
    }

    func runCPUTest() {
        tests[8].status = .running
        tests[8].result = "측정 중..."

        DispatchQueue.global().async {
            let cpuUsage = getCPUUsage()
            let memInfo = getMemoryInfo()
            let bootTime = getBootTime()

            DispatchQueue.main.async {
                tests[8].result = "CPU \(cpuUsage)% · 메모리 \(memInfo) · 업타임 \(bootTime)"
                tests[8].isPassed = true
                tests[8].status = .passed
            }
        }
    }

    func getCPUUsage() -> Int {
        var cpuInfo: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCpus: natural_t = 0
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCpus, &cpuInfo, &numCpuInfo)
        guard result == KERN_SUCCESS, let cpuInfo = cpuInfo else { return 0 }
        var totalUsage: Double = 0
        for i in 0..<Int(numCpus) {
            let base = Int(CPU_STATE_MAX) * i
            let user = Double(cpuInfo[base + Int(CPU_STATE_USER)])
            let system = Double(cpuInfo[base + Int(CPU_STATE_SYSTEM)])
            let idle = Double(cpuInfo[base + Int(CPU_STATE_IDLE)])
            let nice = Double(cpuInfo[base + Int(CPU_STATE_NICE)])
            let total = user + system + idle + nice
            totalUsage += (user + system + nice) / total * 100
        }
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(numCpuInfo) * vm_size_t(MemoryLayout<integer_t>.size))
        return Int(totalUsage / Double(numCpus))
    }

    func getMemoryInfo() -> String {
        let total = ProcessInfo.processInfo.physicalMemory
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        let pageSize = UInt64(vm_page_size)
        let used = result == KERN_SUCCESS
            ? UInt64(stats.active_count + stats.wire_count) * pageSize
            : 0
        let totalGB = String(format: "%.0f", Double(total) / 1_073_741_824)
        let usedGB = String(format: "%.1f", Double(used) / 1_073_741_824)
        return "\(usedGB)/\(totalGB)GB"
    }

    func getBootTime() -> String {
        var tv = timeval()
        var size = MemoryLayout<timeval>.size
        sysctlbyname("kern.boottime", &tv, &size, nil, 0)
        let bootDate = Date(timeIntervalSince1970: TimeInterval(tv.tv_sec))
        let uptime = Date().timeIntervalSince(bootDate)
        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        return "\(hours)시간 \(minutes)분"
    }

    func getMacInfo() -> String {
        let name = Host.current().localizedName ?? "Mac"
        return "\(name) · macOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
    }

    func getBatteryInfo() -> String {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        for source in sources {
            if let desc = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as? [String: Any] {
                let capacity = desc[kIOPSCurrentCapacityKey] as? Int ?? 0
                let maxCapacity = desc[kIOPSMaxCapacityKey] as? Int ?? 100
                let cycleCount = desc["CycleCount"] as? Int ?? 0
                let health = Int((Double(capacity) / Double(maxCapacity)) * 100)
                return "사이클 \(cycleCount)회 · 상태 \(health)%"
            }
        }
        return "배터리 정보 없음"
    }

    func measureSSDSpeed() -> (read: Int, write: Int) {
        let size = 100 * 1024 * 1024
        let data = Data(repeating: 0, count: size)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("macstandard_test")

        // 쓰기 측정
        let writeStart = Date()
        try? data.write(to: url)
        let writeElapsed = Date().timeIntervalSince(writeStart)
        let writeSpeed = writeElapsed > 0 ? Int(Double(size) / writeElapsed / 1024 / 1024) : 0

        // 읽기 측정
        let readStart = Date()
        _ = try? Data(contentsOf: url)
        let readElapsed = Date().timeIntervalSince(readStart)
        let readSpeed = readElapsed > 0 ? Int(Double(size) / readElapsed / 1024 / 1024) : 0

        try? FileManager.default.removeItem(at: url)
        return (readSpeed, writeSpeed)
    }
}

struct TestCard: View {
    let test: TestItem
    let onTap: () -> Void

    var statusColor: Color {
        switch test.status {
        case .pending: return .secondary
        case .running: return .blue
        case .passed: return .green
        case .failed: return .red
        }
    }

    var statusText: String {
        switch test.status {
        case .pending: return "대기"
        case .running: return "진행 중"
        case .passed: return "통과"
        case .failed: return "실패"
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: test.icon)
                        .font(.system(size: 20))
                        .foregroundColor(statusColor)
                    Spacer()
                    Text(statusText)
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor.opacity(0.1))
                        .foregroundColor(statusColor)
                        .cornerRadius(6)
                }
                Text(test.title)
                    .font(.system(size: 14, weight: .medium))
                Text(test.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Divider()
                Text(test.result)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        test.status == .passed ? Color.green.opacity(0.3) :
                        test.status == .failed ? Color.red.opacity(0.3) :
                        Color.gray.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct ReportView: View {
    let tests: [TestItem]
    @Environment(\.dismiss) var dismiss

    var passedCount: Int { tests.filter { $0.status == .passed }.count }
    var failedCount: Int { tests.filter { $0.status == .failed }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("진단 보고서")
                        .font(.system(size: 22, weight: .semibold))
                    Spacer()
                    Button("닫기") { dismiss() }
                        .buttonStyle(.bordered)
                }
                Text(Date().formatted(date: .long, time: .shortened))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(24)
            .padding(.bottom, 8)

            Divider()

            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("\(passedCount)")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.green)
                    Text("통과")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 60)

                VStack(spacing: 4) {
                    Text("\(failedCount)")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(failedCount > 0 ? .red : .secondary)
                    Text("실패")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 60)

                VStack(spacing: 4) {
                    Text(failedCount == 0 ? "양품" : "확인 필요")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(failedCount == 0 ? .green : .orange)
                    Text("판정")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 20)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(tests) { test in
                        HStack(spacing: 12) {
                            Image(systemName: test.status == .passed ? "checkmark.circle.fill" : test.status == .failed ? "xmark.circle.fill" : "circle")
                                .foregroundColor(test.status == .passed ? .green : test.status == .failed ? .red : .secondary)
                                .font(.system(size: 16))
                            Text(test.title)
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Text(test.result)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        Divider()
                            .padding(.leading, 24)
                    }
                }
            }

            Spacer()
        }
        .frame(width: 500, height: 560)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
}
