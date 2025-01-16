//
//  HapticManager.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/21/24.
//

import SwiftUI
import CoreHaptics

public class HapticManager {
    
    static let instance = HapticManager()
        
    /// Check if the device supports haptics.
    var isSupported: Bool {
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        return hapticCapability.supportsHaptics
    }
    
    private init() {}
    
    func feedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat? = nil) {
        let generator = UIImpactFeedbackGenerator(style: style)
        intensity != nil ? generator.impactOccurred(intensity: intensity!) : generator.impactOccurred()
    }

}


public extension View {
    
    @ViewBuilder func haptic<T: Equatable>(feedback type: UINotificationFeedbackGenerator.FeedbackType, trigger: T, condition: @escaping (T) -> Bool) -> some View {
        if HapticManager.instance.isSupported && condition(trigger) == true {
            if #available(iOS 17.0, *) {
                self.onChange(of: trigger) { _, _ in
                    HapticManager.instance.feedback(type)
                }
            } else {
                // Fallback on earlier versions
                self.onChange(of: trigger) { _ in
                    HapticManager.instance.feedback(type)
                }
            }
        } else {
            self
        }
    }
    
    @ViewBuilder func haptic<T: Equatable>(impact style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat? = nil, trigger: T, condition: @escaping (T) -> Bool) -> some View {
        let HM = HapticManager.instance
        if HM.isSupported && condition(trigger) == true {
            if #available(iOS 17.0, *) {
                self.onChange(of: trigger) { _, _ in
                    intensity != nil ? HM.impact(style, intensity: intensity!) : HM.impact(style)
                }
            } else {
                // Fallback on earlier versions
                self.onChange(of: trigger) { _ in
                    intensity != nil ? HM.impact(style, intensity: intensity!) : HM.impact(style)
                }
            }
        } else {
            self
        }
    }
    
}






struct PirateHaptic {
    static var collision: UIImpactFeedbackGenerator.FeedbackStyle = .light
    static var merge: UIImpactFeedbackGenerator.FeedbackStyle = .heavy
    static var toggled: UINotificationFeedbackGenerator.FeedbackType = .success
    
}
