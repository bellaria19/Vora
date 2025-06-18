//
//  View+Extensions.swift
//  Vora
//
//  Created by 이현재 on 6/12/25.
//

import Foundation

import SwiftUI

extension View {
    func handleScreenTap(location: CGPoint, screenSize: CGSize, onLeft: @escaping () -> Void = {}, onRight: @escaping () -> Void = {}, onCenter: @escaping () -> Void) {
        let leftRegionWidth = screenSize.width * 0.25
        let rightRegionWidth = screenSize.width * 0.25

        if location.x < leftRegionWidth {
            onLeft()
        } else if location.x > screenSize.width - rightRegionWidth {
            onRight()
        } else {
            onCenter()
        }
    }
}
