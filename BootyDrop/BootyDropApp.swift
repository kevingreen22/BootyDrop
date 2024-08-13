//
//  BootyDropApp.swift
//  BootyDrop
//
//  Created by Kevin Green on 7/23/24.
//

import SwiftUI

@main
struct BootyDropApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    GameCenterManager.authenticateUser()
                }
        }
    }
}
