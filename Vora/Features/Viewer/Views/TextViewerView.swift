//
//  TextViewerView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI
import UIKit

// MARK: - 텍스트 뷰어 설정

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

struct TextViewerSettings {
    var fontSize: CGFloat = 16
    var lineSpacing: CGFloat = 4
    var fontWeightStep: Int = 4 { // 1~9, 기본값 4(.regular)
        didSet {
            fontWeight = TextViewerSettings.fontWeightSteps[fontWeightStep - 1]
        }
    }

    var fontFamily: String = "System"
    var textColor: UIColor = .label
    var backgroundColor: UIColor = .systemBackground
    var marginHorizontal: CGFloat = 16
    var marginVertical: CGFloat = 16
    var viewMode: ViewMode = .scroll

    // 프리셋 색상
    static let colorPresets: [(UIColor, UIColor)] = [
        (.label, .systemBackground), // 기본
        (.white, .black), // 다크
        (.black, .white), // 라이트
        (.systemYellow, .systemGray) // 예시 프리셋
    ]
    var colorPresetIndex: Int? = 0 // 0~3: 프리셋, nil: 사용자 지정

    // 사용자 지정 색상
    var customTextColor: UIColor = .label
    var customBackgroundColor: UIColor = .systemBackground

    // 실제 적용 색상
    var effectiveTextColor: UIColor {
        if let idx = colorPresetIndex, idx < Self.colorPresets.count {
            return Self.colorPresets[idx].0
        } else {
            return customTextColor
        }
    }

    var effectiveBackgroundColor: UIColor {
        if let idx = colorPresetIndex, idx < Self.colorPresets.count {
            return Self.colorPresets[idx].1
        } else {
            return customBackgroundColor
        }
    }

//    enum ViewMode: String, CaseIterable {
//        case scroll
//        case page
//
//        var displayName: String {
//            switch self {
//            case .scroll: return "스크롤"
//            case .page: return "페이지"
//            }
//        }
//    }

    static let defaultSettings = TextViewerSettings(
        fontSize: 16,
        lineSpacing: 4,
        fontWeightStep: 4,
        fontFamily: "System",
        textColor: .label,
        backgroundColor: .systemBackground,
        marginHorizontal: 16,
        marginVertical: 16,
        viewMode: .scroll,
    )

    var fontWeight: UIFont.Weight = .regular
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
}

// MARK: - 텍스트 뷰어 화면

struct TextViewerView: View {
    let fileInfo: FileInfo
    @StateObject private var viewModel = TextViewerViewModel()
    @State private var showSettingsSheet = false

    var body: some View {
        ZStack {
            Color(viewModel.settings.effectiveBackgroundColor)
                .ignoresSafeArea()

            if viewModel.isLoading {
                LoadingView()
//            } else if let errorMessage = viewModel.errorMessage {
//                ErrorView()
            } else {
                UIKitTextView(viewModel: viewModel) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.showOverlay.toggle()
                    }
                }
            }

            if viewModel.showOverlay {
                ViewerOverlay(
                    fileInfo: fileInfo,
                    currentPage: viewModel.currentPage,
                    totalPages: viewModel.totalPages,
                    onSettings: { showSettingsSheet = true },
                    onPreviousPage: { viewModel.previousPage() },
                    onNextPage: { viewModel.nextPage() },
                    onPageChange: { page in viewModel.goToPage(page) }
                )
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await viewModel.loadTextFile(from: fileInfo.url)
        }
        .sheet(isPresented: $showSettingsSheet) {
            TextViewerSettingsSheet(
                settings: viewModel.settings,
                onSettingsChange: { newSettings in
                    viewModel.updateSettings(newSettings)
                }
            )
        }
    }
}
