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
                Text("Settings")
                    .font(.custom(CustomFont.rum, size: 30, relativeTo: .largeTitle))
                    .pirateShadow()
                
                VStack {
                    Button(action: {
                        
                    }, label: {
                        ButtonLabel(imageName: "trophy", title: "Music")
                    })
                    
                    Button(action: {}, label: {
                        ButtonLabel(imageName: "trophy", title: "Sound")
                    })
                    
                    Button(action: {}, label: {
                        ButtonLabel(imageName: "trophy", title: "Vibrate")
                    })
                }.padding(.bottom, 20)
                
                Button(action: {
                    game.resetGame()
                }, label: {
                    ButtonLabel(imageName: "trophy", title: "Restart")
                }).buttonStyle(.borderedProminent)
                
            }.padding(.vertical, 16)
        }
        .pirateShadow(y: 24)
    }
    
    func ButtonLabel(imageName: String, title: String, frame: CGSize? = nil) -> some View {
        VStack {
            Image(imageName)
                .resizable()
                .frame(width: frame?.width ?? 20, height: frame?.height ?? 20)
            Text(title)
                .font(.custom(CustomFont.rum, size: 16, relativeTo: .subheadline))
                .foregroundStyle(Color.orange.gradient)
                .pirateShadow(y: 4)
            
        }
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

