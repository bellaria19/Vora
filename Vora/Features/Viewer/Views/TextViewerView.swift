//
//  TextViewerView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI
import UIKit

// MARK: - 텍스트 뷰어 설정

struct TextViewerSettings {
    var fontSize: CGFloat = 16
    var lineSpacing: CGFloat = 4
    var fontWeight: UIFont.Weight = .regular
    var fontFamily: String = "System"
    var textColor: UIColor = .label
    var backgroundColor: UIColor = .systemBackground
    var marginHorizontal: CGFloat = 16
    var marginVertical: CGFloat = 16
    var viewMode: ViewMode = .scroll
    
    enum ViewMode: String, CaseIterable {
        case scroll
        case page
        
        var displayName: String {
            switch self {
            case .scroll: return "스크롤"
            case .page: return "페이지"
            }
        }
    }
    
    var uiFont: UIFont {
        switch fontFamily {
        case "System":
            return UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        case "Monospace":
            return UIFont.monospacedSystemFont(ofSize: fontSize, weight: fontWeight)
        default:
            return UIFont(name: fontFamily, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
    }
    
    var paragraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.paragraphSpacing = lineSpacing / 2
        return style
    }
}

// MARK: - 텍스트 청크 관리자

actor TextChunkManager {
    private var chunks: [String] = []
    private var totalLines = 0
    private let linesPerChunk = 500
    
    func addChunk(_ text: String) {
        let lines = text.components(separatedBy: .newlines)
        chunks.append(text)
        totalLines += lines.count
    }
    
    func getChunk(at index: Int) -> String? {
        guard index >= 0, index < chunks.count else { return nil }
        return chunks[index]
    }
    
    func getChunksInRange(_ range: Range<Int>) -> String {
        let validRange = max(0, range.lowerBound)..<min(chunks.count, range.upperBound)
        return Array(chunks[validRange]).joined()
    }
    
    func getAllText() -> String {
        return chunks.joined()
    }
    
    func getTotalLines() -> Int {
        return totalLines
    }
    
    func getChunkCount() -> Int {
        return chunks.count
    }
    
    func clear() {
        chunks.removeAll()
        totalLines = 0
    }
}

// MARK: - 통일된 파일 리더

class UnifiedFileReader {
    private let bufferSize = 64 * 1024 // 64KB
    private let chunkSize = 256 * 1024 // 256KB per chunk
    
    func readFile(
        from url: URL,
        progressCallback: @escaping (Double) -> Void,
        chunkCallback: @escaping (String) -> Void
    ) async throws {
        // 파일 크기 확인
        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
        let fileSize = Int64(resourceValues.fileSize ?? 0)
        
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer { fileHandle.closeFile() }
        
        var processedBytes: Int64 = 0
        var accumulatedData = Data()
        
        while true {
            let data = fileHandle.readData(ofLength: bufferSize)
            if data.isEmpty { break }
            
            accumulatedData.append(data)
            processedBytes += Int64(data.count)
            
            // 진행률 업데이트
            let progress = fileSize > 0 ? Double(processedBytes) / Double(fileSize) : 1.0
            await MainActor.run {
                progressCallback(progress)
            }
            
            // 청크 크기에 도달하면 처리
            if accumulatedData.count >= chunkSize {
                if let chunk = await processChunk(accumulatedData) {
                    await MainActor.run {
                        chunkCallback(chunk.processedText)
                    }
                    accumulatedData = chunk.remainingData
                }
            }
            
            // CPU 부하 방지를 위한 잠시 대기
            if processedBytes % (1024 * 1024) == 0 { // 1MB마다
                try await Task.sleep(nanoseconds: 1000000) // 1ms
            }
        }
        
        // 남은 데이터 처리
        if !accumulatedData.isEmpty {
            if let chunk = await processChunk(accumulatedData, isLast: true) {
                await MainActor.run {
                    chunkCallback(chunk.processedText)
                }
            }
        }
    }
    
    private func processChunk(_ data: Data, isLast: Bool = false) async -> (processedText: String, remainingData: Data)? {
        guard let text = detectEncodingAndDecode(data) else {
            return nil
        }
        
        if isLast {
            return (text, Data())
        }
        
        // 마지막 줄이 완전하지 않을 수 있으므로 마지막 개행문자까지만 처리
        let lines = text.components(separatedBy: .newlines)
        if lines.count > 1 {
            let processedLines = Array(lines.dropLast())
            let processedText = processedLines.joined(separator: "\n") + "\n"
            
            let lastLine = lines.last ?? ""
            let remainingData = lastLine.data(using: .utf8) ?? Data()
            
            return (processedText, remainingData)
        } else {
            // 개행문자가 없는 경우 데이터를 유지
            return ("", data)
        }
    }
    
    private func detectEncodingAndDecode(_ data: Data) -> String? {
        let encodings: [String.Encoding] = [
            .utf8, .utf16, .shiftJIS, .isoLatin1 // .euckr
        ]
        
        for encoding in encodings {
            if let decoded = String(data: data, encoding: encoding) {
                return decoded
            }
        }
        
        return nil
    }
}

// MARK: - 텍스트 뷰어 ViewModel

@MainActor
class TextViewerViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var showOverlay = false
    @Published var settings = TextViewerSettings()
    @Published var loadingProgress: Double = 0
    @Published var contentKey: UUID = .init()
    
    // 통일된 텍스트 관리
    private let chunkManager = TextChunkManager()
    private let fileReader = UnifiedFileReader()
    private var pageTexts: [String] = []
    
    // 페이지네이션 설정
    private let linesPerPage = 100
    
    // 파일 정보
    private var fileURL: URL?
    private var fileSize: Int64 = 0
    
    func toggleOverlay() {
        showOverlay.toggle()
    }
    
    func loadTextFile(from url: URL) async {
        fileURL = url
        isLoading = true
        errorMessage = nil
        loadingProgress = 0
        await chunkManager.clear()
        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            fileSize = Int64(resourceValues.fileSize ?? 0)
            try await fileReader.readFile(
                from: url,
                progressCallback: { [weak self] progress in
                    self?.loadingProgress = progress
                },
                chunkCallback: { [weak self] chunk in
                    print("[chunkCallback] chunk 추가됨")
                    Task {
                        await self?.chunkManager.addChunk(chunk)
                        await self?.updatePaginationIfNeeded()
                        self?.contentKey = UUID()
                    }
                }
            )
            await setupPagination()
        } catch {
            errorMessage = "파일 로딩 실패: \(error.localizedDescription)"
        }
        isLoading = false
        print("[ViewModel] isLoading = false, 로딩 완료")
    }
    
    // 필요시에만 페이지네이션 업데이트
    private func updatePaginationIfNeeded() async {
        if settings.viewMode == .page {
            await setupPagination()
        }
    }
    
    // 효율적인 페이지네이션 설정
    private func setupPagination() async {
        if settings.viewMode == .page {
            let totalLines = await chunkManager.getTotalLines()
            totalPages = max(1, Int(ceil(Double(totalLines) / Double(linesPerPage))))
            currentPage = min(currentPage, totalPages) // 현재 페이지 보정
        } else {
            totalPages = 1
            currentPage = 1
        }
    }
    
    // 지연 로딩을 통한 페이지 텍스트 생성
    private func generatePageText(for page: Int) async -> String {
        guard page > 0 && page <= totalPages else { return "" }
        
        let startLine = (page - 1) * linesPerPage
        let endLine = min(startLine + linesPerPage, await chunkManager.getTotalLines())
        
        let fullText = await chunkManager.getAllText()
        let lines = fullText.components(separatedBy: .newlines)
        
        guard startLine < lines.count else { return "" }
        
        let pageLines = Array(lines[startLine..<min(endLine, lines.count)])
        return pageLines.joined(separator: "\n")
    }
    
    // 현재 페이지 텍스트 가져오기 (지연 로딩)
    func getCurrentPageText() async -> String {
        guard settings.viewMode == .page else {
            return await chunkManager.getAllText()
        }
        
        return await generatePageText(for: currentPage)
    }
    
    // 전체 텍스트 가져오기
    func getFullText() async -> String {
        return await chunkManager.getAllText()
    }
    
    // 현재 표시할 AttributedString 생성
    func getCurrentAttributedString() async -> NSAttributedString {
        let text = settings.viewMode == .page
            ? await getCurrentPageText()
            : await getFullText()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: settings.uiFont,
            .foregroundColor: settings.textColor,
            .paragraphStyle: settings.paragraphStyle
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    // 페이지 이동
    func goToPage(_ page: Int) {
        guard settings.viewMode == .page,
              page > 0 && page <= totalPages else { return }
        currentPage = page
        contentKey = UUID()
    }
    
    func nextPage() {
        if currentPage < totalPages {
            currentPage += 1
            contentKey = UUID()
        }
    }
    
    func previousPage() {
        if currentPage > 1 {
            currentPage -= 1
            contentKey = UUID()
        }
    }
    
    // 설정 업데이트
    func updateSettings(_ newSettings: TextViewerSettings) {
        let oldViewMode = settings.viewMode
        settings = newSettings
        
        if oldViewMode != newSettings.viewMode {
            Task {
                await setupPagination()
                contentKey = UUID()
            }
        } else {
            contentKey = UUID()
        }
    }
    
    // 메모리 사용량 최적화를 위한 청크 정리
    func optimizeMemory() async {
        // 현재 페이지 주변만 유지하고 나머지는 정리하는 로직
        // 필요시 구현
    }
}

// MARK: - UITextView 래퍼 (비동기 처리 개선)

struct TextViewUIKit: UIViewRepresentable {
    @ObservedObject var viewModel: TextViewerViewModel
    let onTap: () -> Void
    @State private var currentAttributedText = NSAttributedString()
    @State private var lastContentKey: UUID = .init()
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = viewModel.settings.backgroundColor
        textView.showsVerticalScrollIndicator = true
        textView.showsHorizontalScrollIndicator = false
        
        // 텍스트 컨테이너 설정
        textView.textContainerInset = UIEdgeInsets(
            top: viewModel.settings.marginVertical,
            left: viewModel.settings.marginHorizontal,
            bottom: viewModel.settings.marginVertical,
            right: viewModel.settings.marginHorizontal
        )
        
        // 성능 최적화
        textView.layoutManager.allowsNonContiguousLayout = true
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineFragmentPadding = 0
        
        // 터치 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        textView.addGestureRecognizer(tapGesture)
        
        // 페이지 모드용 스와이프 제스처
        if viewModel.settings.viewMode == .page {
            let leftSwipe = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipeLeft))
            leftSwipe.direction = .left
            textView.addGestureRecognizer(leftSwipe)
            
            let rightSwipe = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipeRight))
            rightSwipe.direction = .right
            textView.addGestureRecognizer(rightSwipe)
        }
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.backgroundColor = viewModel.settings.backgroundColor
        textView.textContainerInset = UIEdgeInsets(
            top: viewModel.settings.marginVertical,
            left: viewModel.settings.marginHorizontal,
            bottom: viewModel.settings.marginVertical,
            right: viewModel.settings.marginHorizontal
        )
        // contentKey가 바뀐 경우에만 텍스트 갱신
        if lastContentKey != viewModel.contentKey {
            Task {
                let newAttributedText = await viewModel.getCurrentAttributedString()
                print("[updateUIView] 텍스트 갱신, string 길이: \(newAttributedText.string.count)")
                await MainActor.run {
                    textView.attributedText = newAttributedText
                    if viewModel.settings.viewMode == .page {
                        print("[updateUIView] setContentOffset(.zero) 호출")
                        textView.setContentOffset(.zero, animated: false)
                    }
                    lastContentKey = viewModel.contentKey
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: TextViewUIKit
        
        init(_ parent: TextViewUIKit) {
            self.parent = parent
        }
        
        @objc func handleTap() {
            parent.onTap()
        }
        
        @objc func handleSwipeLeft() {
            Task {
                await parent.viewModel.nextPage()
            }
        }
        
        @objc func handleSwipeRight() {
            Task {
                await parent.viewModel.previousPage()
            }
        }
    }
}

// MARK: - 텍스트 뷰어 화면

struct TextViewerView: View {
    let fileInfo: FileInfo
    @StateObject private var viewModel = TextViewerViewModel()
    @State private var showSettingsSheet = false
    
    var body: some View {
        ZStack {
            Color(viewModel.settings.backgroundColor)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                LoadingView()
//            } else if let errorMessage = viewModel.errorMessage {
//                ErrorView()
            } else {
                TextViewUIKit(viewModel: viewModel) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.showOverlay.toggle()
                    }
                }
            }

            if viewModel.showOverlay {
                ViewerOverlay(
                    fileInfo: fileInfo,
                    currentPage: viewModel.currentPage,
                    totalPages: viewModel.totalPages,
                    onSettings: { showSettingsSheet = true },
                    onPreviousPage: { viewModel.previousPage() },
                    onNextPage: { viewModel.nextPage() },
                    onPageChange: { page in viewModel.goToPage(page) }
                )
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await viewModel.loadTextFile(from: fileInfo.url)
        }
        .sheet(isPresented: $showSettingsSheet) {
            TextViewerSettingsView(
                settings: viewModel.settings,
                onSettingsChange: { newSettings in
                    viewModel.updateSettings(newSettings)
                }
            )
        }
    }
}

// MARK: - 설정 시트

struct TextViewerSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let settings: TextViewerSettings
    let onSettingsChange: (TextViewerSettings) -> Void
    
    @State private var localSettings: TextViewerSettings
    
    init(settings: TextViewerSettings, onSettingsChange: @escaping (TextViewerSettings) -> Void) {
        self.settings = settings
        self.onSettingsChange = onSettingsChange
        self._localSettings = State(initialValue: settings)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("보기 모드") {
                    Picker("모드", selection: $localSettings.viewMode) {
                        ForEach(TextViewerSettings.ViewMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("글꼴 설정") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("크기")
                            Spacer()
                            Text("\(Int(localSettings.fontSize))pt")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $localSettings.fontSize, in: 10...28, step: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("줄 간격")
                            Spacer()
                            Text("\(Int(localSettings.lineSpacing))pt")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $localSettings.lineSpacing, in: 0...10, step: 1)
                    }
                    
                    Picker("글꼴", selection: $localSettings.fontFamily) {
                        Text("시스템").tag("System")
                        Text("고정폭").tag("Monospace")
                    }
                }
                
                Section("여백 설정") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("가로 여백")
                            Spacer()
                            Text("\(Int(localSettings.marginHorizontal))pt")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $localSettings.marginHorizontal, in: 8...32, step: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("세로 여백")
                            Spacer()
                            Text("\(Int(localSettings.marginVertical))pt")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $localSettings.marginVertical, in: 8...32, step: 2)
                    }
                }
            }
            .navigationTitle("텍스트 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("적용") {
                        onSettingsChange(localSettings)
                        dismiss()
                    }
                }
            }
        }
    }
}
