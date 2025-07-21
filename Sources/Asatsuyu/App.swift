import SwiftUI
import AppKit
import UserNotifications

@main
struct AsatsuyuApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var notchOverlayManager = NotchOverlayManager.shared
    
    init() {
        requestNotificationPermission()
        setupAppTerminationNotification()
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
            sendClaudeCodeCompletionNotification()
        }
    }
    
    private func sendClaudeCodeCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Claude Code実行完了"
        content.body = "Asatsuyuアプリケーションの開発セッションが終了しました"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "claude-code-completion",
            content: content,
            trigger: nil // 即座に送信
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知送信エラー: \(error)")
            }
        }
    }
}