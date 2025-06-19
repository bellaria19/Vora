//
//  ImageViewerView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct ImageViewerView: View {
    @StateObject private var viewModel: ImageViewerViewModel
    @State private var showSettingsSheet: Bool = false

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
            .background(viewModel.settings.backgroundColor)

            if viewModel.showOverlay {
                ViewerOverlay(fileInfo: viewModel.fileInfo) {
                    showSettingsSheet = true
                }
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showSettingsSheet) {
            ImageViewerSettingsSheet(settings: viewModel.settings) { newSettings in
                viewModel.updateSettings(newSettings)
            }
            .presentationDetents([.height(300), .medium])
        }
    }
}
