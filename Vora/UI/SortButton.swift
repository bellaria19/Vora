//
//  SortButton.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct SortButton: View {
    let currentSort: SortOption
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 14))
                Text(currentSort.displayName)
                    .font(.system(size: 14))
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

#Preview {
    SortButton(currentSort: .dateDesc) {
        print("Sort button tapped")
    }
    .padding()
}
