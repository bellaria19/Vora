//
//  PDFViewerSettingsview.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import SwiftUI

struct PDFViewerSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let settings: PDFViewerSettings
    let onSettingsChange: (PDFViewerSettings) -> Void

    @State private var localSettings: PDFViewerSettings

    init(settings: PDFViewerSettings, onSettingsChange: @escaping (PDFViewerSettings) -> Void) {
        self.settings = settings
        self.onSettingsChange = onSettingsChange
        self._localSettings = State(initialValue: settings)
    }

    var body: some View {
        NavigationView {
            PDFViewerSettingsView(settings: settings, onSettingsChange: { newSettings in
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

struct PDFViewerSettingsView: View {
    let settings: PDFViewerSettings
    let onSettingsChange: (PDFViewerSettings) -> Void

    @State private var isRTL: Bool = false

    @State private var localSettings: PDFViewerSettings

    init(settings: PDFViewerSettings, onSettingsChange: @escaping (PDFViewerSettings) -> Void) {
        self.settings = settings
        self.onSettingsChange = onSettingsChange
        self._localSettings = State(initialValue: settings)
    }

    var body: some View {
        Form {
            Section("모드") {
                Picker("모드", selection: $localSettings.viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("뷰어 설정") {
                Text("배경 색상")

                Toggle("RTL", isOn: $isRTL)
            }
        }
        .navigationTitle("텍스트 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PDFViewerSettings {
    var viewMode: ViewMode = .page
    var backgroundColor: UIColor = .systemBackground

    static let defaultSettings = PDFViewerSettings()
}

enum ViewMode: String, CaseIterable {
    case scroll
    case page

    var displayName: String {
        switch self {
        case .scroll: return "스크롤"
        case .page: return "페이지"
        }
    }
}
