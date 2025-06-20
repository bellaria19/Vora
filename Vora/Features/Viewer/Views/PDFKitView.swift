//
//  PDFKitView.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

// import PDFKit
// import SwiftUI
//
// struct PDFKitView: UIViewRepresentable {
//    let url: URL
//    @Binding var currentPage: Int
//    @Binding var totalPages: Int
//    @Binding var pdfView: PDFView?
//    let settings: PDFViewerSettings
//
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        applySettings(to: pdfView)
//
//        DispatchQueue.main.async {
//            self.pdfView = pdfView
//        }
//
//        if let document = PDFDocument(url: url) {
//            pdfView.document = document
//            DispatchQueue.main.async {
//                totalPages = document.pageCount
//            }
//        }
//
//        // 페이지 변경 알림 설정
//        NotificationCenter.default.addObserver(
//            forName: .PDFViewPageChanged,
//            object: pdfView,
//            queue: .main
//        ) { _ in
//            if let page = pdfView.currentPage,
//               let document = pdfView.document
//            {
//                currentPage = document.index(for: page) + 1
//            }
//        }
//
//        return pdfView
//    }
//
//    func updateUIView(_ uiView: PDFView, context: Context) {
//        applySettings(to: uiView)
//    }
//
//    private func applySettings(to pdfView: PDFView) {
//        // 디스플레이 모드 설정
//        pdfView.displayMode = settings.displayMode.pdfKitDisplayMode
//
//        // 스크롤 방향 설정
//        pdfView.displayDirection = settings.displayDirection == .horizontal ? .horizontal : .vertical
//
//        // 자동 크기 조절 설정
//        pdfView.autoScales = true
//
//        // 배경색 설정
//        pdfView.backgroundColor = UIColor(settings.backgroundColor)
//    }
// }

import PDFKit
import SwiftUI

struct PDFKitView: UIViewRepresentable {
    let url: URL
    @Binding var currentPage: Int
    @Binding var totalPages: Int
    @Binding var pdfView: PDFView?
    let settings: PDFViewerSettings
    let onTap: () -> Void

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        // 기본 PDFView 설정
        setupPDFView(pdfView)
        applySettings(to: pdfView)
        
        // PDF 문서 로드
        if let document = PDFDocument(url: url) {
            pdfView.document = document
            DispatchQueue.main.async {
                totalPages = document.pageCount
            }
        }
        
        // 제스처 인식기 추가 (탭 + 스와이프만)
        setupGestureRecognizers(for: pdfView, context: context)
        
        // 페이지 변경 알림 설정
        setupPageChangeNotification(for: pdfView)
        
        // PDFView 참조 저장
        DispatchQueue.main.async {
            self.pdfView = pdfView
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        applySettings(to: pdfView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Setup Methods
    
    private func setupPDFView(_ pdfView: PDFView) {
        pdfView.backgroundColor = UIColor.systemBackground
        pdfView.autoScales = true
        pdfView.maxScaleFactor = 4.0
        pdfView.minScaleFactor = 0.25
    }
    
    private func setupGestureRecognizers(for pdfView: PDFView, context: Context) {
        // 1. 탭 제스처 (오버레이 토글 + 페이지 이동)
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        tapGesture.delegate = context.coordinator
        pdfView.addGestureRecognizer(tapGesture)
        
        // 2. 좌우 스와이프 제스처 (페이지 이동)
        let leftSwipe = UISwipeGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleSwipeLeft)
        )
        leftSwipe.direction = .left
        leftSwipe.delegate = context.coordinator
        pdfView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleSwipeRight)
        )
        rightSwipe.direction = .right
        rightSwipe.delegate = context.coordinator
        pdfView.addGestureRecognizer(rightSwipe)
        
        // Coordinator에 PDFView 참조 전달
        context.coordinator.pdfView = pdfView
    }
    
    private func setupPageChangeNotification(for pdfView: PDFView) {
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
    }
    
    private func applySettings(to pdfView: PDFView) {
        pdfView.displayMode = settings.displayMode.pdfKitDisplayMode
//        pdfView.displayDirection = settings.displayDirection == .horizontal ? .horizontal : .vertical
        pdfView.autoScales = true
        pdfView.backgroundColor = UIColor(settings.backgroundColor)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: PDFKitView
        var pdfView: PDFView?
        
        init(_ parent: PDFKitView) {
            self.parent = parent
        }
        
        // MARK: - Gesture Handlers
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            guard let view = gesture.view else { return }
            
            let screenWidth = view.bounds.width
            let leftRegion = screenWidth * 0.25 // 왼쪽 25%
            let rightRegion = screenWidth * 0.75 // 오른쪽 25%
            
            if location.x < leftRegion {
                // 왼쪽 영역: 이전 페이지
                goToPreviousPage()
            } else if location.x > rightRegion {
                // 오른쪽 영역: 다음 페이지
                goToNextPage()
            } else {
                // 중앙 영역: 오버레이 토글
                parent.onTap()
            }
        }
        
        @objc func handleSwipeLeft() {
            // 왼쪽으로 스와이프: 다음 페이지
            goToNextPage()
        }
        
        @objc func handleSwipeRight() {
            // 오른쪽으로 스와이프: 이전 페이지
            goToPreviousPage()
        }
        
        // MARK: - Navigation Methods
        
        private func goToPreviousPage() {
            guard let pdfView = pdfView else { return }
            
            // 부드러운 애니메이션과 함께 이전 페이지로 이동
            UIView.animate(withDuration: 0.3, animations: {
                pdfView.goToPreviousPage(nil)
            })
        }
        
        private func goToNextPage() {
            guard let pdfView = pdfView else { return }
            
            // 부드러운 애니메이션과 함께 다음 페이지로 이동
            UIView.animate(withDuration: 0.3, animations: {
                pdfView.goToNextPage(nil)
            })
        }
        
        // MARK: - UIGestureRecognizerDelegate
        
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            // PDFView의 기본 확대/축소 제스처와 충돌하지 않도록 설정
            if gestureRecognizer is UIPinchGestureRecognizer ||
                otherGestureRecognizer is UIPinchGestureRecognizer
            {
                return false
            }
            
            // 기본 스크롤 제스처와는 동시에 인식하지 않음
            return false
        }
        
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldReceive touch: UITouch
        ) -> Bool {
            // 모든 터치를 받도록 허용
            return true
        }
    }
}
