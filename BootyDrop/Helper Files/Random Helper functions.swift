//
//  Random Helper functions.swift
//  BootyDrop
//
//  Created by Kevin Green on 9/20/24.
//

import SwiftUI

public let gameoverTimerCount: Int = 10

public var windowScene: UIWindowScene? {
    return UIApplication.shared.connectedScenes.first as? UIWindowScene
}

public var safeArea: UIEdgeInsets {
    guard windowScene != nil, let insets = windowScene!.keyWindow?.safeAreaInsets else { return .zero }
    return insets
}


public extension Int {
    var asSeconds: String {
        if self % 10 != 0 {
            return "0:0\(self)"
        } else {
            return "0:\(self)"
        }
    }
}
