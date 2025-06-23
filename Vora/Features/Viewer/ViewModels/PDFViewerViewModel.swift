//
//  PDFViewerViewModel.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import PDFKit
import SwiftUI

@MainActor
class PDFViewerViewModel: ObservableObject {
    @Published var showOverlay: Bool = false
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var pdfView: PDFView?
    @Published var settings: PDFViewerSettings
    
    @Published var showContinueReadingPrompt: Bool = false
    
    private var lastPage: Int?

    let fileInfo: FileInfo

    init(fileInfo: FileInfo) {
        self.fileInfo = fileInfo
        self.settings = PDFViewerSettings.load()
        self.lastPage = UserDefaults.standard.integer(forKey: lastPagePreferenceKey)
        
        if let lastPage = self.lastPage, lastPage > 1 {
            // pdf 로드 이후에 물어봐야 제대로 동작함
//            showContinueReadingPrompt = true
        }
    }
    
    var lastPagePreferenceKey: String {
        "lastPage_\(fileInfo.id.uuidString)"
    }
    
    func checkToShowContinueReadingPrompt() {
        if let lastPage = self.lastPage, lastPage > 0, totalPages > 1 {
            self.showContinueReadingPrompt = true
        }
    }

    func saveCurrentPage() {
        UserDefaults.standard.set(currentPage, forKey: lastPagePreferenceKey)
    }

    func updateSettings(_ newSettings: PDFViewerSettings) {
        settings = newSettings
        settings.save()
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

    func continueReading() {
        if let lastPage = lastPage {
            goToPage(lastPage)
        }
        showContinueReadingPrompt = false
    }
    
    func startFromBeginning() {
        showContinueReadingPrompt = false
    }
}
