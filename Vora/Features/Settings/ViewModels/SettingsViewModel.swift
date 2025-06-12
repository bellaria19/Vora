//
//  SettingsViewModel.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var showResetAlert: Bool = false
    @Published var isDarkMode: Bool = false {
        didSet {
            saveSettings()
        }
    }

    let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Viora"
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    init() {
        loadSettings()
    }

    private func loadSettings() {
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }

    private func saveSettings() {
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }

    func resetAllData() {
        print("모든 데이터가 초기화됩니다.")
    }
}
