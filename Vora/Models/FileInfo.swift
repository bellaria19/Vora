//
//  FileInfo.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import Foundation
import SwiftUICore
import UniformTypeIdentifiers

struct FileInfo: Identifiable, Codable {
    var id = UUID()
    let name: String
    let url: URL
    let type: FileType
    let size: Int64
    let modificationDate: Date
    var lastViewedDate: Date?
    
    enum FileType: String, CaseIterable, Codable {
        case text
        case image
        case pdf
        case epub
        case zip
        
        var displayName: String {
            switch self {
            case .text: return "텍스트"
            case .image: return "이미지"
            case .pdf: return "PDF"
            case .epub: return "EPUB"
            case .zip: return "ZIP"
            }
        }
        
        var iconName: String {
            switch self {
            case .text: return "doc.text"
            case .image: return "photo"
            case .pdf: return "doc.richtext"
            case .epub: return "book"
            case .zip: return "archivebox"
            }
        }
        
        var iconColor: Color {
            switch self {
            case .text: return .blue
            case .image: return .green
            case .pdf: return .red
            case .epub: return .orange
            case .zip: return .purple
            }
        }

        var utTypes: [UTType] {
            switch self {
            case .text:
                return [.text, .plainText, .json, .commaSeparatedText]
            case .image:
                return [.image, .jpeg, .png, .gif, .webP]
            case .pdf:
                return [.pdf]
            case .epub:
                return [UTType(filenameExtension: "epub") ?? .data]
            case .zip:
                return [.zip, .archive]
            }
        }
        
        static func from(url: URL) -> FileType {
            let pathExtension = url.pathExtension.lowercased()
            
            switch pathExtension {
            case "txt", "md", "json", "csv", "log", "conf", "ini":
                return .text
            case "jpg", "jpeg", "png", "gif", "webp":
                return .image
            case "pdf":
                return .pdf
            case "epub":
                return .epub
            case "zip":
                return .zip
            default:
                return .text
            }
        }
    }
}
