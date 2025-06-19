//
//  PDFKitView.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import PDFKit
import SwiftUI

struct PDFKitView: UIViewRepresentable {
    let url: URL
    @Binding var currentPage: Int
    @Binding var totalPages: Int
    @Binding var pdfView: PDFView?
    let settings: PDFViewerSettings

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        applySettings(to: pdfView)

        DispatchQueue.main.async {
            self.pdfView = pdfView
        }

        if let document = PDFDocument(url: url) {
            pdfView.document = document
            DispatchQueue.main.async {
                totalPages = document.pageCount
            }
        }

        // 페이지 변경 알림 설정
        NotificationCenter.default.addObserver(
            forName: .PDFViewPageChanged,
            object: pdfView,
            queue: .main
        ) { _ in
            if let page = pdfView.currentPage,
               let document = pdfView.document
            {
                currentPage = document.index(for: page) + 1
            }
        }

        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        applySettings(to: uiView)
    }

    private func applySettings(to pdfView: PDFView) {
        // 디스플레이 모드 설정
        pdfView.displayMode = settings.displayMode.pdfKitDisplayMode
        
        // 스크롤 방향 설정
        pdfView.displayDirection = settings.displayDirection == .horizontal ? .horizontal : .vertical
        
        // 자동 크기 조절 설정
       pdfView.autoScales = true
        
//        if !settings.autoScales {
//            // 페이지 맞춤 설정
//            switch settings.pageFitting {
//            case .fitToWidth:
//                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
//                pdfView.maxScaleFactor = 4.0
//                pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
//            case .fitToHeight:
//                if let page = pdfView.currentPage {
//                    let viewHeight = pdfView.bounds.height
//                    let pageHeight = page.bounds(for: pdfView.displayBox).height
//                    pdfView.scaleFactor = viewHeight / pageHeight
//                }
//            case .fitToPage:
//                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
//            }
//            
            // 확대/축소 설정
//            if !settings.autoScales {
//                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit * settings.zoomScale
//            }
//        }
        
        // 배경색 설정
        pdfView.backgroundColor = UIColor(settings.backgroundColor)
    }
}
