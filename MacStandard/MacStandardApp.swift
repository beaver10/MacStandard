import SwiftUI

@main
struct MacStandardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
            // 전체화면 비활성화
            CommandGroup(replacing: .toolbar) {}
        }
    }
}
