//
//  ZipImageViewerView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

// import SwiftUI
//
// struct ZipImageViewerView: View {
//    @StateObject private var viewModel: ZipImageViewerViewModel
//    @State private var settings = ImageViewerSettings()
//    @State private var showSettingsSheet: Bool = false
//
//    init(fileInfo: FileInfo) {
//        _viewModel = StateObject(wrappedValue: ZipImageViewerViewModel(fileInfo: fileInfo))
//    }
//
//    var body: some View {
//        ZStack {
//            if viewModel.isLoading {
//                LoadingView()
////            } else if viewModel.loadingError != nil {
////                ErrorView()
//            } else if viewModel.images.isEmpty {
//                EmptyImageView()
//            } else {
//                imageViewer
//            }
//        }
//        .navigationBarBackButtonHidden()
//        .sheet(isPresented: $showSettingsSheet, content: {
//            ImageViewerSettingsSheet(settings: settings) { newSettings in
//                settings = newSettings
//            }
//            .presentationDetents([.medium])
//        })
//        .onAppear {
//            viewModel.extractZipFile()
//        }
//        .onDisappear {
//            viewModel.cleanupExtractedFiles()
//        }
//    }
//
//    @ViewBuilder
//    private var imageViewer: some View {
//        ZStack {
//            TabView(selection: $viewModel.currentIndex) {
//                ForEach(viewModel.images.indices, id: \.self) { index in
//                    ImageView(
//                        imageURL: viewModel.images[index],
//                        scale: $viewModel.scale,
//                        offset: $viewModel.offset,
//                        imageSize: $viewModel.imageSize
//                    )
//                    .tag(index)
//                }
//            }
//            .onChange(of: viewModel.currentIndex) { _, _ in
//                viewModel.resetImageState()
//            }
//            .onTapGesture {
//                viewModel.toggleOverlay()
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//
//            if viewModel.showOverlay {
//                ViewerOverlay(
//                    fileInfo: viewModel.fileInfo,
//                    currentPage: viewModel.currentIndex + 1,
//                    totalPages: viewModel.images.count
//                ) {
//                    showSettingsSheet = true
//                } onPreviousPage: {
//                    viewModel.goToPrevious()
//                } onNextPage: {
//                    viewModel.goToNext()
//                } onPageChange: { page in
//                    viewModel.goToPage(page)
//                }
//            }
//        }
//    }
// }

import SwiftUI

struct ZipImageViewerView: View {
    @StateObject private var viewModel: ZipImageViewerViewModel
    @State private var showSettingsSheet: Bool = false

    init(fileInfo: FileInfo) {
        _viewModel = StateObject(wrappedValue: ZipImageViewerViewModel(fileInfo: fileInfo))
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.images.isEmpty {
                EmptyImageView()
            } else {
                optimizedImageViewer
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showSettingsSheet, content: {
            ImageViewerSettingsSheet(settings: viewModel.settings) { newSettings in
                viewModel.updateSettings(newSettings)
            }
            .presentationDetents([.height(300), .medium])
        })
        .onAppear {
            viewModel.extractZipFile()
        }
        .onDisappear {
            viewModel.cleanupExtractedFiles()
        }
    }

    @ViewBuilder
    private var optimizedImageViewer: some View {
        ZStack {
            // TabView 대신 커스텀 페이징 뷰 사용
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // 현재 인덱스 기준으로 -1, 0, +1 인덱스의 이미지만 렌더링
                    ForEach(-1 ... 1, id: \.self) { offset in
                        let index = viewModel.currentIndex + offset

                        if index >= 0 && index < viewModel.images.count {
                            OptimizedImageView(
                                imageURL: viewModel.images[index],
                                scale: $viewModel.scale,
                                offset: $viewModel.offset,
                                imageSize: $viewModel.imageSize
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                        } else {
                            Color.clear
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                }
                .offset(x: -geometry.size.width + viewModel.dragOffset.width) // 중앙 이미지를 화면에 표시
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewModel.dragOffset = value.translation
                        }
                        .onEnded { value in
                            handleSwipeGesture(value, screenWidth: geometry.size.width)
                        }
                )
            }
            .onTapGesture {
                viewModel.toggleOverlay()
            }
            .background(viewModel.settings.backgroundColor)

            if viewModel.showOverlay {
                ViewerOverlay(
                    fileInfo: viewModel.fileInfo,
                    currentPage: viewModel.currentIndex + 1,
                    totalPages: viewModel.images.count
                ) {
                    showSettingsSheet = true
                } onPreviousPage: {
                    viewModel.goToPrevious()
                } onNextPage: {
                    viewModel.goToNext()
                } onPageChange: { page in
                    viewModel.goToPage(page)
                }
            }
        }
    }

    private func handleSwipeGesture(_ value: DragGesture.Value, screenWidth: CGFloat) {
        let threshold: CGFloat = screenWidth * 0.25 // 화면 너비의 25%

        withAnimation(.easeIn(duration: 0.3)) {
            if value.translation.width > threshold && viewModel.currentIndex > 0 {
                // 이전 이미지로 이동
                viewModel.goToPrevious()
            } else if value.translation.width < -threshold && viewModel.currentIndex < viewModel.images.count - 1 {
                // 다음 이미지로 이동
                viewModel.goToNext()
            }

            // 드래그 오프셋 리셋
            viewModel.dragOffset = .zero
        }
    }
}

// MARK: - 최적화된 이미지 뷰 컴포넌트

struct OptimizedImageView: View {
    let imageURL: URL
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var imageSize: CGSize

    @GestureState private var magnification: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero

    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 5.0

    var body: some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(scale * magnification)
                .offset(
                    x: offset.width,
                    y: offset.height
                )
                .onAppear {
                    if let uiImage = UIImage(contentsOfFile: imageURL.path) {
                        imageSize = uiImage.size
                    }
                }
        } placeholder: {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(2.0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .gesture(
            // 확대/축소 제스처
            MagnifyGesture()
                .updating($magnification) { value, gestureState, _ in
                    gestureState = value.magnification
                }
                .onEnded { value in
                    let newScale = scale * value.magnification
                    withAnimation(.easeOut(duration: 0.3)) {
                        scale = min(max(newScale, minScale), maxScale)

                        if scale <= 1.0 {
                            offset = .zero
                        }
                    }
                }
        )
        .gesture(
            // 확대된 상태에서만 드래그 가능
            scale > 1.0 ?
                DragGesture()
                .updating($dragOffset) { value, gestureState, _ in
                    gestureState = value.translation
                }
                .onEnded { value in
                    withAnimation(.easeOut(duration: 0.3)) {
                        offset.width += value.translation.width
                        offset.height += value.translation.height
                        limitOffset()
                    }
                }
                : nil
        )
        .gesture(
            // 더블 탭으로 확대/축소
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

    private func limitOffset() {
        let maxOffsetX = max(0, (imageSize.width * scale - UIScreen.main.bounds.width) / 2)
        let maxOffsetY = max(0, (imageSize.height * scale - UIScreen.main.bounds.height) / 2)

        offset.width = min(max(offset.width, -maxOffsetX), maxOffsetX)
        offset.height = min(max(offset.height, -maxOffsetY), maxOffsetY)
    }
}
