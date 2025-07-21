import SwiftUI

@main
struct AsatsuyuApp: App {
    var body: some Scene {
        MenuBarExtra("Asatsuyu", systemImage: "timer") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}