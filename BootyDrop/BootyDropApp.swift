//
//  BootyDropApp.swift
//  BootyDrop
//
//  Created by Kevin Green on 7/23/24.
//

import SwiftUI

@main
struct BootyDropApp: App {
    @StateObject private var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        return scene
    }()
    
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
//                .task { GameCenterManager.authenticateUser() }
                .environmentObject(game)
        }
    }
}
