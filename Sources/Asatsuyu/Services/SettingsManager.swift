import Combine
import Foundation

@MainActor
class SettingsManager: ObservableObject {
    @MainActor static let shared = SettingsManager()

    private let userDefaults = UserDefaults.standard

    // MARK: - Timer Settings

    @Published var workDuration: TimeInterval {
        didSet {
            userDefaults.set(workDuration, forKey: Keys.workDuration)
        }
    }

    @Published var shortBreakDuration: TimeInterval {
        didSet {
            userDefaults.set(shortBreakDuration, forKey: Keys.shortBreakDuration)
        }
    }

    @Published var longBreakDuration: TimeInterval {
        didSet {
            userDefaults.set(longBreakDuration, forKey: Keys.longBreakDuration)
        }
    }

    @Published var cyclesUntilLongBreak: Int {
        didSet {
            userDefaults.set(cyclesUntilLongBreak, forKey: Keys.cyclesUntilLongBreak)
        }
    }

    // MARK: - Notification Settings

    @Published var soundEnabled: Bool {
        didSet {
            userDefaults.set(soundEnabled, forKey: Keys.soundEnabled)
        }
    }

    @Published var soundName: String {
        didSet {
            userDefaults.set(soundName, forKey: Keys.soundName)
        }
    }

    @Published var bannerEnabled: Bool {
        didSet {
            userDefaults.set(bannerEnabled, forKey: Keys.bannerEnabled)
        }
    }

    // MARK: - Obsidian Settings

    @Published var obsidianVaultPath: String? {
        didSet {
            userDefaults.set(obsidianVaultPath, forKey: Keys.obsidianVaultPath)
        }
    }

    @Published var autoSaveEnabled: Bool {
        didSet {
            userDefaults.set(autoSaveEnabled, forKey: Keys.autoSaveEnabled)
        }
    }

    @Published var fileNameFormat: String {
        didSet {
            userDefaults.set(fileNameFormat, forKey: Keys.fileNameFormat)
        }
    }

    // MARK: - Initialization

    private init() {
        // デフォルト値の設定
        workDuration = userDefaults.object(forKey: Keys.workDuration) as? TimeInterval ?? 1800 // 30分
        shortBreakDuration = userDefaults.object(forKey: Keys.shortBreakDuration) as? TimeInterval ?? 300 // 5分
        longBreakDuration = userDefaults.object(forKey: Keys.longBreakDuration) as? TimeInterval ?? 900 // 15分
        cyclesUntilLongBreak = userDefaults.object(forKey: Keys.cyclesUntilLongBreak) as? Int ?? 4

        soundEnabled = userDefaults.object(forKey: Keys.soundEnabled) as? Bool ?? true
        soundName = userDefaults.object(forKey: Keys.soundName) as? String ?? "default"
        bannerEnabled = userDefaults.object(forKey: Keys.bannerEnabled) as? Bool ?? true

        obsidianVaultPath = userDefaults.object(forKey: Keys.obsidianVaultPath) as? String
        autoSaveEnabled = userDefaults.object(forKey: Keys.autoSaveEnabled) as? Bool ?? true
        fileNameFormat = userDefaults.object(forKey: Keys.fileNameFormat) as? String ?? "YYYY-MM-DD"
    }

    // MARK: - Helper Methods

    func resetToDefaults() {
        workDuration = 1800
        shortBreakDuration = 300
        longBreakDuration = 900
        cyclesUntilLongBreak = 4

        soundEnabled = true
        soundName = "default"
        bannerEnabled = true

        obsidianVaultPath = nil
        autoSaveEnabled = true
        fileNameFormat = "YYYY-MM-DD"
    }

    // MARK: - Keys

    private enum Keys {
        static let workDuration = "timer.workDuration"
        static let shortBreakDuration = "timer.shortBreakDuration"
        static let longBreakDuration = "timer.longBreakDuration"
        static let cyclesUntilLongBreak = "timer.cyclesUntilLongBreak"

        static let soundEnabled = "notifications.soundEnabled"
        static let soundName = "notifications.soundName"
        static let bannerEnabled = "notifications.bannerEnabled"

        static let obsidianVaultPath = "obsidian.vaultPath"
        static let autoSaveEnabled = "obsidian.autoSaveEnabled"
        static let fileNameFormat = "obsidian.fileNameFormat"
    }
}
