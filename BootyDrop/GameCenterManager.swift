//
//  GameCenterManager.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/13/24.
//

// com.kevinGreen.BootyDrop.highscore  // <-- iTunesConnect leaderboard ID

import SwiftUI
import GameKit

class GKPlayer: Identifiable {
    var id: UUID = UUID()
    var name: String
    var score: String
    var image: UIImage
    
    init(name: String, score: String, image: UIImage) {
        self.name = name
        self.score = score
        self.image = image
    }
}

class GameCenterManager {
    private static let leaderboardHighscoreID = "com.kevinGreen.BootyDrop.highscore"
    let shared = GameCenterManager()
    private init() {}
        
    
    class func authenticateUser() {
        print("\(type(of: self)).\(#function)")
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
//            guard vc == nil else {
                // Show the login view controller
//                self.present(viewController, animated: true)
//                return
//            }
            print("Authenticated as \(GKLocalPlayer.local.displayName)")
            GKAccessPoint.shared.isActive = false
        }
    }
    
    
    /// Fetches GameCenter Leaderboard data
    /// - Parameters:
    ///   - playerScope: Specifies the type of players for filtering data.
    ///   - timeScope: Specifies the time period for filtering data.
    ///   - range: The amount of players to fetch.
    /// - Returns: A list of Players.
    class func fetchLeaderboard(
        for playerScope: GKLeaderboard.PlayerScope = .friendsOnly,
        timeScope: GKLeaderboard.TimeScope = .today,
        range: NSRange? = NSRange(1...100)
    ) async throws -> [GKPlayer] {
        print("\(type(of: self)).\(#function)")
        var playersList: [GKPlayer] = []
        
        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardHighscoreID])
        
        guard let leaderboard = leaderboards.filter ({ $0.baseLeaderboardID == self.leaderboardHighscoreID }).first else { throw GKError(.invalidParameter) }
        
        let players = try await leaderboard.loadEntries(for: playerScope, timeScope: timeScope, range: range ?? NSRange(1...10))
        
        if players.1.count > 0 {
            for entry in players.1 {
                let image = try await entry.player.loadPhoto(for: .small)
                print("\(entry.player.displayName) - \(entry.formattedScore)")
                
                playersList.append(
                    GKPlayer(name: entry.player.displayName, score: entry.formattedScore, image: image)
                )
                
                playersList.sort { $0.score < $1.score }
            }
        }
        return playersList
    }
        
    
    /// Submits a players high score to Game Center.
    /// - Parameters:
    ///   - highScore: The score to submit.
    ///   - context: The context of the score.
    ///   - player: The local player object.
    ///   - leaderboardIDs: The custom iTunes Connect leaderboard ID.
    class func submit(_ highScore: Int, context: Int = 0, player: GKLocalPlayer = .local, leaderboardIDs: [String] = [leaderboardHighscoreID]) async throws {
        print("\(type(of: self)).\(#function)")
        do {
            try await GKLeaderboard.submitScore(
                highScore,
                context: context,
                player: player,
                leaderboardIDs: leaderboardIDs
            )
        } catch let error {
            throw error
        }
        // this is where you would make a call to calculate achievements.
        // calculateAchievements()
    }
    
    
//    class func submit(_ achievementID: AchievementID, percentComplete: Double = 100) async throws {
//        let achievement = GKAchievement(identifier: achievementID.rawValue)
//        achievement.percentComplete = percentComplete
//        achievement.showsCompletionBanner = true
//        
//        GKAchievement.report([achievement]) { error in
//            if let error = error {
//                print("Failed to report achievement: \(error)")
//            }
//        }
//    }
//    
//    public enum AchievementID: String {
//        case firstWin = "first_win"
//    }
    
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



