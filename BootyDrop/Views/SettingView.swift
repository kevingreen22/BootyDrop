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
    
    init(showSettings: Binding<Bool>) {
        _showSettings = showSettings
    }
    
    var body: some View {
        RealBlur(style: .dark)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showSettings, height: 450, pullText: "Close") {
            VStack {
                PirateText("Settings").pirateShadow(y: 4)
                
                HStack(spacing: 40) {
                    MusicButton(frame: CGSize(width: 100, height: 100))
                        .pirateShadow(y: 4)
                        .environmentObject(game)
                    
                    SoundButton(frame: CGSize(width: 100, height: 100))
                        .pirateShadow(y: 4)
                }.padding(.bottom, 16)
                
                HStack {
                    VibrateButton(frame: CGSize(width: 100, height: 100))
                        .pirateShadow(y: 4)
                }.padding(.bottom, 16)
                
                if game.isActive {
                    HStack(spacing: 16) {
                        RestartButton(frame: CGSize(width: 90, height: 50)) {
                            withAnimation {
                                game.resetGame(isActive: true)
                                showSettings = false
                            }
                        }.pirateShadow(y: 4)
                        
                        ExitGameButton(frame: CGSize(width: 90, height: 50)) {
                            withAnimation {
                                game.resetGame(isActive: false)
                                showSettings = false
                            }
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



// MARK: Preview
#Preview {
    @Previewable @StateObject var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        return scene
    }()
    @Previewable @State var showSettings: Bool = true
    game.isActive = true
    
    return ZStack {
        SettingView(showSettings: $showSettings)
            .environmentObject(game)
    }
}

