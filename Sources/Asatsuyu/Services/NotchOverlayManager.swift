import AppKit
import SwiftUI
import Combine

@MainActor
class NotchOverlayManager: ObservableObject {
    static let shared = NotchOverlayManager()
    
    private var overlayWindow: NotchOverlayWindow?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isNotchOverlayEnabled: Bool = true {
        didSet {
            if isNotchOverlayEnabled {
                showOverlay()
            } else {
                hideOverlay()
            }
        }
    }
    
    private init() {
        setupOverlayWindow()
    }
    
    private func setupOverlayWindow() {
        let initialRect = NSRect(x: 0, y: 0, width: 200, height: 32)
        overlayWindow = NotchOverlayWindow(
            contentRect: initialRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
    }
    
    func showOverlay() {
        overlayWindow?.show()
    }
    
    func hideOverlay() {
        overlayWindow?.hide()
    }
    
    func updateProgress(_ progress: Double, sessionType: SessionType) {
        let cgProgress = CGFloat(progress)
        let color = colorForSessionType(sessionType)
        
        overlayWindow?.updateProgress(cgProgress, color: color)
    }
    
    private func colorForSessionType(_ sessionType: SessionType) -> NSColor {
        switch sessionType {
        case .work:
            return .controlAccentColor
        case .shortBreak:
            return .systemGreen
        case .longBreak:
            return .systemBlue
        }
    }
    
    func connectToTimer(_ timerViewModel: TimerViewModel) {
        // タイマーの変更を監視してオーバーレイを更新
        // PomodoroTimerの各プロパティの変更を個別に監視
        timerViewModel.pomodoroTimer.$timeRemaining
            .combineLatest(
                timerViewModel.pomodoroTimer.$totalTime,
                timerViewModel.pomodoroTimer.$currentSessionType
            )
            .sink { [weak self] _, _, sessionType in
                let progress = timerViewModel.progress
                self?.updateProgress(progress, sessionType: sessionType)
            }
            .store(in: &cancellables)
    }
}