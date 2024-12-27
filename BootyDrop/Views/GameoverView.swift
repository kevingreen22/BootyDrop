//
//  GameOverView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/15/24.
//

import SwiftUI
import KGViews

struct GameoverView: View {
    var score: Int
    
    @EnvironmentObject var game: GameScene
    
    var body: some View {
        let shareSnapshot: Image = Image(uiImage: game.screenshot)
        
        return PaperScroll(show: $game.isGameOver, height: 546, pullText: "Exit", onDismiss: {
            withAnimation(.easeInOut) {
                game.gameState = .welcome
                game.isGameOver = false
            }
        }) {
            VStack {
                PirateText("Game Over")
                PirateText("Score: \(score)", size: 16)
                
                shareSnapshot
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
                    .cornerRadius(20)
                    .bordered(shape: RoundedRectangle(cornerRadius: 20, style: .continuous), color: Color.white.opacity(0.7), lineWidth: 3)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                
                HStack {
                    ShareButton(item: shareSnapshot, frame: CGSize(width: 65, height: 40))
                        .buttonStyle(.borderedProminent)
                        .pirateShadow(y: 4)
                    
                    RestartButton(frame: CGSize(width: 85, height: 40)) {
                        withAnimation(.easeInOut) {
                            game.gameState = .playing
                            game.isGameOver = false
                        }
                    }.pirateShadow(y: 4)
                    
                }.padding(.bottom, 20)
            }.padding(.vertical, 16)
        }
        .pirateShadow(y: 24)
        .presentationBackground(Color.accentColor)
    }
}



// MARK: Preview
#Preview {
    let gameScene = GameScene.previewGameScene(state: .playing)
    gameScene.isGameOver = true
    
    return GameoverView(score: gameScene.score)
        .environmentObject(gameScene)
}

