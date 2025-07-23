import Combine
import Foundation
import SwiftUI

@MainActor
class TimerViewModel: ObservableObject {
    @Published var pomodoroTimer = PomodoroTimer()
    private let notificationService = NotificationService.shared

    private var cancellables = Set<AnyCancellable>()

    init() {
        // PomodoroTimerの変更を監視
        pomodoroTimer.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // タイマー完了の監視
        pomodoroTimer.$currentState
            .sink { [weak self] state in
                if state == .completed {
                    self?.handleSessionComplete()
                }
            }
            .store(in: &cancellables)

        // 通知権限のリクエスト
        Task {
            await requestNotificationPermission()
        }
    }

    // MARK: - Timer Controls

    func startTimer() {
        pomodoroTimer.start()
    }

    func pauseTimer() {
        pomodoroTimer.pause()
    }

    func stopTimer() {
        pomodoroTimer.stop()
    }

    func resetTimer() {
        pomodoroTimer.reset()
    }

    // MARK: - Computed Properties

    var isRunning: Bool {
        pomodoroTimer.currentState == .running
    }

    var isPaused: Bool {
        pomodoroTimer.currentState == .paused
    }

    var isStopped: Bool {
        pomodoroTimer.currentState == .stopped
    }

    var isCompleted: Bool {
        pomodoroTimer.currentState == .completed
    }

    var canStart: Bool {
        pomodoroTimer.currentState != .running
    }

    var canPause: Bool {
        pomodoroTimer.currentState == .running
    }

    var canStop: Bool {
        pomodoroTimer.currentState != .stopped && pomodoroTimer.currentState != .completed
    }

    var timeRemainingString: String {
        pomodoroTimer.timeRemainingString
    }

    var currentSessionName: String {
        pomodoroTimer.currentSessionType.displayName
    }

    var progress: Double {
        pomodoroTimer.progress
    }

    var currentCycle: Int {
        pomodoroTimer.currentCycle
    }

    // MARK: - Notification Handling

    private func requestNotificationPermission() async {
        let granted = await notificationService.requestPermission()
        print("📱 通知権限: \(granted ? "許可" : "拒否")")
    }

    private func handleSessionComplete() {
        // セッション完了通知を送信
        notificationService.scheduleSessionCompleteNotification(
            for: pomodoroTimer.currentSessionType
        )

        print("🎉 セッション完了: \(pomodoroTimer.currentSessionType.localizedName)")
    }

    // MARK: - UI Colors

    var sessionColor: Color {
        switch pomodoroTimer.currentSessionType {
        case .work:
            return .accentColor
        case .shortBreak:
            return .green
        case .longBreak:
            return .blue
        }
    }

    var sessionIcon: String {
        switch pomodoroTimer.currentSessionType {
        case .work:
            return "laptopcomputer"
        case .shortBreak:
            return "cup.and.saucer"
        case .longBreak:
            return "bed.double"
        }
    }
}
