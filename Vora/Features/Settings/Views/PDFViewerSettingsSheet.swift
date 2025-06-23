//
//  PDFViewerSettingsview.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import PDFKit
import SwiftUI

struct PDFViewerSettings: Codable, Equatable {
    var backgroundColor: Color = ViewerTheme.defaultBackgroundColor
    var displayMode: PDFDisplayMode = .singlePage
//    var displayDirection: PDFDisplayDirection = .vertical

    static let defaultSettings = PDFViewerSettings()

    private static let settingsKey = "PDFViewerSettings"

    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.settingsKey)
        }
    }

    static func load() -> PDFViewerSettings {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(PDFViewerSettings.self, from: data)
        {
            return settings
        }
        return defaultSettings
    }

    enum CodingKeys: String, CodingKey {
        case backgroundColor
        case displayMode
//        case displayDirection
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backgroundColor.toHexString(), forKey: .backgroundColor)
        try container.encode(displayMode, forKey: .displayMode)
//        try container.encode(displayDirection, forKey: .displayDirection)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hexString = try container.decode(String.self, forKey: .backgroundColor)
        backgroundColor = Color(hex: hexString) ?? ViewerTheme.defaultBackgroundColor
        displayMode = try container.decode(PDFDisplayMode.self, forKey: .displayMode)
//        displayDirection = try container.decode(PDFDisplayDirection.self, forKey: .displayDirection)
    }

    init() {}

    static func == (lhs: PDFViewerSettings, rhs: PDFViewerSettings) -> Bool {
        lhs.backgroundColor.toHexString() == rhs.backgroundColor.toHexString() &&
            lhs.displayMode == rhs.displayMode
//            lhs.displayDirection == rhs.displayDirection
    }
}

enum PDFDisplayMode: String, CaseIterable, Codable {
    case singlePage
    // case singlePageContinuous
    case twoPages
    // case twoPagesContinuous

    var displayName: String {
        switch self {
        case .singlePage: return "단일 페이지"
        // case .singlePageContinuous: return "연속 단일 페이지"
        case .twoPages: return "두 페이지"
            // case .twoPagesContinuous: return "연속 두 페이지"
        }
    }

    var pdfKitDisplayMode: PDFKit.PDFDisplayMode {
        switch self {
        case .singlePage: return .singlePage
        // case .singlePageContinuous: return .singlePageContinuous
        case .twoPages: return .twoUp
            // case .twoPagesContinuous: return .twoUpContinuous
        }
    }
}

// enum PDFDisplayDirection: String, CaseIterable, Codable {
//    case horizontal
//    case vertical
//
//    var displayName: String {
//        switch self {
//        case .horizontal: return "가로 스크롤"
//        case .vertical: return "세로 스크롤"
//        }
//    }
// }

struct PDFViewerSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let settings: PDFViewerSettings
    let onSettingsChange: (PDFViewerSettings) -> Void

    @State private var localSettings: PDFViewerSettings

    init(settings: PDFViewerSettings, onSettingsChange: @escaping (PDFViewerSettings) -> Void) {
        self.settings = settings
        self.onSettingsChange = onSettingsChange
        _localSettings = State(initialValue: settings)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("뷰어 설정") {
                    Picker("레이아웃", selection: $localSettings.displayMode) {
                        ForEach(PDFDisplayMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }

//                    Picker("스크롤 방향", selection: $localSettings.displayDirection) {
//                        ForEach(PDFDisplayDirection.allCases, id: \.self) { direction in
//                            Text(direction.displayName).tag(direction)
//                        }
//                    }
                }

                Section("색상") {
                    ColorPicker("배경 색상", selection: $localSettings.backgroundColor)
                }
            }
            .navigationTitle("PDF 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: localSettings) { _, newSettings in
            onSettingsChange(newSettings)
        }
    }
}

// struct PDFViewerSettingsView: View {
//    let settings: PDFViewerSettings
//    let onSettingsChange: (PDFViewerSettings) -> Void
//
//    @State private var localSettings: PDFViewerSettings
//
//    init(settings: PDFViewerSettings, onSettingsChange: @escaping (PDFViewerSettings) -> Void) {
//        self.settings = settings
//        self.onSettingsChange = onSettingsChange
//        self._localSettings = State(initialValue: settings)
//    }
//
//    var body: some View {
//        Form {
//            Section("표시 모드") {
//                Picker("페이지 모드", selection: $localSettings.displayMode) {
//                    ForEach(PDFDisplayMode.allCases, id: \.self) { mode in
//                        Text(mode.displayName).tag(mode)
//                    }
//                }
//
//                Picker("스크롤 방향", selection: $localSettings.displayDirection) {
//                    ForEach(PDFDisplayDirection.allCases, id: \.self) { direction in
//                        Text(direction.displayName).tag(direction)
//                    }
//                }
//            }
//
//            Section("크기 조절") {
//                Toggle("자동 크기 조절", isOn: $localSettings.autoScales)
//
//                if !localSettings.autoScales {
//                    Picker("페이지 맞춤", selection: $localSettings.pageFitting) {
//                        ForEach(PDFViewFitting.allCases, id: \.self) { fitting in
//                            Text(fitting.displayName).tag(fitting)
//                        }
//                    }
//
//                    HStack {
//                        Text("확대/축소")
//                        Slider(
//                            value: $localSettings.zoomScale,
//                            in: 0.5 ... 3.0,
//                            step: 0.1
//                        )
//                        Text(String(format: "%.1fx", localSettings.zoomScale))
//                    }
//                }
//            }
//
//            Section("색상") {
//                ColorPicker("배경 색상", selection: $localSettings.backgroundColor)
//            }
//        }
//        .navigationTitle("PDF 설정")
//        .navigationBarTitleDisplayMode(.inline)
//        .onChange(of: localSettings, { _ ,newSettings in
//            onSettingsChange(newSettings)
//        }
//
//    }
// }
