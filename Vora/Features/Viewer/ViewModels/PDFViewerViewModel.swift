//
//  PDFViewerViewModel.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import PDFKit
import SwiftUI

// struct PDFViewerSettings {
//
// }

@MainActor
class PDFViewerViewModel: ObservableObject {
    @Published var showOverlay: Bool = false
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var pdfView: PDFView?
//    @Published var settings = PDFViewerSettings()

    let fileInfo: FileInfo

    init(fileInfo: FileInfo) {
        self.fileInfo = fileInfo
    }

    func setPDFView(_ pdfView: PDFView?) {
        self.pdfView = pdfView
    }

    func toggleOverlay() {
        showOverlay.toggle()
    }

    func goToPreviousPage() {
        guard let pdfView = pdfView else { return }
        pdfView.goToPreviousPage(nil)
    }

    func goToNextPage() {
        guard let pdfView = pdfView else { return }
        pdfView.goToNextPage(nil)
    }

    func goToPage(_ pageNumber: Int) {
        guard let pdfView = pdfView,
              let document = pdfView.document,
              pageNumber > 0 && pageNumber <= document.pageCount else { return }

        let page = document.page(at: pageNumber - 1) // 0-based index
        pdfView.go(to: page!)
    }

    // 좌 25% | 중앙 50% | 우 25%
    private func handleScreenTap(location: CGPoint, screenSize: CGSize) {
        let leftRegionWidth = screenSize.width * 0.25 // 왼쪽 25%
        let rightRegionWidth = screenSize.width * 0.25 // 오른쪽 25%

        if location.x < leftRegionWidth {
            // 왼쪽 영역: 이전 페이지
            goToPreviousPage()
        } else if location.x > screenSize.width - rightRegionWidth {
            // 오른쪽 영역: 다음 페이지
            goToNextPage()
        } else {
            // 중앙 영역: 오버레이 토글
            withAnimation(.easeInOut(duration: 0.3)) {
                showOverlay.toggle()
            }
        }
    }
}
