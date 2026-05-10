import SwiftUI
import AppKit

struct KeyboardTestView: View {
    @Binding var isPassed: Bool
    @Binding var result: String
    @Environment(\.dismiss) var dismiss

    let allKeys: [String] = [
        "esc","f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12",
        "`","1","2","3","4","5","6","7","8","9","0","-","=","delete",
        "tab","q","w","e","r","t","y","u","i","o","p","[","]","\\",
        "caps","a","s","d","f","g","h","j","k","l",";","'","return",
        "shift","z","x","c","v","b","n","m",",",".","/",
        "fn","ctrl","opt","cmd","space"
    ]

    let systemKeys: Set<String> = ["f11"]

    @State private var pressedKeys: Set<String> = []

    var progress: Double {
        Double(pressedKeys.count) / Double(allKeys.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("키보드 테스트")
                .font(.system(size: 18, weight: .semibold))

            Text("모든 키를 한 번씩 눌러주세요")
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            Text("💡 F1~F12는 fn 키를 누른 채로 눌러주세요")
                .font(.system(size: 12))
                .foregroundColor(.orange)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color.orange.opacity(0.08))
                .cornerRadius(8)
            
            ProgressView(value: min(progress, 1.0))
                .tint(.green)

            Text("\(pressedKeys.count)/\(allKeys.count) 키 확인됨")
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 10), spacing: 6) {
                    ForEach(allKeys, id: \.self) { key in
                        Text(key)
                            .font(.system(size: 11, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                systemKeys.contains(key) ? Color.gray.opacity(0.1) :
                                pressedKeys.contains(key) ? Color.green.opacity(0.2) :
                                Color(NSColor.controlBackgroundColor)
                            )
                            .foregroundColor(
                                systemKeys.contains(key) ? .secondary :
                                pressedKeys.contains(key) ? .green : .primary
                            )
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        systemKeys.contains(key) ? Color.gray.opacity(0.2) :
                                        pressedKeys.contains(key) ? Color.green.opacity(0.5) :
                                        Color.gray.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }

            HStack {
                Button("건너뛰기") {
                    isPassed = false
                    result = "\(pressedKeys.count)/\(allKeys.count) 키 확인"
                    dismiss()
                }
                Spacer()
                Button("완료 ✓") {
                    isPassed = pressedKeys.count >= allKeys.count - 2
                    result = "\(pressedKeys.count)/\(allKeys.count) 키 정상"
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding(24)
        .frame(width: 580, height: 500)
        .onAppear {
            pressedKeys.formUnion(systemKeys)
            NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
                if event.type == .flagsChanged {
                    let flags = event.modifierFlags
                    if flags.contains(.shift) { pressedKeys.insert("shift") }
                    if flags.contains(.control) { pressedKeys.insert("ctrl") }
                    if flags.contains(.option) { pressedKeys.insert("opt") }
                    if flags.contains(.command) { pressedKeys.insert("cmd") }
                    if flags.contains(.capsLock) { pressedKeys.insert("caps") }
                    if flags.contains(.function) { pressedKeys.insert("fn") }
                    return event
                }
                if event.keyCode == 53 {
                    pressedKeys.insert("esc")
                    return nil // 이벤트 삼켜서 창 안 닫히게 하면서 체크
                }
                let key = keyName(for: event)
                if !key.hasPrefix("unknown") {
                    pressedKeys.insert(key)
                }
                return event
            }
        }
    }

    func keyName(for event: NSEvent) -> String {
        switch event.keyCode {
        case 122: return "f1"
        case 120: return "f2"
        case 99:  return "f3"
        case 118: return "f4"
        case 96:  return "f5"
        case 97:  return "f6"
        case 98:  return "f7"
        case 100: return "f8"
        case 101: return "f9"
        case 109: return "f10"
        case 103: return "f11"
        case 111: return "f12"
        case 50:  return "`"
        case 18:  return "1"
        case 19:  return "2"
        case 20:  return "3"
        case 21:  return "4"
        case 23:  return "5"
        case 22:  return "6"
        case 26:  return "7"
        case 28:  return "8"
        case 25:  return "9"
        case 29:  return "0"
        case 27:  return "-"
        case 24:  return "="
        case 51:  return "delete"
        case 48:  return "tab"
        case 12:  return "q"
        case 13:  return "w"
        case 14:  return "e"
        case 15:  return "r"
        case 17:  return "t"
        case 16:  return "y"
        case 32:  return "u"
        case 34:  return "i"
        case 31:  return "o"
        case 35:  return "p"
        case 33:  return "["
        case 30:  return "]"
        case 42:  return "\\"
        case 0:   return "a"
        case 1:   return "s"
        case 2:   return "d"
        case 3:   return "f"
        case 5:   return "g"
        case 4:   return "h"
        case 38:  return "j"
        case 40:  return "k"
        case 37:  return "l"
        case 41:  return ";"
        case 39:  return "'"
        case 36:  return "return"
        case 6:   return "z"
        case 7:   return "x"
        case 8:   return "c"
        case 9:   return "v"
        case 11:  return "b"
        case 45:  return "n"
        case 46:  return "m"
        case 43:  return ","
        case 47:  return "."
        case 44:  return "/"
        case 49:  return "space"
        case 54:  return "cmd↑"
        case 61:  return "opt↑"
        default:  return "unknown-\(event.keyCode)"
        }
    }
}
