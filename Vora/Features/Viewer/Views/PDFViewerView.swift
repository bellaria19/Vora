//
//  PDFViewerView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import PDFKit
import SwiftUI

struct PDFViewerView: View {
    @StateObject private var viewModel: PDFViewerViewModel
    @State private var showSettingsSheet = false

    init(fileInfo: FileInfo) {
        _viewModel = StateObject(wrappedValue: PDFViewerViewModel(fileInfo: fileInfo))
    }

    var body: some View {
        GeometryReader { _ in

            ZStack {
                PDFKitView(
                    url: viewModel.fileInfo.url,
                    currentPage: $viewModel.currentPage,
                    totalPages: $viewModel.totalPages,
                    pdfView: Binding(
                        get: { viewModel.pdfView },
                        set: { viewModel.setPDFView($0) }
                    ),
                    settings: viewModel.settings
                ) {
                    viewModel.toggleOverlay()
                }
//                .onTapGesture {
//                    viewModel.toggleOverlay()
//                }

                if viewModel.showOverlay {
                    ViewerOverlay(
                        fileInfo: viewModel.fileInfo,
                        currentPage: viewModel.currentPage,
                        totalPages: viewModel.totalPages,
                        onSettings: { showSettingsSheet = true },
                        onPreviousPage: { viewModel.goToPreviousPage() },
                        onNextPage: { viewModel.goToNextPage() },
                        onPageChange: { page in viewModel.goToPage(page) }
                    )
                }
            }
            .backgroundStyle(viewModel.settings.backgroundColor)
            .onChange(of: viewModel.totalPages) {
                viewModel.checkToShowContinueReadingPrompt()
            }
            .onDisappear {
                viewModel.saveCurrentPage()
            }
            .alert("이전 페이지", isPresented: $viewModel.showContinueReadingPrompt) {
                Button("이어보기") {
                    viewModel.continueReading()
                }
                Button("처음부터", role: .cancel) {
                    viewModel.startFromBeginning()
                }
            } message: {
                Text("최근에 읽던 페이지부터 이어서 보시겠습니까?")
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showSettingsSheet) {
            PDFViewerSettingsSheet(settings: viewModel.settings) { newSettings in
                viewModel.updateSettings(newSettings)
            }
            .presentationDetents([.medium])
        }
    }
}
