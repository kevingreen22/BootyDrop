//
//  GameOverView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/15/24.
//

import SwiftUI

struct GameOverView: View {
    @State private var showGameOver = false
    @EnvironmentObject var game: GameScene
    
    
    var body: some View {
        PaperScroll(show: $showGameOver, height: 546) {
            VStack {
                PirateText("Game Over")
                
                HStack {
                    MusicButton()
                    SoundButton()
                    RestartButton {
                        game.resetGame()
                        withAnimation(.easeInOut) {
                            showGameOver = false
                        }
                    }
                }.padding(.bottom, 20)
            }.padding(.vertical, 16)
        }
        .pirateShadow(y: 24)
    }
}

#Preview {
    @StateObject var game: GameScene = {
        let scene = GameScene()
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return scene
    }()
    
    return GameOverView()
        .environmentObject(game)
}
