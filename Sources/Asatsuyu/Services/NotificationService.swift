import Foundation
@preconcurrency import UserNotifications

@MainActor
class NotificationService: ObservableObject {
    @MainActor static let shared = NotificationService()

    @Published private(set) var isAuthorized = false
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    /// 通知権限の確認
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            authorizationStatus = settings.authorizationStatus
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    /// 通知権限のリクエスト
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )

            await checkAuthorizationStatus()
            return granted
        } catch {
            print("通知許可エラー: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Session Notifications

    /// セッション完了通知のスケジュール
    func scheduleSessionCompleteNotification(for sessionType: SessionType) {
        guard isAuthorized else {
            print("通知権限がありません")
            return
        }

        let content = UNMutableNotificationContent()
        content.sound = .default
        content.categoryIdentifier = "POMODORO_COMPLETION"

        switch sessionType {
        case .work:
            content.title = NSLocalizedString("Work Session Complete", comment: "作業セッション完了")
            content.body = NSLocalizedString("Time for a break!", comment: "休憩時間です！")
        case .shortBreak:
            content.title = NSLocalizedString("Break Complete", comment: "休憩完了")
            content.body = NSLocalizedString("Ready to focus again?", comment: "再び集中しましょう！")
        case .longBreak:
            content.title = NSLocalizedString("Long Break Complete", comment: "長い休憩完了")
            content.body = NSLocalizedString("Great work! Ready for the next cycle?", comment: "お疲れ様！次のサイクルに進みますか？")
        }

        // 即座に通知を送信
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let identifier = "session-complete-\(Date().timeIntervalSince1970)"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error.localizedDescription)")
            } else {
                print("✅ \(sessionType)完了通知をスケジュールしました")
            }
        }
    }

    /// 進行中のセッション通知（オプション機能）
    func scheduleSessionProgressNotification(remainingTime: TimeInterval, sessionType: SessionType) {
        guard isAuthorized else { return }

        // 5分前と1分前に通知
        let notifications = [
            (timeInterval: max(0, remainingTime - 300), title: "5 minutes remaining"),
            (timeInterval: max(0, remainingTime - 60), title: "1 minute remaining"),
        ].filter { $0.timeInterval > 0 }

        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString(notification.title, comment: "")
            content.body = NSLocalizedString("Stay focused!", comment: "集中を続けましょう！")
            content.sound = .default
            content.categoryIdentifier = "POMODORO_PROGRESS"

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: notification.timeInterval,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "progress-\(sessionType)-\(notification.timeInterval)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("進行通知エラー: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Notification Management

    /// 全ての予定通知をキャンセル
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("📱 全ての通知をキャンセルしました")
    }

    /// 特定のカテゴリの通知をキャンセル
    func cancelNotifications(withCategory category: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.content.categoryIdentifier == category }
                .map { $0.identifier }

            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: identifiersToRemove
            )

            print("📱 \(category)カテゴリの通知をキャンセルしました")
        }
    }

    // MARK: - Settings Integration

    /// 設定に基づいて通知を有効/無効にする
    func updateNotificationSettings(soundEnabled: Bool) {
        // SettingsManagerと連携して通知設定を更新
        // 実装は後でSettingsManagerに統合
        print("🔧 通知設定を更新: 音声=\(soundEnabled)")
    }
}

// MARK: - SessionType Extension

extension SessionType {
    var localizedName: String {
        switch self {
        case .work:
            return NSLocalizedString("Work", comment: "作業")
        case .shortBreak:
            return NSLocalizedString("Short Break", comment: "短い休憩")
        case .longBreak:
            return NSLocalizedString("Long Break", comment: "長い休憩")
        }
    }
}
