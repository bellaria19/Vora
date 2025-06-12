//
//  ImageViewerView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct ImageViewerView: View {
    @StateObject private var viewModel: ImageViewerViewModel

    var bgColor: Color = .white

    init(fileInfo: FileInfo) {
        _viewModel = StateObject(wrappedValue: ImageViewerViewModel(fileInfo: fileInfo))
    }

    var body: some View {
        ZStack {
            ImageView(
                imageURL: viewModel.fileInfo.url,
                scale: $viewModel.scale,
                offset: $viewModel.offset,
                imageSize: $viewModel.imageSize
            )
            .onTapGesture {
                viewModel.toggleOverlay()
            }
            .background(bgColor)

            if viewModel.showOverlay {
                ViewerOverlay(fileInfo: viewModel.fileInfo) {
                    print("이미지 설정")
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
