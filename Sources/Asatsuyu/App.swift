import SwiftUI
import AppKit

@main
struct AsatsuyuApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var notchOverlayManager = NotchOverlayManager.shared
    
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
}