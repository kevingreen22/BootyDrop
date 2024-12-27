//
//  SettingView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/4/24.
//

import SwiftUI
import KGViews
import AppInfo

struct SettingView: View {
    @Binding var showSettings: Bool
    
    @EnvironmentObject var game: GameScene
    
    @AppStorage(AppStorageKey.sound) var shouldPlaySoundEffects: Bool = true
    @AppStorage(AppStorageKey.vibrate) var shouldVibrate: Bool = true
    @AppStorage(AppStorageKey.music) var shouldPlayMusic: Bool = true
    
    var body: some View {
        RealBlur(style: .dark)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showSettings, height: 450, pullText: "Close") {
            VStack {
                PirateText("Settings").pirateShadow(y: 4)
                
                HStack(spacing: 40) {
                    MusicButton(frame: CGSize(width: 100, height: 100), shouldPlayMusic: $shouldPlayMusic) {
                        musicButtonAction()
                    }.pirateShadow(y: 4)
                    
                    SoundButton(frame: CGSize(width: 100, height: 100), shouldPlaySoundEffects: $shouldPlaySoundEffects) {
                        soundButtonAction()
                    }.pirateShadow(y: 4)
                }.padding(.bottom, 16)
                
                HStack {
                    VibrateButton(frame: CGSize(width: 100, height: 100), shouldVibrate: $shouldVibrate) {
                        vibrateButtonAction()
                    }.pirateShadow(y: 4)
                }.padding(.bottom, 16)
                
                if game.gameState == .playing {
                    HStack(spacing: 16) {
                        RestartButton(frame: CGSize(width: 90, height: 50)) {
                            restartButtonAction()
                        }.pirateShadow(y: 4)
                        
                        ExitGameButton(frame: CGSize(width: 90, height: 50)) {
                            exitGameButtonAction()
                        }.pirateShadow(y: 4)
                    }
                }
                
                Spacer()
                Text("V\(Info.version)-\(Info.build)")
                    .font(.caption2)
                    .foregroundStyle(Color.brown)
                
            }.padding(.vertical, 16)
        }
        .pirateShadow(y: 24)
    }    
}



// MARK: Private Subviews
extension SettingView {
    
    fileprivate func musicButtonAction() {
        withAnimation {
            shouldPlayMusic.toggle()
        } completion: {
            game.toggleThemeMusic()
        }
        if shouldPlaySoundEffects {
            try? SoundManager.playeffect(SoundResourceName.soundEffectClick)
        }
    }
    
    fileprivate func soundButtonAction() {
        withAnimation {
            shouldPlaySoundEffects.toggle()
        }
        if shouldPlaySoundEffects {
            try? SoundManager.playeffect(SoundResourceName.soundEffectClick)
        }
    }
    
    fileprivate func restartButtonAction() {
        withAnimation(.easeInOut) {
            game.gameState = .playing
            showSettings = false
        }
        if shouldPlaySoundEffects {
            try? SoundManager.playeffect(SoundResourceName.soundEffectClick)
        }
    }
    
    fileprivate func vibrateButtonAction() {
        withAnimation {
            shouldVibrate.toggle()
        }
        if shouldPlaySoundEffects {
            try? SoundManager.playeffect(SoundResourceName.soundEffectClick)
        }
    }
    
    fileprivate func exitGameButtonAction() {
        withAnimation(.easeInOut) {
            game.gameState = .welcome
            showSettings = false
        }
        if shouldPlaySoundEffects {
            try? SoundManager.playeffect(SoundResourceName.soundEffectClick)
        }
    }
    
}



// MARK: Preview
#Preview {
    @Previewable @State var showSettings: Bool = true
    
    ZStack {
        SettingView(showSettings: $showSettings)
            .environmentObject(GameScene.previewGameScene(state: .welcome))
    }
}

