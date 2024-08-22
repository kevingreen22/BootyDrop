//
//  SoundManager.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/21/24.
//

import SwiftUI
import AVKit

public class SoundManager {
    
//    static let instance = SoundManager()
    
    private static var player: AVAudioPlayer?
    
    private init() { }
    
    /// Plays a sound file contained in the main bundle.
    static func playeffect(_ forResource: String, withExtension: String? = ".mp3") throws {
        guard let url = Bundle.main.url(forResource: forResource, withExtension: withExtension) else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            throw error
        }
    }
    
    /// Plays a sound file contained in the main bundle.
    static func playeffect(_ forResource: String, withExtension: String? = ".mp3") async throws {
        guard let url = Bundle.main.url(forResource: forResource, withExtension: withExtension) else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            throw error
        }
    }
    
}
