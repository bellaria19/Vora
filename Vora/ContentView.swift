//
//  ContentView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import Inject
import SwiftData
import SwiftUI

struct ContentView: View {
    @ObserveInjection var inject
    @EnvironmentObject var documentPickerViewModel: DocumentPickerViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if !documentPickerViewModel.filteredFiles.isEmpty {
                    sortHeader()
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                }

                // 메인 콘텐츠
                if documentPickerViewModel.filteredFiles.isEmpty && documentPickerViewModel.searchText.isEmpty {
                    EmptyListView()
                } else if documentPickerViewModel.filteredFiles.isEmpty && !documentPickerViewModel.searchText.isEmpty {
                    EmptySearchView()
                        .environmentObject(documentPickerViewModel)
                } else {
                    FileListView()
                        .environmentObject(documentPickerViewModel)
                }
            }
            .searchable(
                text: $documentPickerViewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "파일 검색..."
            )
            .onSubmit(of: .search) {
                // 검색 제출 시 추가 작업이 필요하면 여기에
            }
            .onChange(of: documentPickerViewModel.searchText) { _, newValue in
                documentPickerViewModel.updateSearchText(newValue)
            }
            .toolbar {
                toolbarContent()
            }
            .sheet(isPresented: $documentPickerViewModel.isShowingPicker) {
                DocumentPickerView { urls in
                    documentPickerViewModel.handleDocumentSelection(urls: urls)
                }
            }
            .sheet(isPresented: $documentPickerViewModel.isShowingSortSheet) {
                SortOptionsView(
                    isPresented: $documentPickerViewModel.isShowingSortSheet,
                    currentSort: $documentPickerViewModel.currentSortOption,
                    onSortSelected: { option in
                        documentPickerViewModel.updateSortOption(option)
                    }
                )
                .presentationDetents([.height(300), .medium])
            }
            .alert("오류", isPresented: .constant(documentPickerViewModel.errorMessage != nil)) {
                Button("확인") {
                    print(documentPickerViewModel.errorMessage ?? "errorMessage is nil")

                    documentPickerViewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = documentPickerViewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .overlay {
                if documentPickerViewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView("파일 복사 중...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        }
        .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
        .enableInjection()
    }

    @ViewBuilder
    private func sortHeader() -> some View {
        HStack {
            // 정렬 버튼
            SortButton(currentSort: documentPickerViewModel.currentSortOption) {
                documentPickerViewModel.isShowingSortSheet = true
            }

            Spacer()

            Text("\(documentPickerViewModel.filteredFiles.count)개 파일")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem {
            Button {
                documentPickerViewModel.showDocumentPicker()
            } label: {
                Image(systemName: "plus")
            }
        }
        ToolbarItem {
            NavigationLink {
                SettingsView()
                    .environmentObject(settingsViewModel)
            } label: {
                Image(systemName: "gearshape.fill")
            }
        }
    }
}

#Preview {
    ContentView()
}
