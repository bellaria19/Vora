//
//  TextViewerSettingsView.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import SwiftUI

struct TextViewerSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let settings: TextViewerSettings
    let onSettingsChange: (TextViewerSettings) -> Void
    
    @State private var localSettings: TextViewerSettings
    
    init(settings: TextViewerSettings, onSettingsChange: @escaping (TextViewerSettings) -> Void) {
        self.settings = settings
        self.onSettingsChange = onSettingsChange
        self._localSettings = State(initialValue: settings)
    }
    
    var body: some View {
        NavigationView {
            TextViewerSettingsView(settings: settings) { newSettings in
                onSettingsChange(newSettings)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
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

struct TextViewerSettingsView: View {
    let settings: TextViewerSettings
    let onSettingsChange: (TextViewerSettings) -> Void
    
    @State private var localSettings: TextViewerSettings
    
    init(settings: TextViewerSettings, onSettingsChange: @escaping (TextViewerSettings) -> Void) {
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
                
            Section("테마") {
                HStack(spacing: 16) {
                    ForEach(0 ..< TextViewerSettings.themes.count, id: \.self) { idx in
                        Button(action: {
                            localSettings.customTextColor = TextViewerSettings.themes[idx].0
                            localSettings.customBackgroundColor = TextViewerSettings.themes[idx].1
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(TextViewerSettings.themes[idx].1))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                (localSettings.customTextColor == TextViewerSettings.themes[idx].0 && localSettings.customBackgroundColor == TextViewerSettings.themes[idx].1) ? Color.accentColor : Color.gray.opacity(0.3),
                                                lineWidth: 2
                                            )
                                    )
                                Text("가")
                                    .foregroundColor(Color(TextViewerSettings.themes[idx].0))
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
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
                    in: 16...34,
                    step: 2
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
                    value: Binding(
                        get: { localSettings.fontWeightStep },
                        set: {
                            localSettings.fontWeightStep = $0
                            localSettings.fontWeight = TextViewerSettings.fontWeightSteps[$0 - 1]
                        }
                    ),
                    in: 1...9
                ) {
                    HStack {
                        Image(systemName: "bold")
                            .foregroundStyle(.secondary, Color.white)
                            .frame(width: 24, height: 24)
                            
                        Text("글자 두께")
                        Text("\(localSettings.fontWeightStep)")
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
                        Text("\(Int(localSettings.lineSpacing))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
                
            Section("여백 설정") {
                Stepper(
                    value: $localSettings.marginHorizontal,
                    in: 8...32,
                    step: 2
                ) {
                    HStack {
                        Image(systemName: "arrow.left.and.right")
                            .frame(width: 24, height: 24)
                            
                        Text("가로 여백")
                        Text("\(Int(localSettings.marginHorizontal))pt")
                            .foregroundStyle(.secondary)
                    }
                }
                    
                Stepper(
                    value: $localSettings.marginVertical,
                    in: 8...32,
                    step: 2
                ) {
                    HStack {
                        Image(systemName: "arrow.up.and.down")
                            .frame(width: 24, height: 24)
                            
                        Text("세로 여백")
                        Text("\(Int(localSettings.marginVertical))pt")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        
        .navigationTitle("텍스트 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}
