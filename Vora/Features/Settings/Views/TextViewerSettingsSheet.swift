//
//  TextViewerSettingsView.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import SwiftUI

extension TextViewerSettings {
    static let themes: [(UIColor, UIColor)] = [
        // 1. 순수 흰색 배경 + 검정 텍스트
        (.black, .white),
        // 2. 연한 회색 배경 + 검정 텍스트
        (.black, UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)),
        // 3. 크림/아이보리 배경 + 진한 갈색 텍스트
        (UIColor(red: 0.36, green: 0.23, blue: 0.13, alpha: 1.0), UIColor(red: 1.0, green: 0.98, blue: 0.89, alpha: 1.0)),
        // 4. 순수 검정 배경 + 흰색 텍스트
        (.white, .black),
        // 5. 진한 회색 배경 + 밝은 회색 텍스트
        (UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0), UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)),
        // 6. 세피아 다크(갈색 계열 어두운 배경)
        (UIColor(red: 0.82, green: 0.72, blue: 0.56, alpha: 1.0), UIColor(red: 0.23, green: 0.17, blue: 0.13, alpha: 1.0))
    ]
}

struct TextViewerSettings: Codable, Equatable {
    var fontSize: CGFloat = 16
    var lineSpacing: CGFloat = 4
    var fontWeightStep: Int = 4 // 1~9, 기본값 4(.regular)
    var fontFamily: String = "System"
    var textColor: UIColor = .label
    var backgroundColor: UIColor = .systemBackground
    var marginHorizontal: CGFloat = 16
    var marginVertical: CGFloat = 16
    var viewMode: ViewMode = .scroll

    var fontWeight: UIFont.Weight {
        TextViewerSettings.fontWeightSteps[safe: fontWeightStep - 1] ?? .regular
    }

    // MARK: - Save and Load

    static let defaultSettings = TextViewerSettings()
    private static let settingsKey = "TextViewerSettings"

    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.settingsKey)
        }
    }

    static func load() -> TextViewerSettings {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(TextViewerSettings.self, from: data)
        {
            return settings
        }
        return .defaultSettings
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case fontSize, lineSpacing, fontWeightStep, fontFamily, textColor, backgroundColor, marginHorizontal, marginVertical, viewMode
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(lineSpacing, forKey: .lineSpacing)
        try container.encode(fontWeightStep, forKey: .fontWeightStep)
        try container.encode(fontFamily, forKey: .fontFamily)
        try container.encode(Color(textColor).toHexString(), forKey: .textColor)
        try container.encode(Color(backgroundColor).toHexString(), forKey: .backgroundColor)
        try container.encode(marginHorizontal, forKey: .marginHorizontal)
        try container.encode(marginVertical, forKey: .marginVertical)
        try container.encode(viewMode, forKey: .viewMode)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        lineSpacing = try container.decode(CGFloat.self, forKey: .lineSpacing)
        fontWeightStep = try container.decode(Int.self, forKey: .fontWeightStep)
        fontFamily = try container.decode(String.self, forKey: .fontFamily)
        
        let textColorHex = try container.decode(String.self, forKey: .textColor)
        textColor = UIColor(Color(hex: textColorHex) ?? .primary)

        let backgroundColorHex = try container.decode(String.self, forKey: .backgroundColor)
        backgroundColor = UIColor(Color(hex: backgroundColorHex) ?? Color(.systemBackground))

        marginHorizontal = try container.decode(CGFloat.self, forKey: .marginHorizontal)
        marginVertical = try container.decode(CGFloat.self, forKey: .marginVertical)
        viewMode = try container.decode(ViewMode.self, forKey: .viewMode)
    }
    
    init() {}

    // MARK: - Equatable

    static func == (lhs: TextViewerSettings, rhs: TextViewerSettings) -> Bool {
        lhs.fontSize == rhs.fontSize &&
            lhs.lineSpacing == rhs.lineSpacing &&
            lhs.fontWeightStep == rhs.fontWeightStep &&
            lhs.fontFamily == rhs.fontFamily &&
            Color(lhs.textColor).toHexString() == Color(rhs.textColor).toHexString() &&
            Color(lhs.backgroundColor).toHexString() == Color(rhs.backgroundColor).toHexString() &&
            lhs.marginHorizontal == rhs.marginHorizontal &&
            lhs.marginVertical == rhs.marginVertical &&
            lhs.viewMode == rhs.viewMode
    }

    var uiFont: UIFont {
        switch fontFamily {
        case "System":
            return UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        case "Monospace":
            return UIFont.monospacedSystemFont(ofSize: fontSize, weight: fontWeight)
        default:
            return UIFont(name: fontFamily, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
    }

    var paragraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.paragraphSpacing = lineSpacing / 2
        return style
    }
    
    // UIFont.Weight 매핑
    static let fontWeightSteps: [UIFont.Weight] = [
        .ultraLight, // 1
        .thin, // 2
        .light, // 3
        .regular, // 4
        .medium, // 5
        .semibold, // 6
        .bold, // 7
        .heavy, // 8
        .black // 9
    ]
    static func fontWeightLabel(for step: Int) -> String {
        switch step {
        case 1: return "초얇게"
        case 2: return "얇게"
        case 3: return "라이트"
        case 4: return "보통"
        case 5: return "중간"
        case 6: return "세미볼드"
        case 7: return "볼드"
        case 8: return "헤비"
        case 9: return "블랙"
        default: return ""
        }
    }
}

struct TextViewerSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSettingsChange: (TextViewerSettings) -> Void
    
    @State private var localSettings: TextViewerSettings
    private let initialSettings: TextViewerSettings
    
    init(settings: TextViewerSettings, onSettingsChange: @escaping (TextViewerSettings) -> Void) {
        initialSettings = settings
        self.onSettingsChange = onSettingsChange
        _localSettings = State(initialValue: settings)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("모드") {
                    Picker("모드", selection: $localSettings.viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("색상") {
                    ColorPicker("글자 색상", selection: Binding(
                        get: { Color(self.localSettings.textColor) },
                        set: { self.localSettings.textColor = UIColor($0) }
                    ), supportsOpacity: false)
                    ColorPicker("배경 색상", selection: Binding(
                        get: { Color(self.localSettings.backgroundColor) },
                        set: { self.localSettings.backgroundColor = UIColor($0) }
                    ), supportsOpacity: false)
                }
                
                Section("글꼴 설정") {
                    Picker(selection: $localSettings.fontFamily) {
                        Text("시스템").tag("System")
                        Text("고정폭").tag("Monospace")
                    } label: {
                        HStack {
                            Image(systemName: "textformat")
                                .frame(width: 24, height: 24)
                                
                            Text("글꼴")
                        }
                    }

                    Stepper(
                        value: $localSettings.fontSize,
                        in: 10...40,
                        step: 1
                    ) {
                        HStack {
                            Image(systemName: "textformat.size")
                                .frame(width: 24, height: 24)
                                
                            Text("글자 크기")
                            Text("\(Int(localSettings.fontSize))pt")
                                .foregroundStyle(.secondary)
                        }
                    }
                        
                    Stepper(
                        value: $localSettings.fontWeightStep,
                        in: 1...9
                    ) {
                        HStack {
                            Image(systemName: "bold")
                                .frame(width: 24, height: 24)
                                
                            Text("글자 두께")
                            Text(TextViewerSettings.fontWeightLabel(for: localSettings.fontWeightStep))
                                .foregroundStyle(.secondary)
                        }
                    }
                        
                    Stepper(
                        value: $localSettings.lineSpacing,
                        in: 0...10,
                        step: 1
                    ) {
                        HStack {
                            Image(systemName: "line.3.horizontal")
                                .frame(width: 24, height: 24)
                                
                            Text("줄 간격")
                            Text(String(format: "%.1f", localSettings.lineSpacing))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("여백") {
                    Stepper(value: $localSettings.marginHorizontal, in: 0...60, step: 2) {
                        Text("좌우 여백: \(Int(localSettings.marginHorizontal))")
                    }
                    Stepper(value: $localSettings.marginVertical, in: 0...60, step: 2) {
                        Text("상하 여백: \(Int(localSettings.marginVertical))")
                    }
                }
            }
            .navigationTitle("텍스트 뷰어 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            if localSettings != initialSettings {
                onSettingsChange(localSettings)
            }
        }
    }
}

// struct TextViewerSettingsView: View {
//     let settings: TextViewerSettings
//     let onSettingsChange: (TextViewerSettings) -> Void
    
//     @State private var localSettings: TextViewerSettings
    
//     init(settings: TextViewerSettings, onSettingsChange: @escaping (TextViewerSettings) -> Void) {
//         self.settings = settings
//         self.onSettingsChange = onSettingsChange
//         self._localSettings = State(initialValue: settings)
//     }
    
//     var body: some View {
//         Form {
//             Section("모드") {
//                 Picker("모드", selection: $localSettings.viewMode) {
//                     ForEach(ViewMode.allCases, id: \.self) { mode in
//                         Text(mode.displayName).tag(mode)
//                     }
//                 }
//                 .pickerStyle(.segmented)
//             }
                
//             Section("테마") {
//                 HStack(spacing: 16) {
//                     ForEach(0 ..< TextViewerSettings.themes.count, id: \.self) { idx in
//                         Button(action: {
//                             localSettings.customTextColor = TextViewerSettings.themes[idx].0
//                             localSettings.customBackgroundColor = TextViewerSettings.themes[idx].1
//                         }) {
//                             ZStack {
//                                 RoundedRectangle(cornerRadius: 8)
//                                     .fill(Color(TextViewerSettings.themes[idx].1))
//                                     .frame(width: 44, height: 44)
//                                     .overlay(
//                                         RoundedRectangle(cornerRadius: 8)
//                                             .stroke(
//                                                 (localSettings.customTextColor == TextViewerSettings.themes[idx].0 && localSettings.customBackgroundColor == TextViewerSettings.themes[idx].1) ? Color.accentColor : Color.gray.opacity(0.3),
//                                                 lineWidth: 2
//                                             )
//                                     )
//                                 Text("가")
//                                     .foregroundColor(Color(TextViewerSettings.themes[idx].0))
//                                     .font(.system(size: 20, weight: .bold))
//                             }
//                             .contentShape(Rectangle())
//                         }
//                         .buttonStyle(PlainButtonStyle())
//                     }
//                 }
//             }
                
//             Section("글꼴 설정") {
//                 Picker(selection: $localSettings.fontFamily) {
//                     Text("시스템").tag("System")
//                     Text("고정폭").tag("Monospace")
//                 } label: {
//                     HStack {
//                         Image(systemName: "textformat")
//                             .frame(width: 24, height: 24)
                            
//                         Text("글꼴")
//                     }
//                 }

//                 Stepper(
//                     value: $localSettings.fontSize,
//                     in: 16...34,
//                     step: 2
//                 ) {
//                     HStack {
//                         Image(systemName: "textformat.size")
//                             .frame(width: 24, height: 24)
                            
//                         Text("글자 크기")
//                         Text("\(Int(localSettings.fontSize))pt")
//                             .foregroundStyle(.secondary)
//                     }
//                 }
                    
//                 Stepper(
//                     value: Binding(
//                         get: { localSettings.fontWeightStep },
//                         set: {
//                             localSettings.fontWeightStep = $0
//                             localSettings.fontWeight = TextViewerSettings.fontWeightSteps[$0 - 1]
//                         }
//                     ),
//                     in: 1...9
//                 ) {
//                     HStack {
//                         Image(systemName: "bold")
//                             .foregroundStyle(.secondary, Color.white)
//                             .frame(width: 24, height: 24)
                            
//                         Text("글자 두께")
//                         Text("\(localSettings.fontWeightStep)")
//                             .foregroundStyle(.secondary)
//                     }
//                 }
                    
//                 Stepper(
//                     value: $localSettings.lineSpacing,
//                     in: 0...10,
//                     step: 1
//                 ) {
//                     HStack {
//                         Image(systemName: "line.3.horizontal")
//                             .frame(width: 24, height: 24)
                                
//                         Text("줄 간격")
//                         Text("\(Int(localSettings.lineSpacing))")
//                             .foregroundStyle(.secondary)
//                     }
//                 }
//             }
                
//             Section("여백 설정") {
//                 Stepper(
//                     value: $localSettings.marginHorizontal,
//                     in: 8...32,
//                     step: 2
//                 ) {
//                     HStack {
//                         Image(systemName: "arrow.left.and.right")
//                             .frame(width: 24, height: 24)
                            
//                         Text("가로 여백")
//                         Text("\(Int(localSettings.marginHorizontal))pt")
//                             .foregroundStyle(.secondary)
//                     }
//                 }
                    
//                 Stepper(
//                     value: $localSettings.marginVertical,
//                     in: 8...32,
//                     step: 2
//                 ) {
//                     HStack {
//                         Image(systemName: "arrow.up.and.down")
//                             .frame(width: 24, height: 24)
                            
//                         Text("세로 여백")
//                         Text("\(Int(localSettings.marginVertical))pt")
//                             .foregroundStyle(.secondary)
//                     }
//                 }
//             }
//         }
        
//         .navigationTitle("텍스트 설정")
//         .navigationBarTitleDisplayMode(.inline)
//     }
// }
