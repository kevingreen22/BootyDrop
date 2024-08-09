//
//  ContentView.swift
//  BallDrop
//
//  Created by Kevin Green on 7/15/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        scene.backgroundColor = GameScene.backgoundColor
        return scene
    }()
    @State private var showSettings: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            SpriteView(scene: game)
            Footer().frame(height: 85)
        }.ignoresSafeArea()
        
        .overlay(alignment: .top) {
            Header(showSettings: $showSettings).environmentObject(game)
        }
        
        .overlay {
            if showSettings {
                SettingView(showSettings: $showSettings)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }
        }
    }
}

#Preview {
    @StateObject var game: GameScene = {
        let scene = GameScene()
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene.backgroundColor = GameScene.backgoundColor
        return scene
    }()
    
    return ContentView()
        .environmentObject(game)
}


// MARK: Views

struct Header: View {
    @EnvironmentObject var game: GameScene
    @Binding var showSettings: Bool
    
    var body: some View {
        ZStack {
            background
                .overlay(alignment: .top) {
                    VStack(spacing: 0) {
                        highScore
                        score
                    }
                }
                .overlay(alignment: .topLeading) {
                    NextObjectView(dropObject: $game.nextDropObject)
                    Spacer()
                }
                .overlay(alignment: .topTrailing) {
                    HStack {
                        Button(action: {}, label: {
                            Image("crownButton")
                                .resizable()
                                .frame(width: 40, height: 40)
                        })
                        Button(action: {
                            withAnimation(.bouncy) {
                                showSettings = true
                            }
                        }, label: {
                            Image("settingsButton")
                                .resizable()
                                .frame(width: 40, height: 40)
                        })
                    }
                    .padding([.top, .trailing])
                }
        }
        .pirateShadow()
        .padding(.horizontal, 8)
    }
    
    var highScore: some View {
        HStack(spacing: 4) {
            Image("trophy")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 20)
                .foregroundStyle(Color(uiColor: .darkText))
            Text("\(6757)")
                .font(.custom(CustomFont.rum, size: 16))
                .foregroundStyle(Color(uiColor: .darkText))
        }
        .foregroundStyle(Color(uiColor: .darkText))
        .pirateShadow(y: 3)
        .padding(.top, 8)
    }
    
    var score: some View {
        Text("\(game.score)")
            .font(.custom(CustomFont.rum, size: 28))
            .foregroundStyle(Color(uiColor: .darkText))
            .pirateShadow(y: 3)
            .padding(.top, 4)
    }
    
    var background: some View {
        Image("scroll3")
            .resizable()
            .frame(height: 80)
            .rotationEffect(.degrees(-0.5))
    }
}

struct NextObjectView: View {
    @Binding var dropObject: DropObject
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Next: ")
                .font(.custom(CustomFont.rum, size: 14))
                .foregroundStyle(Color(uiColor: .darkText))
                .pirateShadow(x: 3)
            Image("\(dropObject.imageName.rawValue)")
                .resizable()
                .frame(width: 30, height: 30)
                .pirateShadow(x: 3)
                .animation(.bouncy, value: dropObject.customSize)
            
        }
        .padding(.top, 8)
        .padding(.leading)
    }
}

struct Footer: View {
    var body: some View {
        ZStack {
            background
            collage
        }
    }
        
    var collage: some View {
        HStack {
            Image("coin").resizable().scaledToFit()
            Image("red_gem").resizable().scaledToFit()
            Image("blue_gem").resizable().scaledToFit()
            Image("green_gem").resizable().scaledToFit()
            Image("gold_brick").resizable().scaledToFit()
            Image("skull").resizable().scaledToFit()
        }
        .frame(height: 30)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10.0, style: .continuous).fill(Color.black.opacity(0.6))
        }
    }
    
    var background: some View {
        Image("sand")
            .resizable()
            .frame(height: 100)
    }
}








private struct PirateShadow: ViewModifier {
    var x: CGFloat = 0
    var y: CGFloat = 0
    func body(content: Content) -> some View {
        content.shadow(color: .black.opacity(0.4), radius: 5, x: x, y: y)
    }
}

extension View {
    func pirateShadow(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        self.modifier(PirateShadow(x: x, y: y))
    }
}
