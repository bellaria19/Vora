//
//  DocumentPickerViewModel.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - DocumentPicker ViewModel

@MainActor
class DocumentPickerViewModel: ObservableObject {
    @Published var selectedFiles: [FileInfo] = []
    @Published var filteredFiles: [FileInfo] = []
    @Published var isShowingPicker = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var currentSortOption: SortOption = .dateDesc
    @Published var isShowingSortSheet = false
    
    // 앱 문서 디렉토리
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("viora")
    }
    
    init() {
        createDocumentsDirectoryIfNeeded()
        loadExistingFiles()

//        self.selectedFiles = FileInfo.sampleFiles
        filterAndSortFiles()
    }
    
    // 검색 텍스트 변경 시 호출
    func updateSearchText(_ text: String) {
        searchText = text
        filterAndSortFiles()
    }
    
    // 정렬 옵션 변경 시 호출
    func updateSortOption(_ option: SortOption) {
        currentSortOption = option
        filterAndSortFiles()
    }
    
    // 검색 및 정렬 적용
    private func filterAndSortFiles() {
        var files = selectedFiles
        
        // 검색 필터링
        if !searchText.isEmpty {
            files = files.filter { file in
                file.name.localizedCaseInsensitiveContains(searchText) ||
                    file.type.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 정렬 적용
        files.sort(by: currentSortOption.compare)

        filteredFiles = files
    }
    
    // 문서 디렉토리 생성
    private func createDocumentsDirectoryIfNeeded() {
        do {
            try FileManager.default.createDirectory(
                at: documentsDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            print("문서 디렉토리 생성 실패: \(error)")
        }
    }
    
    // refresh
    func refreshFiles() async {
        await MainActor.run {
            isLoading = true
        }
        
        // 기존 파일 목록 다시 로드
        loadExistingFiles()
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    // 기존 파일들 로드
    private func loadExistingFiles() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
            )
            
            selectedFiles = fileURLs.compactMap { url in
                guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                      let size = attributes[.size] as? Int64,
                      let modificationDate = attributes[.modificationDate] as? Date
                else {
                    return nil
                }
                
                return FileInfo(
                    name: url.lastPathComponent,
                    url: url,
                    type: FileInfo.FileType.from(url: url),
                    size: size,
                    modificationDate: modificationDate
                )
            }
            
            filterAndSortFiles()
            
        } catch {
            print("파일 로드 실패: \(error)")
        }
    }
    
    // DocumentPicker 표시
    func showDocumentPicker() {
        isShowingPicker = true
    }
    
    // 파일 선택 처리
    func handleDocumentSelection(urls: [URL]) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                for url in urls {
                    try await copyFileToDocuments(from: url)
                }
                loadExistingFiles()
            } catch {
                errorMessage = "파일 복사 중 오류가 발생했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // 파일을 앱 문서 디렉토리로 복사
    private func copyFileToDocuments(from sourceURL: URL) async throws {
        let fileName = sourceURL.lastPathComponent
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)
        
        // 중복 파일명 처리
        let finalDestinationURL = try generateUniqueURL(for: destinationURL)
        
        // 보안 스코프 접근 시작
        guard sourceURL.startAccessingSecurityScopedResource() else {
            throw DocumentPickerError.securityScopeAccessFailed
        }
        
        defer {
            sourceURL.stopAccessingSecurityScopedResource()
        }
        
        try FileManager.default.copyItem(at: sourceURL, to: finalDestinationURL)
    }
    
    // 중복 파일명 처리
    private func generateUniqueURL(for url: URL) throws -> URL {
        var counter = 1
        var uniqueURL = url
        
        while FileManager.default.fileExists(atPath: uniqueURL.path) {
            let fileName = url.deletingPathExtension().lastPathComponent
            let fileExtension = url.pathExtension
            let newFileName = "\(fileName)_\(counter).\(fileExtension)"
            uniqueURL = url.deletingLastPathComponent().appendingPathComponent(newFileName)
            counter += 1
        }
        
        return uniqueURL
    }
    
    // 파일 이름 변겨
    func renameFile(_ fileInfo: FileInfo, to newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 빈 이름이거나 같은 이름인 경우 무시
        guard !trimmedName.isEmpty, trimmedName != fileInfo.name else { return }
        
        let newURL = fileInfo.url.deletingLastPathComponent().appendingPathComponent(trimmedName)
        
        do {
            try FileManager.default.moveItem(at: fileInfo.url, to: newURL)
            loadExistingFiles() // 파일 목록 새로고침
        } catch {
            errorMessage = "파일 이름 변경 실패: \(error.localizedDescription)"
        }
    }
    
    // 파일 삭제
    func deleteFile(_ fileInfo: FileInfo) {
        do {
            try FileManager.default.removeItem(at: fileInfo.url)
            selectedFiles.removeAll { $0.id == fileInfo.id }
            filterAndSortFiles()
        } catch {
            errorMessage = "파일 삭제 실패: \(error.localizedDescription)"
        }
    }
    
    // 모든 파일 삭제
    func deleteAllFiles() {
        do {
            try FileManager.default.removeItem(at: documentsDirectory)
            createDocumentsDirectoryIfNeeded()
            selectedFiles.removeAll()
            filterAndSortFiles()
        } catch {
            errorMessage = "파일 삭제 실패: \(error.localizedDescription)"
        }
    }
}

// MARK: - DocumentPicker 오류 타입

enum DocumentPickerError: LocalizedError {
    case securityScopeAccessFailed
    
    var errorDescription: String? {
        switch self {
        case .securityScopeAccessFailed:
            return "파일 접근 권한을 얻을 수 없습니다."
        }
    }
}

// MARK: - DocumentPicker View

struct DocumentPickerView: UIViewControllerRepresentable {
    let allowedTypes: [UTType]
    let allowMultiple: Bool
    let onSelection: ([URL]) -> Void
    
    init(
        allowedTypes: [UTType] = [.text, .image, .pdf, .zip, UTType(filenameExtension: "epub") ?? .data],
        allowMultiple: Bool = true,
        onSelection: @escaping ([URL]) -> Void
    ) {
        self.allowedTypes = allowedTypes
        self.allowMultiple = allowMultiple
        self.onSelection = onSelection
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        picker.allowsMultipleSelection = allowMultiple
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // 업데이트 로직 (필요시)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSelection: onSelection)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onSelection: ([URL]) -> Void
        
        init(onSelection: @escaping ([URL]) -> Void) {
            self.onSelection = onSelection
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onSelection(urls)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // 취소 처리 (필요시)
        }
    }
}
