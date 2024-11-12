//
//  RoutingView.swift
//  BootyDrop
//
//  Created by Kevin Green on 9/25/24.
//

import SwiftUI

class ViewRouter: ObservableObject {
    @Published var view: Views = .welcome
}

enum Views: Int {
    case welcome, game
}

struct RoutingView: View {
    @EnvironmentObject var router: ViewRouter
    
    @StateObject private var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        return scene
    }()
    
    
    var body: some View {
        switch router.view {
        case .welcome: WelcomeScreen()
                .environmentObject(router)
                .transition(.blurReplace.combined(with: .scale))
            
        case .game: GameView()
                .environmentObject(router)
                .environmentObject(game)
                .transition(.blurReplace.combined(with: .scale))
        }
    }
}

#Preview {
    @Previewable @StateObject var router = ViewRouter()
    @Previewable @StateObject var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        return scene
    }()
    
    RoutingView()
        .environmentObject(router)
        .environmentObject(game)
}





