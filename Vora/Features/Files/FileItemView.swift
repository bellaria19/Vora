//
//  FileItemView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct FileItemView: View {
    let fileInfo: FileInfo

    var body: some View {
        NavigationLink {
            destinationView
        } label: {
            HStack {
                Image(systemName: fileInfo.type.iconName)
                    .font(.title2)
                    .foregroundColor(fileInfo.type.iconColor)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(fileInfo.name)
                        .font(.headline)
                        .lineLimit(2)

                    HStack {
                        Text(fileInfo.formattedSize)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(fileInfo.formattedModifiedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }

    @ViewBuilder
    private var destinationView: some View {
        switch fileInfo.type {
        case .pdf:
            PDFViewerView(fileInfo: fileInfo)

        case .image:
            ImageViewerView(fileInfo: fileInfo)

        case .zip:
            ZipImageViewerView(fileInfo: fileInfo)

        case .epub:
            EpubViewerView(fileInfo: fileInfo)

        case .text:
            TextViewerView(fileInfo: fileInfo)
        }
    }
}

#Preview {
    List {
        ForEach(FileInfo.sampleFiles) { fileinfo in
            FileItemView(fileInfo: fileinfo)
        }
    }
}
