//
//  RankingsView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/10/24.
//

import SwiftUI

struct RankingsView: View {
    @Binding var showRankings: Bool

    var body: some View {
        Color.black.opacity(0.7).ignoresSafeArea()
            .transition(.opacity)
        PaperScroll(show: $showRankings) {
            VStack {
                Text("Settings")
                    .font(.custom(CustomFont.rum, size: 30, relativeTo: .largeTitle))
                    .pirateShadow()
                
                HStack {
                    Button(action: {
                        
                    }, label: {
                        ButtonLabel(imageName: "trophy", title: "Today")
                    })
                    
                    Button(action: {}, label: {
                        ButtonLabel(imageName: "trophy", title: "Weekly")
                    })
                    
                    Button(action: {}, label: {
                        ButtonLabel(imageName: "trophy", title: "All-time")
                    })
                }.padding(.bottom, 20)
                
                
                
//                List(rankingData) { cell in
//                    RankingCell()
//                }
                
                
                
                
                Button(action: {}, label: {
                    ButtonLabel(imageName: "trophy", title: "Leaderboard")
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
    @State var showRankings: Bool = true
    
    return RankingsView(showRankings: $showRankings)
}
