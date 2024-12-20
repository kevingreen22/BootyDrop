//
//  GameOverView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/15/24.
//

import SwiftUI
import KGViews

struct GameOverView: View {
    @Binding var showGameOver: Bool
    var score: Int
    
    @EnvironmentObject var game: GameScene
    @EnvironmentObject var router: ViewRouter
    
    init(_ showGameOver: Binding<Bool>, score: Int) {
        _showGameOver = showGameOver
        self.score = score
    }
    
    
    var body: some View {
        let shareSnapshot: Image = Image(uiImage: game.screenshot)
        
        return PaperScroll(show: $showGameOver, height: 546, pullText: "Exit", onDismiss: {
            router.view = .welcome
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
                        game.resetGame(isActive: true)
                        withAnimation(.easeInOut) {
                            showGameOver = false
                        }
                    }.pirateShadow(y: 4)
                    
                }.padding(.bottom, 20)
            }.padding(.vertical, 16)
        }
        .pirateShadow(y: 24)
        .presentationBackground(Color.accentColor)
    }
}

#Preview {
    @Previewable @State var showGameOver = false
    @Previewable @StateObject var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        return scene
    }()
    @Previewable @StateObject var router = ViewRouter()
        
    GameOverView($showGameOver, score: game.score)
        .environmentObject(game)
        .environmentObject(router)
}

