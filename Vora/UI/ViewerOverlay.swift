//
//  ViewerOverlay.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct ViewerOverlay: View {
    @Environment(\.dismiss) private var dismiss
    
    let fileInfo: FileInfo
    let currentPage: Int?
    let totalPages: Int?
    let onSettings: () -> Void
    let onPreviousPage: (() -> Void)?
    let onNextPage: (() -> Void)?
    let onPageChange: ((Int) -> Void)?
    
    init(
        fileInfo: FileInfo,
        currentPage: Int? = nil,
        totalPages: Int? = nil,
        onSettings: @escaping () -> Void,
        onPreviousPage: (() -> Void)? = nil,
        onNextPage: (() -> Void)? = nil,
        onPageChange: ((Int) -> Void)? = nil
    ) {
        self.fileInfo = fileInfo
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.onSettings = onSettings
        self.onPreviousPage = onPreviousPage
        self.onNextPage = onNextPage
        self.onPageChange = onPageChange
    }

    var body: some View {
        VStack {
            topOverlay()
                .background(Color.black.opacity(0.7))
            
            Spacer()

            bottomOverlay()
                .background(Color.black.opacity(0.7))
        }
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func topOverlay() -> some View {
        HStack {
            overlayButton(systemName: "chevron.left") {
                dismiss()
            }
            
            Spacer()
            
            Text(fileInfo.name)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding()
            
            Spacer()
            
            overlayButton(systemName: "gearshape.fill") {
                onSettings()
            }
        }
    }
    
    @ViewBuilder
    private func bottomOverlay() -> some View {
        VStack {
            if let currentPage = currentPage,
               let totalPages = totalPages,
               currentPage != 1 || totalPages != 1
            {
                HStack {
                    overlayButton(systemName: "chevron.left") {
                        onPreviousPage?()
                    }
                    .disabled(currentPage <= 1)
                    .opacity(currentPage <= 1 ? 0.5 : 1.0)
                    
                    Spacer()
                    
                    Text("\(currentPage) / \(totalPages)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    
                    Spacer()
                    
                    overlayButton(systemName: "chevron.right") {
                        onNextPage?()
                    }
                    .disabled(currentPage >= totalPages)
                    .opacity(currentPage >= totalPages ? 0.5 : 1)
                }
                
                if let onPageChange {
                    PageSlider(
                        currentPage: .constant(currentPage),
                        totalPages: totalPages,
                        onPageChange: onPageChange)
                }
            }
            else {
                Color.clear.frame(height: 28)
            }
        }
    }
    
    @ViewBuilder
    private func overlayButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(.white)
                .padding()
        }
    }
}
