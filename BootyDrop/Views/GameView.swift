//
//  ContentView.swift
//  BootyDrop
//
//  Created by Kevin Green on 7/15/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var game: GameScene
    @EnvironmentObject var router: ViewRouter
    @State private var showSettings: Bool = false
    @State private var showRankings: Bool = false
    
    
    var body: some View {
        VStack(spacing: 0) {
            SpriteView(scene: game)
            Footer().frame(height: 85)
        }.ignoresSafeArea()
        
        .overlay(alignment: .top) {
            Header(showSettings: $showSettings, showRankings: $showRankings)
                .environmentObject(game)
        } // Header View
        
        .overlay {
            if showSettings {
                SettingView(showSettings: $showSettings, game: game)
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
        
        .fullScreenCover(isPresented: $game.isGameOver) {
            GameOverView($game.isGameOver, score: game.score)
                .environmentObject(game)
                .environmentObject(router)
        } // GameOver View
    }
}

#Preview {
    @Previewable @StateObject var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.isActive = true
        return scene
    }()
    @Previewable @StateObject var router = ViewRouter()
    
    GameView()
        .environmentObject(game)
        .environmentObject(router)
}




// MARK: Views

struct Header: View {
    @EnvironmentObject var game: GameScene
    @Binding var showSettings: Bool
    @Binding var showRankings: Bool
    
    var body: some View {
        ZStack {
            headerBackground
                .overlay(alignment: .topLeading) {
                    NextObjectView(dropObject: $game.nextDropObject)
                        .padding([.leading, .top], 8)
                }
                .overlay(alignment: .top) {
                    VStack(spacing: 0) {
                        highScore
                        score
                    }
                }
                .overlay(alignment: .topTrailing) {
                    HStack {
                        RankingsButton($showRankings).environmentObject(game)
                        SettingsButton($showSettings).environmentObject(game)
                    }
                    .padding(.trailing, 26)
                    .padding(.top, 20)
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
    
    var headerBackground: some View {
        Image("scroll_middle")
            .resizable()
            .frame(height: 84)
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
                .animation(.bouncy, value: dropObject.size)
        }
        .padding(.top, 8)
        .padding(.leading)
    }
}

struct Footer: View {
    var body: some View {
        ZStack {
            background
            collage.padding(.horizontal, 16)
        }
    }
        
    var collage: some View {
        HStack {
            Image("coin").resizable().scaledToFit()
            Image("gem1").resizable().scaledToFit()
            Image("gem2").resizable().scaledToFit()
            Image("gem3").resizable().scaledToFit()
            Image("gem4").resizable().scaledToFit()
            Image("gem5").resizable().scaledToFit()
            Image("diamond").resizable().scaledToFit()
            Image("potion").resizable().scaledToFit()
            Image("nugget").resizable().scaledToFit()
            Image("skull").resizable().scaledToFit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background {
            RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                .fill(Color.white.opacity(0.6))
        }
        .frame(height: 45)
    }
    
    var background: some View {
        Image("sand")
            .resizable()
            .frame(height: 100)
    }
}


