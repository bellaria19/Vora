//
//  ImageViewerView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct ImageViewerSettings {
    var backgroundColor: Color = .black

    static let defaultSettings = ImageViewerSettings()
}

struct ImageViewerView: View {
    @StateObject private var viewModel: ImageViewerViewModel
    @State private var settings = ImageViewerSettings()
    @State private var showSettingsSheet: Bool = false

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
                    showSettingsSheet = true
                }
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showSettingsSheet) {
            ImageViewerSettingsSheet(settings: settings) { newSettings in
                settings = newSettings
            }
            .presentationDetents([.medium])
        }
    }
}

