//
//  ZipImageViewerView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct ZipImageViewerView: View {
    @StateObject private var viewModel: ZipImageViewerViewModel

    init(fileInfo: FileInfo) {
        _viewModel = StateObject(wrappedValue: ZipImageViewerViewModel(fileInfo: fileInfo))
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
//            } else if viewModel.loadingError != nil {
//                ErrorView()
            } else if viewModel.images.isEmpty {
                EmptyImageView()
            } else {
                imageViewer
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.extractZipFile()
        }
        .onDisappear {
            viewModel.cleanupExtractedFiles()
        }
    }

    @ViewBuilder
    private var imageViewer: some View {
        ZStack {
            TabView(selection: $viewModel.currentIndex) {
                ForEach(viewModel.images.indices, id: \.self) { index in
                    ImageView(
                        imageURL: viewModel.images[index],
                        scale: $viewModel.scale,
                        offset: $viewModel.offset,
                        imageSize: $viewModel.imageSize
                    )
                    .tag(index)
                }
            }
            .onChange(of: viewModel.currentIndex) { _, _ in
                viewModel.resetImageState()
            }
            .onTapGesture {
                viewModel.toggleOverlay()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            if viewModel.showOverlay {
                ViewerOverlay(fileInfo: viewModel.fileInfo, currentPage: viewModel.currentIndex + 1, totalPages: viewModel.images.count) {
                    print("Zip 이미지 설정")
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
}
