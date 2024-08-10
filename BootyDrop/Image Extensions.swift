//
//  Image Extensions.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/9/24.
//

import SwiftUI

extension Image {
    func flipHorizontal() -> some View {
        self.rotation3DEffect(.degrees(180), axis: (x: 1.0, y: 0.0, z: 0.0))
    }
    
    func flipVertically() -> some View {
        self.rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
}
