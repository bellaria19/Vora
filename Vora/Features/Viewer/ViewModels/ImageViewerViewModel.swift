//
//  ImageViewerViewModel.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import Foundation
import SwiftUI

@MainActor
class ImageViewerViewModel: ObservableObject {
    @Published var showOverlay: Bool = false
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var imageSize: CGSize = .zero
    @Published var settings: ImageViewerSettings

    let fileInfo: FileInfo

    init(fileInfo: FileInfo) {
        self.fileInfo = fileInfo
        self.settings = ImageViewerSettings.load()
    }

    func updateSettings(_ newSettings: ImageViewerSettings) {
        settings = newSettings
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if settings.isRotationEnabled {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .all))
            } else {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }

    func toggleOverlay() {
        withAnimation {
            showOverlay.toggle()
        }
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
