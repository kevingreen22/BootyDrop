//
//  BootyDropApp.swift
//  BootyDrop
//
//  Created by Kevin Green on 7/23/24.
//

import SwiftUI

@main
struct BootyDropApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        scene.name = "playable_game"
        return scene
    }()
    
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .task { GameCenterManager.authenticateUser() }
                .environmentObject(game)
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            switch newValue {
            case .background, .inactive:
                break
                
            case .active:
                game.toggleThemeMusic()
                break
                
            @unknown default:
                break
            }
        }
    }
}
