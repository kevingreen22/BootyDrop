////
////  FakeGameScene.swift
////  BootyDrop
////
////  Created by Kevin Green on 9/21/24.
////
//
//import SwiftUI
//import SpriteKit
//import CoreMotion
//import Combine
//
//// A simple game scene with falling pirate booty.
//class FakeGameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
//    
//    private var nodeGroup: [DropObject] = []
//    private var backgroundMusic: SKAudioNode!
//    @AppStorage(AppStorageKey.music) var shouldPlayMusic: Bool = true
//
//    
//// MARK: SKScene
//    
//    /* Setup scene here */
//    override func didMove(to view: SKView) {
//        guard let scene else { return }
//        scene.anchorPoint.x = 0
//        scene.anchorPoint.y = 0
//        scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
//        scene.physicsWorld.contactDelegate = self
//        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
//        
//        addBackgroundImage(position: CGPoint(x: scene.frame.width/2, y: scene.frame.height/2), scene: scene)
//        addWelcomeEffectSongNode()
//        addDropObjectNodes()
//    }
//    
//    override func update(_ currentTime: TimeInterval) {
////        print("\(type(of: self)).\(#function)")
//    }
//    
//    
//// MARK: SKPhysicsContactDelegate
//
//    /// Called when there is a collision notification.
//    func didBegin(_ contact: SKPhysicsContact) {
//        guard let nodeA = contact.bodyA.node as? SKSpriteNode else { return }
//        guard let nodeB = contact.bodyB.node as? SKSpriteNode else { return }
//        
////        if nodeA.size == nodeB.size && nodeA.name == nodeB.name {
////            print("matched collision detected:\n  \(nodeA) \nAND\n  \(nodeB)\n")
////            handleCollision(between: nodeA, and: nodeB)
////        }
//    }
//    
//    
//    
//// MARK: Helper Methods
//    
//    func handleCollision(between objectA: SKSpriteNode, and objectB: SKSpriteNode) {
//        
//    }
//    
//    func toggleThemeMusic() {
//        shouldPlayMusic ? backgroundMusic.run(SKAction.stop()) : backgroundMusic.run(SKAction.play())
//    }
//    
//    private func addWelcomeEffectSongNode() {
//        if let musicURL = Bundle.main.url(forResource: "welcome_music_effects", withExtension: "mp3") {
//            backgroundMusic = SKAudioNode(url: musicURL)
//            toggleThemeMusic()
//            addChild(backgroundMusic)
//        }
//    }
//    
//    private func addDropObjectNodes() {
//        guard let scene = scene else { return }
//        var sizes: [DropObjectSize] = DropObjectSize.allCases.shuffled()
//        var positions: [CGPoint] = {
//            var points: [CGPoint] = []
//            let range: Range<Double> = Range(uncheckedBounds: (lower: 100, upper: scene.frame.width-100))
//            for size in sizes {
//                points.append(CGPoint(x: Double.random(in: range), y: scene.frame.height-size.actual.height))
//            }
//            return points
//        }()
//        
//        let wait = SKAction.wait(forDuration: 1, withRange: 2)
//        
//        let block = SKAction.run { [unowned self] in
//            //Debug
////            let now = Date()
////            if let lastSpawnTime = self.lastSpawnTime {
////                let elapsed = now.timeIntervalSince(lastSpawnTime)
////                print("Sprite spawned after : \(elapsed)")
////            }
////            self.lastSpawnTime = now
//            //End Debug
//            
//            let node = DropObject(DOSize: sizes.removeFirst(), position: positions.removeFirst())
//            guard let nodeTexture = node.texture else { return }
//            node.physicsBody = SKPhysicsBody(texture: nodeTexture, size: node.dropObjectSize.actual)
//            node.physicsBody?.restitution = 0
//            node.physicsBody?.friction = 0.2
//            node.physicsBody?.angularDamping = 6
//            node.physicsBody?.linearDamping = 0.3
//            node.physicsBody?.isDynamic = true
//            
//            // collides with everything and send notifications for all collisions.
//            node.physicsBody?.contactTestBitMask = node.physicsBody?.collisionBitMask ?? 0
//            self.addChild(node)
//        }
//        
//        let sequence = SKAction.sequence([block, wait])
//        let loop = SKAction.repeat(sequence, count: 10)
//        run(loop, withKey: "addNodesInSequencedTime")
//    }
//    
//    private func addBackgroundImage(position: CGPoint, scene: SKScene) {
//        let background = SKSpriteNode(imageNamed: "background.jpg")
//        background.position = position
//        background.size = scene.frame.size
//        background.zPosition = -2
//        background.name = "background"
//        addChild(background)
//    }
//    
//}
