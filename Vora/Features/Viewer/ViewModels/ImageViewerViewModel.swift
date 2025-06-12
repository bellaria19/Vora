//
//  ImageViewerViewModel.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import Foundation
import SwiftUI

// struct ImageViewerSettings {
//
// }

@MainActor
class ImageViewerViewModel: ObservableObject {
    @Published var showOverlay: Bool = false
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var imageSize: CGSize = .zero
//    @Published var settings = ImageViewerSettings()

    let fileInfo: FileInfo

    init(fileInfo: FileInfo) {
        self.fileInfo = fileInfo
    }

    func toggleOverlay() {
        showOverlay.toggle()
    }

    func resetZoom() {
        scale = 1.0
        offset = .zero
    }

    func setImageSize(_ size: CGSize) {
        imageSize = size
    }

    func updateScale(_ newScale: CGFloat) {
        scale = min(max(newScale, 0.5), 5.0)
        if scale <= 1.0 {
            offset = .zero
        }
    }

    func updateOffset(_ newOffset: CGSize) {
        offset = newOffset
    }
}
