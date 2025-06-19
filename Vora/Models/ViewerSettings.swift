import SwiftUI

enum ViewerTheme {
    static let themes: [Color] = [
        .black,
        .white,
        Color(uiColor: .darkGray),
        Color(uiColor: .lightGray),
        .mint,
        .indigo,
    ]

    static let defaultBackgroundColor: Color = .white
}

enum ViewMode: String, CaseIterable {
    case scroll
    case page

    var displayName: String {
        switch self {
        case .scroll: return "스크롤"
        case .page: return "페이지"
        }
    }
}
