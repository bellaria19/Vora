//
//  FileInfo+Extensions.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import Foundation

extension FileInfo {
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    var formattedModifiedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: modificationDate)
    }

    var formattedLastViewedDate: String? {
        guard let lastViewedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: lastViewedDate)
    }
}

extension FileInfo {
    static let sampleFiles: [FileInfo] = [
        FileInfo(
            name: "회의록_2024.txt",
            url: URL(string: "file:///Documents/회의록_2024.txt")!,
            type: .text,
            size: 15_420,
            modificationDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            lastViewedDate: Date()
        ),
        FileInfo(
            name: "프로젝트계획서.pdf",
            url: URL(string: "file:///Documents/프로젝트_계획서.pdf")!,
            type: .pdf,
            size: 2_485_760,
            modificationDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            lastViewedDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
        ),
        FileInfo(
            name: "vacation_photo.jpg",
            url: URL(string: "file:///Documents/vacation_photo.jpg")!,
            type: .image,
            size: 8_924_160,
            modificationDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        ),
        FileInfo(
            name: "소설해리포터.epub",
            url: URL(string: "file:///Documents/소설_해리포터.epub")!,
            type: .epub,
            size: 1_248_576,
            modificationDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
            lastViewedDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
        ),
        FileInfo(
            name: "backup_files.zip",
            url: URL(string: "file:///Documents/backup_files.zip")!,
            type: .zip,
            size: 15_728_640,
            modificationDate: Calendar.current.date(byAdding: .day, value: -21, to: Date()) ?? Date()
        ),
        FileInfo(
            name: "data_analysis.csv",
            url: URL(string: "file:///Documents/data_analysis.csv")!,
            type: .text,
            size: 89_340,
            modificationDate: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
            lastViewedDate: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        ),
        FileInfo(
            name: "screenshot_bug.png",
            url: URL(string: "file:///Documents/screenshot_bug.png")!,
            type: .image,
            size: 3_456_789,
            modificationDate: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date()
        )
    ]
}
