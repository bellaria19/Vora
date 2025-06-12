//
//  EmptyImageView.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct EmptyImageView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("이미지를 찾을 수 없습니다")
                .font(.title)

            Text("ZIP 파일에 지원하는 이미지 파일이 없습니다.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("뒤로 가기") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyImageView()
}
