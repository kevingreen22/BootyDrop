//
//  MainScreen.swift
//  BootyDrop
//
//  Created by Kevin Green on 9/19/24.
//

import SwiftUI
import SpriteKit

struct WelcomeScreen: View {
    @State private var showRankings: Bool = false
    @State private var showSettings: Bool = false
    @EnvironmentObject var router: ViewRouter
    @EnvironmentObject var game: GameScene
    
    
    var body: some View {
        ZStack {
            SpriteView(scene: game).ignoresSafeArea()
            
            StaticPaperScroll(height: 400) {
                VStack {
                    Spacer()
                    
                    PirateText("Pirate's", size: 40)
                    PirateText("Booty Drop", size: 30)
                    
                    StartButton()
                        .pirateShadow()
                        .padding(.vertical, 24)
                        .environmentObject(router)
                        .environmentObject(game)
                    
                    HStack(spacing: 40) {
                        VStack(spacing: 16) {
                            RankingsButton($showRankings)
                                .scaleEffect(1.5)
                                .pirateShadow()
                            PirateText("Rankings", size: 14)
                        }
                        VStack(spacing: 16) {
                            SettingsButton($showSettings)
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
        .overlay {
            if showSettings {
                SettingView(showSettings: $showSettings, game: nil)
                    .environmentObject(router)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }
        } // Settings View
        
        .overlay {
            if showRankings {
                RankingsView(showRankings: $showRankings)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }
        } // Rankings View
        
    }
}

#Preview {
    @Previewable @StateObject var router = ViewRouter()
    @Previewable @StateObject var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        return scene
    }()
    
    WelcomeScreen()
        .environmentObject(router)
        .environmentObject(game)
}

