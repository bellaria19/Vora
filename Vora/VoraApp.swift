//
//  VoraApp.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

@main
struct VoraApp: App {
    @StateObject private var documentPickerViewModel = DocumentPickerViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(documentPickerViewModel)
                .environmentObject(settingsViewModel)
        }
    }
}
