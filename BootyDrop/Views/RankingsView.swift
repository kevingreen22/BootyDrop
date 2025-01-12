//
//  RankingsViewView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/10/24.
//

import SwiftUI
import GameKit
import KGViews

struct RankingsView: View {
    @Binding var showRankings: Bool
    
    @State private var showGamecenterView = false
    @State private var leaderboardEntries: [GKPlayer] = []
    @State private var loadingText: String = "loading..."
    
    @EnvironmentObject var game: GameScene
    
    @AppStorage(AppStorageKey.sound) var shouldPlaySoundEffects: Bool = true

    
    var body: some View {
        RealBlur(style: .dark)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showRankings, shouldPlaySoundEffect: $shouldPlaySoundEffects, height: UIScreen.main.bounds.height*0.60, pullText: "Close") {
            VStack {
                rankingsViews
            }.padding(.vertical, 24)
        }
        .pirateShadow(y: 24)
        
        .fullScreenCover(isPresented: $showGamecenterView) {
            GameCenterView(format: .leaderboards)
        }
        
        .onAppear {
            loadingText = "loading..."
            if !GKLocalPlayer.local.isAuthenticated {
                GameCenterManager.authenticateUser()
            } else if leaderboardEntries.count == 0 {
                Task(priority: .high) {
                    await loadLeaderboards()
                    await MainActor.run {
                        if leaderboardEntries.isEmpty {
                            loadingText = "No Rankings yet"
                        }
                    }
                }
            }
        }
    }
    
    
    fileprivate var leaderBoardButton: some View {
        Button {
            showGamecenterView.toggle()
        } label: {
            HStack(spacing: 8) {
                Image("trophy")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                PirateText("Leaderboards", size: 14)
                    .frame(width: 160, height: 40)
            }
        }
        .buttonStyle(.borderedProminent)
        .pirateShadow(y: 4)
    }
    
    @ViewBuilder fileprivate var rankingsViews: some View {
        VStack {
            PirateText("Rankings").pirateShadow(y: 4)
            
            HStack {
                Button {
                    Task(priority: .userInitiated) {
                        await loadLeaderboards()
                    }
                } label: {
                    PirateText("Today", size: 11, relativeTo: .subheadline, withShadow: false)
                }.buttonStyle(.borderedProminent).pirateShadow()
                
                Button {
                    Task(priority: .userInitiated) {
                        await loadLeaderboards(for: .friendsOnly, timeScope: .week)
                    }
                } label: {
                    PirateText("Week", size: 11, relativeTo: .subheadline, withShadow: false)
                }.buttonStyle(.borderedProminent).pirateShadow()
                
                Button {
                    Task(priority: .userInitiated) {
                        await loadLeaderboards(for: .friendsOnly, timeScope: .allTime)
                    }
                } label: {
                    PirateText("All-Time", size: 11, relativeTo: .subheadline, withShadow: false)
                }.buttonStyle(.borderedProminent).pirateShadow()
                
            }.padding(.bottom, 8)
            
            ZStack {
                if leaderboardEntries.isEmpty {
                    VStack {
                        ProgressView()
                            .opacity(loadingText == "loading..." ? 1 : 0)
                        PirateText(loadingText, size: 14)
                    }.offset(y: 20)
                } else {
                    LazyVStack(alignment: .leading) {
                        ForEach(leaderboardEntries) { player in
                            HStack {
                                Image(uiimage: player.image)
                                Text("\(player.name)")
                                Spacer()
                                Text("\(player.score)")
                            }
                        }
                    }.padding(.horizontal, 24)
                }
            }
        }
        Spacer()
        leaderBoardButton
    }
    
    fileprivate func loadLeaderboards(for playerScope: GKLeaderboard.PlayerScope = .friendsOnly, timeScope: GKLeaderboard.TimeScope = .today, range: NSRange? = NSRange(1...100)
    ) async {
        do {
            leaderboardEntries = try await GameCenterManager.fetchLeaderboard()
        } catch {
            print("\(type(of: self)).\(#function)_failed to fetch leaderboard: \(error)")
        }
    }
    
}



// MARK: Preview
#Preview {
    @Previewable @State var showRankings: Bool = true
    
    return ZStack {
        RankingsView(showRankings: $showRankings)
    }
}
