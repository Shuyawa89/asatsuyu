import AppKit
import SwiftUI
import UserNotifications

@main
struct AsatsuyuApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var notchOverlayManager = NotchOverlayManager.shared

    init() {
        // 通知機能は一時的に無効化（Swift 6.0並行性対応）
        // Phase 2で再実装予定
    }

    var body: some Scene {
        MenuBarExtra("Asatsuyu", systemImage: "timer") {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(settingsManager)
                .environmentObject(notchOverlayManager)
                .onAppear {
                    // アプリ起動時にノッチオーバーレイを表示
                    notchOverlayManager.showOverlay()
                }
        }
        .menuBarExtraStyle(.window)
    }

    // MARK: - Notification Setup

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("通知許可エラー: \(error)")
            }
            print("通知許可: \(granted)")
        }
    }

    private func setupAppTerminationNotification() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                AsatsuyuApp.sendClaudeCodeCompletionNotification()
            }
        }
    }

    @MainActor
    private static func sendClaudeCodeCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Claude Code Execution Complete", comment: "Claude Code実行完了")
        content.body = NSLocalizedString("Asatsuyu application development session has ended.", comment: "Asatsuyuアプリケーションの開発セッションが終了しました")
        content.sound = .default
        content.categoryIdentifier = "CLAUDE_CODE_COMPLETION"

        // 小さな遅延を追加して配信の信頼性を向上
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "claude-code-completion-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知送信エラー: \(error.localizedDescription)")
            } else {
                print("Claude Code完了通知を送信しました")
            }
        }
    }
}
