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
                    )
                )
                .onTapGesture {
                    viewModel.toggleOverlay()
                }

                if viewModel.showOverlay {
                    ViewerOverlay(
                        fileInfo: viewModel.fileInfo,
                        currentPage: viewModel.currentPage,
                        totalPages: viewModel.totalPages
                    ) {
                        print("onSettings")
                    } onPreviousPage: {
                        viewModel.goToPreviousPage()
                    } onNextPage: {
                        viewModel.goToNextPage()
                    } onPageChange: { page in
                        viewModel.goToPage(page)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
