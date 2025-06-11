//
//  EmptySearchView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct EmptySearchView: View {
    @EnvironmentObject var viewModel: DocumentPickerViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("검색 결과가 없습니다")
                .font(.title2)
                .fontWeight(.medium)

            Text("'\(viewModel.searchText)'에 대한 검색 결과를 찾을 수 없습니다")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    EmptySearchView()
}
