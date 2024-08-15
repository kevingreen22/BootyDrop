//
//  Image Extensions.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/9/24.
//

import SwiftUI

// MARK: Image Extensions
extension Image {
    
    func flipHorizontal() -> some View {
        self.rotation3DEffect(.degrees(180), axis: (x: 1.0, y: 0.0, z: 0.0))
    }
    
    func flipVertically() -> some View {
        self.rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
    
}





// MARK: View Extensions

extension View {
    
    func pirateShadow(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        self.modifier(PirateShadow(x: x, y: y))
    }
}

private struct PirateShadow: ViewModifier {
    var x: CGFloat = 0
    var y: CGFloat = 0
    func body(content: Content) -> some View {
        content.shadow(color: .black.opacity(0.4), radius: 5, x: x, y: y)
    }
}

