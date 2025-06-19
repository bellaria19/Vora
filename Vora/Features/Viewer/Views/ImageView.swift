//
//  ImageView.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import SwiftUI

struct ImageView: View {
    let imageURL: URL
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var imageSize: CGSize

    @GestureState private var magnification: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero
    @State private var downsampledImage: UIImage?
    @State private var isLoading: Bool = false

    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 5.0

    var body: some View {
        GeometryReader { geo in
            Group {
                if let image = downsampledImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(scale * magnification)
                        .offset(x: offset.width, y: offset.height)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(2.0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .onAppear {
                loadOptimizedImage(targetSize: geo.size)
            }
            .gesture(
                MagnifyGesture()
                    .updating($magnification) { value, gestureState, _ in
                        gestureState = value.magnification
                    }
                    .onEnded { value in
                        let newScale = scale * value.magnification
                        scale = min(max(newScale, minScale), maxScale)

                        if scale <= 1.0 {
                            withAnimation(.easeOut(duration: 0.3)) {
                                offset = .zero
                            }
                        }
                    }
            )
            .gesture(
                scale > 1.0 ?
                    DragGesture()
                    .updating($dragOffset) { value, gestureState, _ in
                        gestureState = value.translation
                    }
                    .onEnded { value in
                        offset.width += value.translation.width
                        offset.height += value.translation.height
                        limitOffset(geometry: geo)
                    }
                    : nil
            )
            .gesture(
                TapGesture(count: 2)
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if scale == 1.0 {
                                scale = 2.0
                            } else {
                                scale = 1.0
                                offset = .zero
                            }
                        }
                    }
            )
        }
    }

    private func loadOptimizedImage(targetSize: CGSize) {
        Task {
            let image = await downsampleImage(from: imageURL, to: targetSize)
            await MainActor.run {
                self.downsampledImage = image
                self.isLoading = false

                if let image = image {
                    self.imageSize = image.size
                }
            }
        }
    }

    func downsampleImage(from url: URL, to targetSize: CGSize) async -> UIImage? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(targetSize.width, targetSize.height)
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    private func limitOffset(geometry: GeometryProxy) {
        let maxOffsetX = (imageSize.width * scale - geometry.size.width) / 2
        let maxOffsetY = (imageSize.height * scale - geometry.size.height) / 2

        offset.width = min(max(offset.width, -maxOffsetX), maxOffsetX)
        offset.height = min(max(offset.height, -maxOffsetY), maxOffsetY)
    }
}
