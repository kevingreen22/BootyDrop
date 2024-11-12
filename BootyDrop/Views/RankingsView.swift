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
    
    @State private var leaderboardEntries: (GKLeaderboard.Entry?, [GKLeaderboard.Entry], Int) = (nil,[],0)

    
    var body: some View {
        RealBlur(style: .dark)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showRankings, pullText: "Close") {
            VStack {
                Spacer()
                comingSoon
                Spacer()
//                rankingsViews
            }.padding(.vertical, 24)
        }
        .pirateShadow(y: 24)
        
        .fullScreenCover(isPresented: $showGamecenterView) {
            GameCenterView()
        }
        
        .task {
            await loadLeaderboards()
        }
    }
    
    
    var leaderBoardButton: some View {
        Button {
            showGamecenterView.toggle()
        } label: {
            HM.ButtonLabel(imageName: "trophy", title: "Leaderboards", frame: CGSize(width: 200, height: 40))
                .frame(width: 200, height: 40)
        }
        .buttonStyle(.borderedProminent)
        .pirateShadow(y: 4)
    }
    
    fileprivate func loadLeaderboards() async {
        do {
            leaderboardEntries = try await GameCenterManager.fetchLeaderboard()
        } catch {
            print("Failed to fetch leaderboard: \(error)")
        }
    }
    
    fileprivate var comingSoon: some View {
        VStack {
            PirateText("Coming", size: 30)
            PirateText("Soon!", size: 30)
        }
    }
    
    @ViewBuilder fileprivate var rankingsViews: some View {
        VStack {
            PirateText("Rankings").pirateShadow(y: 4)
            
            HStack {
                Button {
                    
                } label: {
                    HM.ButtonLabel(imageName: "trophy", title: "Today")
                }
                
                Button(action: {
                    
                }, label: {
                    HM.ButtonLabel(imageName: "trophy", title: "Weekly")
                })
                
                Button(action: {
                    
                }, label: {
                    HM.ButtonLabel(imageName: "trophy", title: "All-time")
                })
            }.padding(.bottom, 8)
            
            ZStack {
                Text("loading...")
                    .font(.custom(CustomFont.rum, size: 16, relativeTo: .subheadline))
                    .opacity(leaderboardEntries.1.isEmpty ? 1 : 0)
                    .offset(y: 20)
                    .pirateShadow()
                
                ForEach(leaderboardEntries.1, id: \.player.gamePlayerID) { entry in
                    HStack {
                        Text("\(entry.player.displayName)")
                        Spacer()
                        Text("\(entry.formattedScore)")
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        Spacer()
        leaderBoardButton
    }
}


#Preview {
    @Previewable @State var showRankings: Bool = true
    
    return ZStack {
        RankingsView(showRankings: $showRankings)
    }
}
