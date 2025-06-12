//
//  AboutView.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import SwiftUI

struct AboutView: View {
    let viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding()
                
                VStack(spacing: 8) {
                    Text(viewModel.appName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                            
                    Text("버전 \(viewModel.appVersion).\(viewModel.buildNumber)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // 앱 설명
            VStack(alignment: .leading, spacing: 16) {
                Text("앱 소개")
                    .font(.headline)
                    .fontWeight(.semibold)
                        
                Text("Viora는 다양한 파일 형식을 지원하는 모바일 파일 뷰어 앱입니다.")
                    .font(.body)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
                    
            // 지원 파일 형식
            VStack(alignment: .leading, spacing: 16) {
                Text("지원 파일 형식")
                    .font(.headline)
                    .fontWeight(.semibold)
                        
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    FileTypeCard(icon: "doc.text.fill", title: "텍스트", description: "TXT, MD, JSON, CSV")
                    FileTypeCard(icon: "photo.fill", title: "이미지", description: "JPG, PNG, GIF, WebP")
                    FileTypeCard(icon: "doc.richtext.fill", title: "PDF", description: "PDF 문서")
                    FileTypeCard(icon: "book.fill", title: "EPUB", description: "전자책")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
                    
            // 개발자 정보
            VStack(alignment: .leading, spacing: 16) {
                Text("개발자")
                    .font(.headline)
                    .fontWeight(.semibold)
                        
                VStack(alignment: .leading, spacing: 8) {
                    Text("© 2024 Viora Team")
                        .font(.body)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
                    
            Spacer(minLength: 32)
        }
        .padding(24)
        .navigationTitle("앱 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("About") {
    AboutView(viewModel: SettingsViewModel())
}
