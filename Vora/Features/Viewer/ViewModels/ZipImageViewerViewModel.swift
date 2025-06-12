//
//  ZipImageViewerViewModel.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI
import ZipArchive

// struct ZipImageViewerSettings {
//
// }

@MainActor
class ZipImageViewerViewModel: ObservableObject {
    @Published var showOverlay: Bool = false
    @Published var currentIndex: Int = 0
    @Published var images: [URL] = []
    @Published var isLoading: Bool = true
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var imageSize: CGSize = .zero
    @Published var loadingError: String?
    @Published var extractedDirectory: URL?
    //    @Published var settings = ZipImageViewerSettings()

    let fileInfo: FileInfo

    init(fileInfo: FileInfo) {
        self.fileInfo = fileInfo
    }

    func goToPrevious() {
        if currentIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex -= 1
            }
        }
    }

    func goToNext() {
        if currentIndex < images.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
            }
        }
    }

    func goToPage(_ page: Int) {
        let targetIndex = page - 1
        if targetIndex >= 0, targetIndex < images.count {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex = targetIndex
            }
        }
    }

    func toggleOverlay() {
        showOverlay.toggle()
    }

    func resetImageState() {
        scale = 1.0
        offset = .zero
        imageSize = .zero
    }

    // MARK: - ZIP 파일 추출

    func extractZipFile() {
        Task {
            do {
                let tempDirectory = FileManager.default.temporaryDirectory
                    .appendingPathComponent("zip_images_\(UUID().uuidString)")

                try FileManager.default.createDirectory(
                    at: tempDirectory,
                    withIntermediateDirectories: true
                )

                let success = SSZipArchive.unzipFile(
                    atPath: fileInfo.url.path,
                    toDestination: tempDirectory.path
                )

                if success {
                    extractedDirectory = tempDirectory
                    let imageURLs = try findImageFiles(in: tempDirectory)

                    await MainActor.run {
                        self.images = imageURLs.sorted { $0.lastPathComponent < $1.lastPathComponent }
                        self.isLoading = false

                        if images.isEmpty {
                            self.loadingError = "ZIP 파일에서 이미지를 찾을 수 없습니다"
                        }
                    }
                } else {
                    await MainActor.run {
                        self.loadingError = "ZIP 파일을 추출할 수 없습니다"
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.loadingError = "ZIP 파일 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - 이미지 파일 찾기

    func findImageFiles(in directory: URL) throws -> [URL] {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        var imageFiles: [URL] = []
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "webp", "heic"]

        for url in contents {
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    // 하위 디렉토리 재귀 탐색
                    let subImages = try findImageFiles(in: url)
                    imageFiles.append(contentsOf: subImages)
                } else {
                    let ext = url.pathExtension.lowercased()
                    if imageExtensions.contains(ext) {
                        imageFiles.append(url)
                    }
                }
            }
        }

        return imageFiles
    }

    // MARK: - 임시 파일 정리

    func cleanupExtractedFiles() {
        guard let directory = extractedDirectory else { return }

        try? FileManager.default.removeItem(at: directory)
    }
}
