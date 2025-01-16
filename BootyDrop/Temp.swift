//
//  Temp.swift
//  BootyDrop
//
//  Created by Kevin Green on 1/15/25.
//

import SwiftUI
import GameKit
struct Temp: View {
    @State private var selectedPlayerScope: Int = GKLeaderboard.PlayerScope.global.rawValue
    
    var body: some View {
        Picker("", selection: $selectedPlayerScope) {
            PirateText("Friends", size: 11, relativeTo: .subheadline, withShadow: false).tag(GKLeaderboard.PlayerScope.friendsOnly.rawValue)

            PirateText("Global", size: 11, relativeTo: .subheadline, withShadow: false).tag(GKLeaderboard.PlayerScope.friendsOnly.rawValue)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 30)
    }
}

#Preview {
    Temp()
}
