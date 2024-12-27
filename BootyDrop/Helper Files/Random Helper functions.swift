//
//  Random Helper functions.swift
//  BootyDrop
//
//  Created by Kevin Green on 9/20/24.
//

import SwiftUI

public let gameoverTimerCount: Int = 8

public var windowScene: UIWindowScene? {
    return UIApplication.shared.connectedScenes.first as? UIWindowScene
}

public var safeArea: UIEdgeInsets {
    guard windowScene != nil, let insets = windowScene!.keyWindow?.safeAreaInsets else { return .zero }
    return insets
}
