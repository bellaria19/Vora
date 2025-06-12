//
//  FileTypeCard.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import SwiftUI

struct FileTypeCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    FileTypeCard(icon: "doc.text.fill", title: "텍스트", description: "TXT, MD, JSON, CSV")
}
