//
//  TextViewerView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI
import UIKit


// MARK: - 텍스트 뷰어 화면

struct TextViewerView: View {
    @StateObject private var viewModel: TextViewerViewModel
    @State private var showSettingsSheet = false

    init(fileInfo: FileInfo) {
        _viewModel = StateObject(wrappedValue: TextViewerViewModel(fileInfo: fileInfo))
    }

    var body: some View {
        ZStack {
            Color(viewModel.settings.backgroundColor)
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
                    fileInfo: viewModel.fileInfo,
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
            await viewModel.loadTextFile(from: viewModel.fileInfo.url)
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
