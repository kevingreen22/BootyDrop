//
//  SettingView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/4/24.
//

import SwiftUI
import KGViews

struct SettingView: View {
    @Binding var showSettings: Bool
    @EnvironmentObject var game: GameScene
    
    var body: some View {
        RealBlur(style: .dark)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showSettings, height: 450, pullText: "Close") {
            VStack {
                PirateText("Settings").pirateShadow(y: 4)
                
                HStack(spacing: 40) {
                    MusicButton(frame: CGSize(width: 100, height: 100)).pirateShadow(y: 4)
                    SoundButton(frame: CGSize(width: 100, height: 100)).pirateShadow(y: 4)
                }.padding(.bottom, 16)
                
                HStack {
                    VibrateButton(frame: CGSize(width: 100, height: 100)).pirateShadow(y: 4)
                }.padding(.bottom, 16)
                
                RestartButton(frame: CGSize(width: 130, height: 50)) {
                    game.resetGame()
                    withAnimation(.easeInOut) {
                        showSettings = false
                    }
                }.pirateShadow(y: 4)
                
            }.padding(.vertical, 16)
        }
        .pirateShadow(y: 24)
    }    
}

#Preview {
    @Previewable @StateObject var game: GameScene = {
        let scene = GameScene()
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return scene
    }()
    @Previewable @State var showSettings: Bool = true
    
    return ZStack {
        SettingView(showSettings: $showSettings)
            .environmentObject(game)
    }
}

