//
//  EmptyListView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct EmptyListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("파일을 추가해주세요")
                .font(.title2)
                .fontWeight(.medium)

            Text("상단의 '+' 버튼을 눌러\n지원하는 파일들을 가져올 수 있습니다")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    EmptyListView()
}
