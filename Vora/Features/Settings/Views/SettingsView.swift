//
//  SettingsView.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import Inject
import SwiftUI

struct SettingsView: View {
    @ObserveInjection var inject
    @EnvironmentObject private var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("앱 설정") {
                Toggle(isOn: $viewModel.isDarkMode) {
                    settingsLabel("다크 모드", iconName: "moon.fill")
                }

                Button {
                    viewModel.showResetAlert = true
                } label: {
                    Label {
                        Text("데이터 초기화")
                            .foregroundStyle(.red)
                    } icon: {
                        Image(systemName: "trash.fill")
                            .foregroundStyle(viewModel.isDarkMode ? Color.white : .blue)
                            .frame(width: 24, height: 24)
                    }
                }
            }

            Section("뷰어 설정") {
                NavigationLink {
                    TextViewerSettingsView()
                } label: {
                    settingsLabel("텍스트 뷰어", iconName: "doc.text.fill")
                }

                NavigationLink {
                    ImageViewerSettingsView()
                } label: {
                    settingsLabel("이미지 뷰어", iconName: "photo.fill")
                }

                NavigationLink {
                    PDFViewerSettingsview()
                } label: {
                    settingsLabel("PDF 뷰어", iconName: "doc.richtext.fill")
                }

                NavigationLink {
                    EPUBViewerSettingsView()
                } label: {
                    settingsLabel("EPUB 뷰어", iconName: "book.fill")
                }
            }

            Section("지원") {
                NavigationLink {
                    AboutView(viewModel: viewModel)
                } label: {
                    settingsLabel("앱 정보", iconName: "info.circle.fill")
                }
            }
        }
        .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)
        .navigationTitle("설정")
        .alert("데이터 초기화", isPresented: $viewModel.showResetAlert, actions: {
            Button("초기화", role: .destructive) {
                viewModel.resetAllData()
            }
            Button("취소", role: .cancel) {}
        }, message: {
            Text("앱의 모든 파일이 삭제됩니다. 이 작업은 되돌릴 수 없습니다.")
        })
        .enableInjection()
    }

    @ViewBuilder
    private func settingsLabel(_ title: String, iconName: String) -> some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: iconName)
                .foregroundStyle(viewModel.isDarkMode ? Color.white : .blue)
                .frame(width: 24, height: 24)
        }
    }
}
