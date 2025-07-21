import Foundation
import Combine
import SwiftUI

@MainActor
class TimerViewModel: ObservableObject {
    @Published var pomodoroTimer = PomodoroTimer()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // PomodoroTimerの変更を監視
        pomodoroTimer.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
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
    
    var canStart: Bool {
        pomodoroTimer.currentState != .running
    }
    
    var canPause: Bool {
        pomodoroTimer.currentState == .running
    }
    
    var canStop: Bool {
        pomodoroTimer.currentState != .stopped
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