//
//  GameCenterManager.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/13/24.
//

// highscores_1234567890

import SwiftUI
import GameKit
import Combine

class GameCenterManager {
    private let leaderboardIdentifier = "highscores_1234567890"
    let shared = GameCenterManager()
    private init() {}
        
    class func authenticateUser() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            guard vc == nil else {
                // Show the login view controller
//                self.present(viewController, animated: true)
                return
            }
            print("Authenticated as \(GKLocalPlayer.local.displayName)")
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.isActive = localPlayer.isAuthenticated
        }
    }
    
    class func fetchLeaderboard() async throws -> (GKLeaderboard.Entry?, [GKLeaderboard.Entry], Int) {
        let leaderboard = try await GKLeaderboard.loadLeaderboards(IDs: ["highscores_1234567890"]).first

        guard let scores = try await leaderboard?.loadEntries(for: .global, timeScope: .allTime, range: NSRange(1...10)) else { return (nil,[],0) }

//        for entry in scores.1 {
//            let player = entry.player
//            let score = entry.formattedScore
//            let image = try? await entry.player.loadPhoto(for: .small)
//
//            print("\(player.displayName) - \(score)")
//        }
        
        return scores
    }
        
    class func submit(_ highScore: Int, context: Int = 0, player: GKLocalPlayer = .local, leaderboardIDs: [String] = ["highscores_1234567890"]) async throws {
        try await GKLeaderboard.submitScore(
            highScore,
            context: context,
            player: player,
            leaderboardIDs: leaderboardIDs
        )
    }
    
    class func submit(_ achievementID: AchievementID, percentComplete: Double = 100) async throws {
        let achievement = GKAchievement(identifier: achievementID.rawValue)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Failed to report achievement: \(error)")
            }
        }
    }
    
    public enum AchievementID: String {
        case firstWin = "first_win"
    }
    
}



public struct GameCenterView: UIViewControllerRepresentable {
    let viewController: GKGameCenterViewController
    @AppStorage("IsGameCenterActive") var isGKActive:Bool = false

    public init(viewController: GKGameCenterViewController = GKGameCenterViewController(), format:GKGameCenterViewControllerState = .default ) {
        self.viewController = GKGameCenterViewController(state: format)
    }

    public func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let gkVC = viewController
        gkVC.gameCenterDelegate = context.coordinator
        return gkVC
    }

    public func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {
        return
    }

    public func makeCoordinator() -> GKCoordinator {
        return GKCoordinator(self)
    }
    
    public class GKCoordinator: NSObject, GKGameCenterControllerDelegate {
        var view: GameCenterView

        init(_ gkView: GameCenterView) {
            self.view = gkView
        }

        public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.dismiss(animated: true, completion: nil)
            view.isGKActive = false
        }
    }
}



