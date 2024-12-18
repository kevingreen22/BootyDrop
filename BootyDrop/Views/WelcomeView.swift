//
//  WelcomeView.swift
//  BootyDrop
//
//  Created by Kevin Green on 9/27/24.
//

import SwiftUI
import SpriteKit

struct WelcomeView: View {
    @State private var showSettings: Bool = false
    @State private var showRankings: Bool = false
    
    @EnvironmentObject var game: GameScene
    
    @AppStorage(AppStorageKey.sound) var shouldPlaySoundEffects: Bool = true

    
    var body: some View {
        ZStack {
            GameView(showSettings: $showSettings, showRankings: $showRankings)
                .environmentObject(game)
            
            if game.isActive == false {
                StaticPaperScroll(height: 400) {
                    PaperScrollContent
                }
            } // PaperScroll View
        }
        
        .overlay {
            if showSettings {
                SettingView(showSettings: $showSettings)
                    .environmentObject(game)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }
        } // Settings View
        
        .overlay {
            if showRankings {
                RankingsView(showRankings: $showRankings)
                    .environmentObject(game)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }
        } // Rankings View
        
        .fullScreenCover(isPresented: $game.isGameOver) {
            GameoverView($game.isGameOver, score: game.score)
                .environmentObject(game)
        } // Gameover View
        
        .animation(.easeInOut, value: game.isActive)
    }
    
    fileprivate var PaperScrollContent: some View {
        VStack {
            Spacer()
            
            PirateText("Pirate's", size: 40)
            PirateText("Booty Drop", size: 30)
            
            StartButton {
                withAnimation(.easeInOut) {
                    game.resetGame(isActive: true)
                }
                if shouldPlaySoundEffects {
                    try? SoundManager.playeffect(SoundResourceName.soundEffectClick)
                }
            }
                .pirateShadow()
                .padding(.vertical, 24)
                .environmentObject(game)
            
            HStack(spacing: 40) {
                VStack(spacing: 16) {
                    RankingsButton {
                        withAnimation(.easeInOut) {
                            showRankings = true
                        }
                        if shouldPlaySoundEffects {
                            try? SoundManager.playeffect(SoundResourceName.soundEffectClick)
                        }
                    }
                    .scaleEffect(1.5)
                    .pirateShadow()
                    PirateText("Rankings", size: 14)
                }
                VStack(spacing: 16) {
                    SettingsButton {
                        withAnimation(.easeInOut) {
                            showSettings = true
                        }
                        if shouldPlaySoundEffects {
                            try? SoundManager.playeffect(SoundResourceName.soundEffectClick)
                        }
                    }
                    .scaleEffect(1.5)
                    .pirateShadow()
                    PirateText("Settings", size: 14)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            
            Spacer()
        }
    }
}



// MARK: Preview
#Preview {
    @Previewable @State var showSettings = false
    @Previewable @State var showRankings = false
    
    WelcomeView()
        .environmentObject(GameScene.Preview.gameScene(isActive: false))
}

