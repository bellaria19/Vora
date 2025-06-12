//
//  SettingsView.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool = false
}

struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section {}
            Section("앱 설정") {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundStyle(.primary)
                        .frame(width: 24, height: 24)

//                    Text("다크 모드")
//
//                    Spacer()

                    Toggle("다크 모드", isOn: $viewModel.isDarkMode)
                }
            }
        }
        .navigationTitle("설정")
    }
}
