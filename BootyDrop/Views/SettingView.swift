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
    var game: GameScene?
    @EnvironmentObject var router: ViewRouter
    
    init(showSettings: Binding<Bool>, game: GameScene?) {
        _showSettings = showSettings
        self.game = game
    }
    
    var body: some View {
        RealBlur(style: .dark)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showSettings, height: 450, pullText: "Close") {
            VStack {
                PirateText("Settings").pirateShadow(y: 4)
                
                HStack(spacing: 40) {
                    MusicButton(frame: CGSize(width: 100, height: 100)) {
                        game?.toggleThemeMusic()
                    }
                        .pirateShadow(y: 4)
                    
                    SoundButton(frame: CGSize(width: 100, height: 100))
                        .pirateShadow(y: 4)
                }.padding(.bottom, 16)
                
                HStack {
                    VibrateButton(frame: CGSize(width: 100, height: 100))
                        .pirateShadow(y: 4)
                }.padding(.bottom, 16)
                
                if let game = game {
                    HStack(spacing: 16) {
                        RestartButton(frame: CGSize(width: 90, height: 50)) {
                            withAnimation(.easeInOut) {
                                showSettings = false
                            } completion: {
                                game.resetGame(isActive: true)
                            }
                        }
                        .pirateShadow(y: 4)
                        
                        ExitGameButton(frame: CGSize(width: 90, height: 50)) {
                            withAnimation(.easeInOut) {
                                showSettings = false
                            } completion: {
                                withAnimation(.easeInOut) {
                                    router.view = .welcome
                                }
                            }
                        }
                        .pirateShadow(y: 4)
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

#Preview {
    @Previewable @StateObject var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
//        scene.isActive = true
        return scene
    }()
    @Previewable @StateObject var router = ViewRouter()
    @Previewable @State var showSettings: Bool = true
    game.isActive = true
    
    return ZStack {
        SettingView(showSettings: $showSettings, game: game)
            .environmentObject(router)
    }
}

