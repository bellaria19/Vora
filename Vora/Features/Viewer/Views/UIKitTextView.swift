//
//  UIKitTextView.swift
//  Vora
//
//  Created by 이현재 on 6/14/25.
//

import SwiftUI
import UIKit

// MARK: - UITextView 래퍼 (비동기 처리 개선)

struct UIKitTextView: UIViewRepresentable {
    @ObservedObject var viewModel: TextViewerViewModel
    let onTap: () -> Void
    @State private var currentAttributedText = NSAttributedString()
    @State private var lastContentKey: UUID = .init()
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = viewModel.settings.effectiveBackgroundColor
        textView.showsVerticalScrollIndicator = true
        textView.showsHorizontalScrollIndicator = false
        
        // 텍스트 컨테이너 설정
        textView.textContainerInset = UIEdgeInsets(
            top: viewModel.settings.marginVertical,
            left: viewModel.settings.marginHorizontal,
            bottom: viewModel.settings.marginVertical,
            right: viewModel.settings.marginHorizontal
        )
        
        // 성능 최적화
        textView.layoutManager.allowsNonContiguousLayout = true
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineFragmentPadding = 0
        
        // 터치 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        textView.addGestureRecognizer(tapGesture)
        
        // 페이지 모드용 스와이프 제스처
        if viewModel.settings.viewMode == .page {
            let leftSwipe = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipeLeft))
            leftSwipe.direction = .left
            textView.addGestureRecognizer(leftSwipe)
            
            let rightSwipe = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipeRight))
            rightSwipe.direction = .right
            textView.addGestureRecognizer(rightSwipe)
        }
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.backgroundColor = viewModel.settings.effectiveBackgroundColor
        textView.textContainerInset = UIEdgeInsets(
            top: viewModel.settings.marginVertical,
            left: viewModel.settings.marginHorizontal,
            bottom: viewModel.settings.marginVertical,
            right: viewModel.settings.marginHorizontal
        )
        // contentKey가 바뀐 경우에만 텍스트 갱신
        if lastContentKey != viewModel.contentKey {
            Task {
                let newAttributedText = await viewModel.getCurrentAttributedString()
                print("[updateUIView] 텍스트 갱신, string 길이: \(newAttributedText.string.count)")
                await MainActor.run {
                    textView.attributedText = newAttributedText
                    if viewModel.settings.viewMode == .page {
                        print("[updateUIView] setContentOffset(.zero) 호출")
                        textView.setContentOffset(.zero, animated: false)
                    }
                    lastContentKey = viewModel.contentKey
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: UIKitTextView
        
        init(_ parent: UIKitTextView) {
            self.parent = parent
        }
        
        @objc func handleTap() {
            parent.onTap()
        }
        
        @objc func handleSwipeLeft() {
            Task {
                await parent.viewModel.nextPage()
            }
        }
        
        @objc func handleSwipeRight() {
            Task {
                await parent.viewModel.previousPage()
            }
        }
    }
}
