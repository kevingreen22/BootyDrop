//
//  BootyDropApp.swift
//  BootyDrop
//
//  Created by Kevin Green on 7/23/24.
//

import SwiftUI

@main
struct BootyDropApp: App {
    @StateObject var router = ViewRouter()
    @StateObject private var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        return scene
    }()
    
    var body: some Scene {
        WindowGroup {
//            RoutingView()
//                    .task { GameCenterManager.authenticateUser() }
//                    .environmentObject(router)
            MainView()
                .environmentObject(router)
                .environmentObject(game)
        }
    }
}
