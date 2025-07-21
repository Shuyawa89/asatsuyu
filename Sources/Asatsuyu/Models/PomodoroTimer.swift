import Foundation
import Combine

enum TimerState {
    case stopped
    case running
    case paused
}

enum SessionType: String, CaseIterable {
    case work = "work"
    case shortBreak = "shortBreak"
    case longBreak = "longBreak"
    
    var displayName: String {
        switch self {
        case .work: return "作業"
        case .shortBreak: return "短い休憩"
        case .longBreak: return "長い休憩"
        }
    }
}

class PomodoroTimer: ObservableObject {
    @Published var currentState: TimerState = .stopped
    @Published var currentSessionType: SessionType = .work
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    @Published var currentCycle: Int = 0
    
    private var timer: Timer?
    private var sessionStartTime: Date?
    
    // 設定値
    private let workDuration: TimeInterval = 30 * 60 // 30分
    private let shortBreakDuration: TimeInterval = 5 * 60 // 5分
    private let longBreakDuration: TimeInterval = 15 * 60 // 15分
    private let cyclesUntilLongBreak: Int = 4
    
    init() {
        resetTimer()
    }
    
    func start() {
        guard currentState != .running else { return }
        
        if currentState == .stopped {
            sessionStartTime = Date()
            timeRemaining = getDurationForCurrentSession()
            totalTime = timeRemaining
        }
        
        currentState = .running
        startTimer()
    }
    
    func pause() {
        guard currentState == .running else { return }
        currentState = .paused
        stopTimer()
    }
    
    func stop() {
        currentState = .stopped
        stopTimer()
        resetTimer()
    }
    
    func reset() {
        stopTimer()
        currentState = .stopped
        resetTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        timeRemaining -= 1
        
        if timeRemaining <= 0 {
            sessionCompleted()
        }
    }
    
    private func sessionCompleted() {
        stopTimer()
        currentState = .stopped
        
        // 次のセッションタイプを決定
        switch currentSessionType {
        case .work:
            currentCycle += 1
            if currentCycle >= cyclesUntilLongBreak {
                currentSessionType = .longBreak
                currentCycle = 0
            } else {
                currentSessionType = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentSessionType = .work
        }
        
        resetTimer()
        
        // 通知を送信（後で実装）
        // NotificationService.shared.sendSessionCompletedNotification()
    }
    
    private func resetTimer() {
        timeRemaining = getDurationForCurrentSession()
        totalTime = timeRemaining
    }
    
    private func getDurationForCurrentSession() -> TimeInterval {
        switch currentSessionType {
        case .work:
            return workDuration
        case .shortBreak:
            return shortBreakDuration
        case .longBreak:
            return longBreakDuration
        }
    }
    
    // プログレス（0.0 - 1.0）
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return 1.0 - (timeRemaining / totalTime)
    }
    
    // 残り時間の文字列表現
    var timeRemainingString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}