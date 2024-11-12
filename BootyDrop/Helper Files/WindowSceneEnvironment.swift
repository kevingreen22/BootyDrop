//
//  WindowSceneEnvironment.swift
//  BootyDrop
//
//  Created by Kevin Green on 9/25/24.
//

import SwiftUI

private struct WindowScene: EnvironmentKey {
    static let defaultValue = UIApplication.shared.connectedScenes.first as? UIWindowScene
}

public extension EnvironmentValues {
    var windowScene: UIWindowScene {
        get { self[WindowScene.self]! }
    set { self[WindowScene.self] = newValue }
  }
}

public extension View {
    func windowScene(_ windowScene: UIWindowScene) -> some View {
    environment(\.windowScene, windowScene)
  }
}



private struct SceneRect: EnvironmentKey {
    static let defaultValue = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
}

public extension EnvironmentValues {
    var sceneRect: CGRect {
        get { self[SceneRect.self]! }
    set { self[SceneRect.self] = newValue }
  }
}

public extension View {
    func sceneRect(_ sceneRect: CGRect) -> some View {
    environment(\.sceneRect, sceneRect)
  }
}
