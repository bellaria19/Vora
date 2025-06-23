//
//  Collection+Extensions.swift
//  Vora
//
//  Created by 이현재 on 6/13/25.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 