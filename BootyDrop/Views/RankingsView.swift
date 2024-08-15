//
//  RankingsViewView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/10/24.
//

import SwiftUI
import GameKit

struct RankingsView: View {
    @Binding var showRankings: Bool
    
    @State private var leaderboardEntries: (GKLeaderboard.Entry?, [GKLeaderboard.Entry], Int) = (nil,[],0)
    let accessPoint = GKAccessPoint.shared

    
    var body: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showRankings) {
            VStack {
                VStack {
                    PirateText("Rankings")
                    
                    HStack {
                        Button(action: {
                            
                        }, label: {
                            HM.ButtonLabel(imageName: "trophy", title: "Today")
                        })
                        
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
                }.padding(.vertical, 16)
                
                Spacer()
                Button {
                    accessPoint.isActive.toggle()
                } label: {
                    HM.ButtonLabel(imageName: "trophy", title: "Leaderboards")
                }
                .buttonStyle(.borderedProminent)
                .offset(y: -30)
            }
        }
        .pirateShadow(y: 24)
        
        .task {
            do {
                leaderboardEntries = try await GameCenterManager.fetchLeaderboard()
            } catch {
                print("Failed to fetch leaderboard: \(error)")
            }
        }
    }
    
    
}


#Preview {
    @State var showRankings: Bool = true
    
    return ZStack {
        RankingsView(showRankings: $showRankings)
    }
}
