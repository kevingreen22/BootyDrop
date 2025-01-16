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
    @State var leaderboardEntries: [GKPlayer] = []
    @State private var loadingText: String = "loading..."
    @State private var selectedPlayerScope: Int = GKLeaderboard.PlayerScope.global.rawValue
    @EnvironmentObject var game: GameScene
    
    @AppStorage(AppStorageKey.sound) var shouldPlaySoundEffects: Bool = true

    // Testing
//    var entries = [
//        GKPlayer(name: "Kevin", score: "1200", image: UIImage(named: "skull")!),
//        GKPlayer(name: "Janelle", score: "678", image:  UIImage(named: "skull")!),
//        GKPlayer(name: "Kevin", score: "1200", image:  UIImage(named: "skull")!),
//        GKPlayer(name: "Janelle", score: "678", image:  UIImage(named: "skull")!),
//        GKPlayer(name: "Kevin", score: "1200", image:  UIImage(named: "skull")!),
//        GKPlayer(name: "Janelle", score: "678", image:  UIImage(named: "skull")!),
//        GKPlayer(name: "Kevin", score: "1200", image:  UIImage(named: "skull")!),
//        GKPlayer(name: "Janelle", score: "678", image:  UIImage(named: "skull")!),
//        GKPlayer(name: "Kevin", score: "1200", image:  UIImage(named: "skull")!),
//        GKPlayer(name: "Janelle", score: "678", image:  UIImage(named: "skull")!),
//        GKPlayer(name: "Kevin", score: "1200", image:  UIImage(named: "skull")!),
//        GKPlayer(name: "Janelle", score: "678", image:  UIImage(named: "skull")!)
//    ]
    
    init(showRankings: Binding<Bool>) {
        _showRankings = showRankings
        UISegmentedControl.appearance().selectedSegmentTintColor = .accentSecondary
        UISegmentedControl
            .appearance()
            .setTitleTextAttributes([.font: UIFont(name: CustomFont.rum, size: 10)!], for: .normal)
    }
    
    var body: some View {
        RealBlur(style: .dark)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showRankings, shouldPlaySoundEffect: $shouldPlaySoundEffects, height: UIScreen.main.bounds.height*0.60, pullText: "Close") {
            VStack(spacing: 12) {
                PirateText("Rankings").pirateShadow(y: 4)
                
                PlayerScopeSegmentPicker
                
                RankingsList
            }.padding(.top, 24)
        }
        .pirateShadow(y: 24)
        
        .fullScreenCover(isPresented: $showGamecenterView) {
            GameCenterView(format: .leaderboards)
        }
        
        .onAppear {
//            leaderboardEntries = entries
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
    
        
    fileprivate var PlayerScopeSegmentPicker: some View {
        Picker("", selection: $selectedPlayerScope) {
            PirateText("Friends", size: 11, relativeTo: .subheadline, withShadow: false).tag(GKLeaderboard.PlayerScope.friendsOnly.rawValue)
            PirateText("Global", size: 11, relativeTo: .subheadline, withShadow: false).tag(GKLeaderboard.PlayerScope.global.rawValue)
        }
        .pickerStyle(.segmented)
        .bordered(shape: RoundedRectangle(cornerRadius: 5), color: Color.brown, lineWidth: 1)
        .padding(.horizontal, 30)
        .onChange(of: selectedPlayerScope) { _, newValue in
            switch newValue {
            case 0:
                Task(priority: .userInitiated) {
                    await loadLeaderboards(for: .friendsOnly)
                }
                
            case 1:
                Task(priority: .userInitiated) {
                    await loadLeaderboards(for: .global)
                }
            default: break
            }
        }
    }
    
    fileprivate var RankingsList: some View {
        ZStack {
            if leaderboardEntries.isEmpty {
                VStack {
                    ProgressView()
                        .opacity(loadingText == "loading..." ? 1 : 0)
                    PirateText(loadingText, size: 14)
                }.offset(y: 20)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(leaderboardEntries.indices, id: \.self) { idx in
                            let player = leaderboardEntries[idx]
                            rankingsCellFor(player, index: idx)
                        }
                    }
                }.scrollIndicators(.never)
            }
        }
        .padding(.horizontal, 28)
        .animation(.easeInOut, value: leaderboardEntries)
    }
    
    fileprivate func rankingsCellFor(_ player: GKPlayer, index: Int) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.accentColor.opacity(0.6))
            .stroke(Color.brown)
            .frame(width: .infinity, height: 45)
            .overlay(alignment: .leading) {
                HStack {
                    let place = index+1
                    if place.inRange(of: 1...3) {
                        PirateText("\(place)", size: 14, withShadow: false)
                            .background {
                                Image("trophy")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundStyle(getTrophyColor(for: place).gradient)
                                    .pirateShadow()
                            }
                            .padding(.leading, 4)
                    } else {
                        PirateText("\(place)", size: 14, withShadow: false)
                                .padding(.leading, 4)
                    }
                    
                    Image(uiimage: player.image)
                        .resizable()
                        .frame(width: 35, height: 35)
                        .padding(4)
                    PirateText("\(player.name)", size: 16, withShadow: false)
                    Spacer()
                }
                .padding(8)
            }
            .overlay(alignment: .trailing) {
                VStack(spacing: 2) {
                    Image("coin")
                        .resizable()
                        .frame(width: 20, height: 20)
                    PirateText("\(player.score)", size: 14, withShadow: false)
                }
                .frame(width: 34)
                .padding(.trailing, 8)
            }
    }
    
    fileprivate func getTrophyColor(for index: Int) -> Color {
        switch index {
        case 1: return Color.gold
        case 2: return Color.silver
        case 3: return Color.bronze
        default: return Color.clear
        }
    }
    
    fileprivate func loadLeaderboards(for playerScope: GKLeaderboard.PlayerScope = .friendsOnly, timeScope: GKLeaderboard.TimeScope = .allTime, range: NSRange? = NSRange(1...100)
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
    
    ZStack {
        RankingsView(showRankings: $showRankings)
    }
}
