//
//  SortOption.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

enum SortOption: String, CaseIterable {
    case nameAsc = "name_asc"
    case nameDesc = "name_desc"
    case sizeAsc = "size_asc"
    case sizeDesc = "size_desc"
    case dateAsc = "date_asc"
    case dateDesc = "date_desc"

    var displayName: String {
        switch self {
        case .nameAsc: return "이름 (오름차순)"
        case .nameDesc: return "이름 (내림차순)"
        case .sizeAsc: return "크기 (작은순)"
        case .sizeDesc: return "크기 (큰순)"
        case .dateAsc: return "날짜 (오래된순)"
        case .dateDesc: return "날짜 (최신순)"
        }
    }

    var iconName: String {
        switch self {
        case .nameAsc: return "textformat.abc"
        case .nameDesc: return "textformat.abc"
        case .sizeAsc: return "arrow.up.circle"
        case .sizeDesc: return "arrow.down.circle"
        case .dateAsc: return "calendar.badge.plus"
        case .dateDesc: return "calendar.badge.minus"
        }
    }

    func compare(_ lhs: FileInfo, _ rhs: FileInfo) -> Bool {
        switch self {
        case .nameAsc:
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        case .nameDesc:
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedDescending
        case .sizeAsc:
            return lhs.size < rhs.size
        case .sizeDesc:
            return lhs.size > rhs.size
        case .dateAsc:
            return lhs.modificationDate < rhs.modificationDate
        case .dateDesc:
            return lhs.modificationDate > rhs.modificationDate
        }
    }
}
