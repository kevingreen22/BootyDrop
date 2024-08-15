//
//  SettingView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/4/24.
//

import SwiftUI

struct SettingView: View {
    @Binding var showSettings: Bool
    
    @EnvironmentObject var game: GameScene
    
    
    var body: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showSettings) {
            VStack {
                PirateText("Settings")
                
                VStack {
                    MusicButton()
                    SoundButton()
                    VibrateButton()
                }.padding(.bottom, 20)
                
                RestartButton() {
                    game.resetGame()
                    withAnimation(.easeInOut) {
                        showSettings = false
                    }
                }
                
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
    @State var showSettings: Bool = true
    
    return ZStack {
        SettingView(showSettings: $showSettings)
            .environmentObject(game)
    }
}

