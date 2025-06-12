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

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true

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

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
