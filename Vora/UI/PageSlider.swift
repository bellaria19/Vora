//
//  PageSlider.swift
//  Vora
//
//  Created by 이현재 on 6/11/25.
//

import SwiftUI

struct PageSlider: View {
    @Binding var currentPage: Int
    let totalPages: Int
    let onPageChange: (Int) -> Void

    var body: some View {
        VStack {
            HStack {
                Text("1")
                    .font(.caption)
                    .foregroundColor(.white)

                Slider(
                    value: Binding(
                        get: { Double(currentPage) },
                        set: { newValue in
                            let page = Int(newValue.rounded())
                            if page != currentPage {
                                onPageChange(page)
                            }
                        }
                    ),
                    in: 1 ... Double(totalPages),
                    step: 1
                )
                .tint(.white)

                Text("\(totalPages)")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
}
