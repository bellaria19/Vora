//
//  SortOptionsView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct SortOptionsView: View {
    @Binding var isPresented: Bool
    @Binding var currentSort: SortOption
    let onSortSelected: (SortOption) -> Void

    var body: some View {
        List {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button(action: {
                    onSortSelected(option)
                    isPresented = false
                }) {
                    HStack {
                        Text(option.displayName)
                            .foregroundColor(.primary)

                        Spacer()

                        if currentSort == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("정렬 옵션")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    SortOptionsView(
        isPresented: .constant(true),
        currentSort: .constant(.dateDesc),
        onSortSelected: { option in
            print("Selected sort: \(option.displayName)")
        }
    )
}
