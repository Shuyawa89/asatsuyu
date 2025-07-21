import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    @EnvironmentObject private var notchOverlayManager: NotchOverlayManager
    
    var body: some View {
        VStack(spacing: 20) {
            // セッション情報
            sessionHeader
            
            // 円形プログレス表示
            circularProgress
            
            // 制御ボタン
            controlButtons
        }
        .padding()
        .frame(width: 320, height: 400)
        .onAppear {
            // タイマーViewModelとノッチオーバーレイを接続
            notchOverlayManager.connectToTimer(viewModel)
        }
    }
    
    // MARK: - UI Components
    
    private var sessionHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: viewModel.sessionIcon)
                    .foregroundColor(viewModel.sessionColor)
                Text(viewModel.currentSessionName)
                    .font(.headline)
                    .foregroundColor(viewModel.sessionColor)
            }
            
            if viewModel.currentCycle > 0 {
                Text("サイクル \(viewModel.currentCycle)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var circularProgress: some View {
        ZStack {
            // 背景の円
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                .frame(width: 120, height: 120)
            
            // プログレス円
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    viewModel.sessionColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
            
            // 時間表示
            VStack {
                Text(viewModel.timeRemainingString)
                    .font(.title2)
                    .fontWeight(.medium)
                    .monospacedDigit()
                
                Text(timerStateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 16) {
            // 開始/一時停止ボタン
            Button(action: primaryButtonAction) {
                HStack {
                    Image(systemName: primaryButtonIcon)
                    Text(primaryButtonText)
                }
                .frame(minWidth: 100)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canStart && !viewModel.canPause)
            
            // 停止ボタン
            Button(action: viewModel.stopTimer) {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("停止")
                }
                .frame(minWidth: 80)
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.canStop)
        }
    }
    
    // MARK: - Helper Properties
    
    private var timerStateText: String {
        switch viewModel.pomodoroTimer.currentState {
        case .running:
            return "実行中"
        case .paused:
            return "一時停止"
        case .stopped:
            return "停止中"
        }
    }
    
    private var primaryButtonText: String {
        switch viewModel.pomodoroTimer.currentState {
        case .running:
            return "一時停止"
        case .paused:
            return "再開"
        case .stopped:
            return "開始"
        }
    }
    
    private var primaryButtonIcon: String {
        switch viewModel.pomodoroTimer.currentState {
        case .running:
            return "pause.fill"
        case .paused:
            return "play.fill"
        case .stopped:
            return "play.fill"
        }
    }
    
    private func primaryButtonAction() {
        switch viewModel.pomodoroTimer.currentState {
        case .running:
            viewModel.pauseTimer()
        case .paused, .stopped:
            viewModel.startTimer()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}