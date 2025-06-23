//
//  ImageViewerSettingsView.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import SwiftUI

struct ImageViewerSettings: Codable, Equatable {
    var backgroundColor: Color = ViewerTheme.defaultBackgroundColor
    var isRotationEnabled: Bool = false

    static let defaultSettings = ImageViewerSettings()

    // UserDefaults 키
    private static let settingsKey = "ImageViewerSettings"

    // 설정 저장
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.settingsKey)
        }
    }

    // 설정 불러오기
    static func load() -> ImageViewerSettings {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(ImageViewerSettings.self, from: data)
        {
            return settings
        }
        return defaultSettings
    }

    // Codable 구현을 위한 CodingKeys
    enum CodingKeys: String, CodingKey {
        case backgroundColor
        case isRotationEnabled
    }

    // Color 인코딩
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backgroundColor.toHexString(), forKey: .backgroundColor)
        try container.encode(isRotationEnabled, forKey: .isRotationEnabled)
    }

    // Color 디코딩
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hexString = try container.decode(String.self, forKey: .backgroundColor)
        backgroundColor = Color(hex: hexString) ?? ViewerTheme.defaultBackgroundColor
        isRotationEnabled = try container.decode(Bool.self, forKey: .isRotationEnabled)
    }

    init(backgroundColor: Color = ViewerTheme.defaultBackgroundColor, isRotationEnabled: Bool = false) {
        self.backgroundColor = backgroundColor
        self.isRotationEnabled = isRotationEnabled
    }

    static func == (lhs: ImageViewerSettings, rhs: ImageViewerSettings) -> Bool {
        lhs.backgroundColor.toHexString() == rhs.backgroundColor.toHexString() &&
            lhs.isRotationEnabled == rhs.isRotationEnabled
    }
}

struct ImageViewerSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let settings: ImageViewerSettings
    let onSettingsChange: (ImageViewerSettings) -> Void

    @State private var localSettings: ImageViewerSettings

    init(settings: ImageViewerSettings, onSettingsChange: @escaping (ImageViewerSettings) -> Void) {
        self.settings = settings
        self.onSettingsChange = onSettingsChange
        _localSettings = State(initialValue: settings)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("뷰어 설정") {
                    HStack {
                        Text("배경 색상")

                        Spacer()

                        ForEach(0 ..< ViewerTheme.themes.count, id: \.self) { idx in
                            let theme = ViewerTheme.themes[idx]

                            Button {
                                localSettings.backgroundColor = theme
                            } label: {
                                Circle()
                                    .fill(theme)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                localSettings.backgroundColor == theme ? Color.accentColor : Color.gray.opacity(0.3),
                                                lineWidth: 2
                                            )
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    Toggle("화면 회전", isOn: Binding(
                        get: { localSettings.isRotationEnabled },
                        set: { newValue in
                            localSettings.isRotationEnabled = newValue
                        }
                    ))
                }
            }
            .navigationTitle("이미지 설정")
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
