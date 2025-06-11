//
//  FileListView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct FileListView: View {
    @EnvironmentObject var viewModel: DocumentPickerViewModel
    @State private var fileToDelete: FileInfo?
    @State private var fileToRename: FileInfo?
    @State private var newFileName = ""

    var body: some View {
        List {
            ForEach(viewModel.filteredFiles) { fileInfo in
                FileItemView(fileInfo: fileInfo)
                    .swipeActions(edge: .leading, content: {
                        Button {
                            fileToRename = fileInfo
                            newFileName = fileInfo.name
                        } label: {
                            Label("Rename", systemImage: "pencil")
                                .labelStyle(.iconOnly)
                        }
                        .tint(.blue)
                    })
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            fileToDelete = fileInfo // 삭제할 파일 설정
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                    }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refreshFiles()
        }
        .alert("파일 삭제", isPresented: .constant(fileToDelete != nil)) {
            Button("삭제", role: .destructive) {
                if let file = fileToDelete {
                    viewModel.deleteFile(file)
                    fileToDelete = nil
                }
            }
            Button("취소", role: .cancel) {
                fileToDelete = nil
            }
        } message: {
            if let file = fileToDelete {
                Text("\(file.name)을 삭제하시겠습니까?")
            }
        }
        .alert("파일 이름 변경", isPresented: .constant(fileToRename != nil)) {
            TextField("새 파일명", text: $newFileName)
                .autocorrectionDisabled()

            Button("변경") {
                if let file = fileToRename {
                    viewModel.renameFile(file, to: newFileName)
                    fileToRename = nil
                }
            }
            .disabled(newFileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Button("취소", role: .cancel) {
                fileToRename = nil
            }
        } message: {
            if let file = fileToRename {
                Text("\(file.name)의 새로운 이름을 입력하세요")
            }
        }
    }
}
