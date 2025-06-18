//
//  ImageViewerSettingsView.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import SwiftUI

struct ImageViewerSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let settings: ImageViewerSettings
    let onSettingsChange: (ImageViewerSettings) -> Void

    @State private var isActivateRotation: Bool = false

    @State private var localSettings: ImageViewerSettings

    init(settings: ImageViewerSettings, onSettingsChange: @escaping (ImageViewerSettings) -> Void) {
        self.settings = settings
        self.onSettingsChange = onSettingsChange
        self._localSettings = State(initialValue: settings)
    }

    var body: some View {
        NavigationView {
            ImageViewerSettingsView(settings: settings, onSettingsChange: { newSettings in
                onSettingsChange(newSettings)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("적용") {
                        onSettingsChange(localSettings)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ImageViewerSettingsView: View {
    let settings: ImageViewerSettings
    let onSettingsChange: (ImageViewerSettings) -> Void

    @State private var isActivateRotation: Bool = false

    @State private var localSettings: ImageViewerSettings

    init(settings: ImageViewerSettings, onSettingsChange: @escaping (ImageViewerSettings) -> Void) {
        self.settings = settings
        self.onSettingsChange = onSettingsChange
        self._localSettings = State(initialValue: settings)
    }

    var body: some View {
        Form {
            Section("뷰어 설정") {
                Text("배경 색상")

                Toggle("화면 회전", isOn: $isActivateRotation)
            }
        }
        .navigationTitle("이미지 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}
