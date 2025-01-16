//
//  GameScene.swift
//  BootyDrop
//
//  Created by Kevin Green on 7/15/24.
//

/*  Music from #Uppbeat (free for Creators!): https://uppbeat.io/t/studiokolomna/corsairs
    License code: X3L0TGIV3ZEIQCOZ
 */

import Foundation
import SwiftUI
import UIKit
import SpriteKit
import KGToolbelt
import Combine

enum GameState: Identifiable, CaseIterable {
    var id: Int {
        switch self {
        case .welcome: 0
        case .playing: 1
        case ._preview: 2
        }
    }
    case welcome
    case playing
    case _preview
}

/// A simple game scene with falling pirate booty.
class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    @Published var score: Int = 0
    @Published var nextDropObject: DropObject = DropObject(size: DropObjectSize.random)
    @Published var isGameOver: Bool = false
    @Published var gameState: GameState = .welcome
    
    @AppStorage(AppStorageKey.music) var shouldPlayMusic: Bool = true
    @AppStorage(AppStorageKey.vibrate) var shouldVibrate: Bool = true
    @AppStorage(AppStorageKey.sound) var shouldPlaySoundEffects: Bool = true
    @AppStorage(AppStorageKey.highScore) var highScore: Int = 0
        
//    public var screenshot: UIImage = UIImage(systemName: "questionmark")!
    public var screenshot: Image = Image(systemName: "questionmark")
    
    private var cancellables = Set<AnyCancellable>()
    private var startLine: SKShapeNode!
    private var currentDropObject: DropObject!
    private var dropGuide: SKNode!
    private var lastDropPosition: CGPoint?
    
//    private var physicsBodies: PhysicsBodies!
    private let dropY: CGFloat = 640
    private var timer: Timer?
    private var gameOverTime: Int = gameoverTimerCount
    private var gameEndingClock: SKLabelNode!

    
    private var backgroundMusic: SKAudioNode!
    private let dropSoundEffectAction = SKAction.playSoundFileNamed("sound_effect_drop.mp3", waitForCompletion: false)
    private let mergeSoundEffectAction = SKAction.playSoundFileNamed("sound_effect_merge.mp3", waitForCompletion: false)
    
    override init(size: CGSize) {
        super.init(size: size)
//        let scene = SKScene(size: size)
        self.scaleMode = .fill
        subscribeToGameState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate override init() {
        super.init(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.scaleMode = .fill
        self.gameState = ._preview
    }
    
    
// MARK: SKScene
    
    /* Initial scene setup here */
    override func didMove(to view: SKView) {
        print("\(type(of: self)).\(#function)")
        guard let scene else { return }
        print("  -scene: \(scene)")
        scene.anchorPoint.x = 0
        scene.anchorPoint.y = 0
        scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
        scene.physicsWorld.contactDelegate = self
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        switch gameState {
        case .playing, .welcome:
            setGameScene(for: gameState)
            
        case ._preview:
            addBackgroundImage(position: CGPoint(x: scene.frame.width/2, y: scene.frame.height/2))
            setupPlayableGameScene(scene)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("\(type(of: self)).\(#function)")
        switch gameState {
        case .welcome:
            break
            
        case .playing, ._preview:
            guard let touch = touches.first else { return }
            let location = CGPoint(x: touch.location(in: self).x, y: dropY)
            currentDropObject.position = location
            dropGuide.position.x = location.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("\(type(of: self)).\(#function)")
        switch gameState {
        case .welcome:
            break
            
        case .playing, ._preview:
            guard let scene else { return }
            guard let touch = touches.first else { return }
            let location = CGPoint(x: touch.location(in: self).x, y: dropY)
            
            currentDropObject.position = location
            dropGuide.position.x = location.x
            
            // Makes it so that the drop-object does not go beyond the scene/screen's edge/
            if currentDropObject.frame.minX < scene.frame.minX {
                currentDropObject.position.x = scene.frame.minX + (currentDropObject.frame.width/2)
                lastDropPosition = currentDropObject.position
                dropGuide.position.x = currentDropObject.position.x
            } else if currentDropObject.frame.maxX > scene.frame.maxX {
                currentDropObject.position.x = scene.frame.maxX - (currentDropObject.frame.width/2)
                lastDropPosition = currentDropObject.position
                dropGuide.position.x = currentDropObject.position.x
            } else {
                lastDropPosition = nil
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("\(type(of: self)).\(#function)")
        switch gameState {
        case .welcome:
            break
            
        case .playing, ._preview:
            guard let scene, let view = scene.view else { return }
            guard let touch = touches.first else { return }
            let location = CGPoint(x: touch.location(in: self).x, y: dropY)
            
            currentDropObject.physicsBody?.isDynamic = true
            currentDropObject.setBitMasks(to: .booty)
            dropGuide.alpha = 0
            
            if let emmiter = SKEmitterNode(fileNamed: "finger_touch") {
                emmiter.position = touch.location(in: self)
                let action = SKAction.wait(forDuration: 0.6)
                emmiter.run(action) { self.destroy(object: emmiter) }
                addChild(emmiter)
            }
            playDropSoundEffect()
            
            view.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now()+0.6) { [unowned self] in
                view.isUserInteractionEnabled = true
                
                let size = self.nextDropObject.dropObjectSize
                self.dropGuide.alpha = 1
                
                calculateLastDropPositionForLargerDropObject(in: scene)
                
                self.currentDropObject = self.addDropObjectNode(dropObjectSize: size, position: lastDropPosition ?? location)
                
                self.dropGuide.position.x = self.currentDropObject.position.x
                
                self.nextDropObject = DropObject(size: DropObjectSize.random)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
//        print("\(type(of: self)).\(#function)")
        switch gameState {
        case .welcome:
            break
            
        case .playing, ._preview:
            guard let scene = scene else { return }
            startGameEndingSequence(scene)
        }
    }
    
    
    
// MARK: SKPhysicsContactDelegate

    /// Called when there is a collision notification.
    func didBegin(_ contact: SKPhysicsContact) {
//        print("\(type(of: self)).\(#function)")
        switch gameState {
        case .welcome:
            break
            
        case .playing, ._preview:
//            print("  -collisionImpulse: \(contact.collisionImpulse)")
            if contact.collisionImpulse > 5 && shouldVibrate {
                HapticManager.instance.impact(PirateHaptic.collision, intensity: contact.collisionImpulse)
            }
            guard let nodeA = contact.bodyA.node as? SKSpriteNode else { return }
            guard let nodeB = contact.bodyB.node as? SKSpriteNode else { return }
            guard nodeA.size.height != DropObjectSize.largest.rawValue && nodeB.size.height != DropObjectSize.largest.rawValue else { return }
            
            if nodeA.size == nodeB.size && nodeA.name == nodeB.name {
//                print("  -matched collision detected:\n  \(nodeA) \nAND\n  \(nodeB)\n")
                handleCollision(between: nodeA, and: nodeB)
            }
        }
    }
    
    
    
// MARK: High level helper methods
    private func subscribeToGameState() {
        $gameState
            .sink { [weak self] state in
                print("  -setting game state")
                self?.setGameScene(for: state)
            }
            .store(in: &cancellables)
    }
    
    private func setGameScene(for state: GameState) {
        print("  -\(#function)")
        guard let scene = scene else { return }
        
        // removes all nodes and actions
        scene.removeAllChildren()
        scene.removeAllActions()
        
        addBackgroundImage(position: CGPoint(x: scene.frame.width/2, y: scene.frame.height/2))

        switch state {
        case .welcome:
            setupWelcomeScene()
            
        case .playing:
            setupPlayableGameScene(scene)
            resetGame()
            
        case ._preview:
            break
        }
    }
    
    private func setupWelcomeScene() {
        print("  -\(#function)")
        addWelcomeEffectSongNode()
        addStaticDropObjectNodes()
    }
    
    private func setupPlayableGameScene(_ scene: SKScene) {
        print("  -\(#function)")
//        physicsBodies = PhysicsBodies()
        
        addThemeSongNode()
            
        addStartLine()
                
        dropGuide = createDropGuide(xPosition: scene.frame.width/2)
        
        currentDropObject = addDropObjectNode(dropObjectSize: .random, position: CGPoint(x: scene.frame.width/2, y: dropY))
    }
    
    private func resetGame() {
        print("  -\(#function)")
        guard let scene = scene else { return }
        // reset startLine color
        startLine.strokeColor = .darkGray

        // reset drop position
        lastDropPosition = nil

        // Reset timer
        timer?.invalidate()
        timer = nil

        // Reset score
        score = 0

        // Reset gameOverTime amount
        gameOverTime = gameoverTimerCount

        // Reset drop guide visibility and position
        dropGuide.alpha = 1
        dropGuide.position.x = scene.frame.width/2
    }
    
    
    
// MARK: Welcome scene methods
    private func addWelcomeEffectSongNode() {
        print("  -\(#function)")
        if let musicURL = Bundle.main.url(forResource: "welcome_music_effects", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic.run(SKAction.stop())
            addChild(backgroundMusic)
            toggleThemeMusic()
        }
    }
    
    private func addStaticDropObjectNodes(count: Int = 10) {
        print("  -\(#function)")
        guard let scene = scene else { return }
        var sizes: [DropObjectSize] = DropObjectSize.allCases.shuffled()
        var positions: [CGPoint] = {
            var points: [CGPoint] = []
            let range: Range<Double> = Range(uncheckedBounds: (lower: 100, upper: scene.frame.width-100))
            for size in sizes {
                points.append(CGPoint(x: Double.random(in: range), y: scene.frame.height-size.actual.height))
            }
            return points
        }()
        
        let wait = SKAction.wait(forDuration: 1, withRange: 2)
        
        let block = SKAction.run { [unowned self] in
            //Debug
//            let now = Date()
//            if let lastSpawnTime = self.lastSpawnTime {
//                let elapsed = now.timeIntervalSince(lastSpawnTime)
//                print("Sprite spawned after : \(elapsed)")
//            }
//            self.lastSpawnTime = now
            //End Debug
            
            let node = DropObject(size: sizes.removeFirst(), position: positions.removeFirst())
            guard let nodeTexture = node.texture else { return }
            node.physicsBody = SKPhysicsBody(texture: nodeTexture, size: node.dropObjectSize.actual)
            node.physicsBody?.restitution = 0
            node.physicsBody?.friction = 0.2
            node.physicsBody?.angularDamping = 6
            node.physicsBody?.linearDamping = 0.3
            node.physicsBody?.isDynamic = true
            
            // collides with everything and send notifications for all collisions.
            node.physicsBody?.contactTestBitMask = node.physicsBody?.collisionBitMask ?? 0
            self.addChild(node)
        }
        
        let sequence = SKAction.sequence([block, wait])
        let loop = SKAction.repeat(sequence, count: count)
        run(loop, withKey: "addNodesInSequencedTime")
    }

    
    
// MARK: Actual game play methods
    func startGameEndingSequence(_ scene: SKScene) {
        guard currentDropObject != nil,
              dropGuide != nil,
              startLine != nil else { return }
        
        // Set startLine color according to how close objects are to the fail line (i.e. startLine).
        if (scene.children.filter({
            $0.name != "background" &&
            $0 != currentDropObject &&
            $0 != dropGuide &&
            $0 != startLine &&
            $0.position.y >= dropY-100
        }).count >= 3) {
            startLine.strokeColor = .red
            startLine.lineWidth = 6
        } else {
            startLine.strokeColor = .darkGray
            startLine.lineWidth = 3
        }
                
        // If any drop object's y position is greater than or equal to the start line, and there's at least 3 of them.
        if scene.children.filter({
            $0.name != "background" &&
            $0 != currentDropObject &&
            $0 != dropGuide &&
            $0 != startLine &&
            $0.frame.maxY >= startLine.frame.maxY
        }).count >= 3 {
            // Then start a timer if its not already started.
            if timer == nil {
                print("  -creating timer")
                addGameEndingClock()
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                    print("  -timer running...\(timer)")
                    // When the timer runs out, the game ends.
                    self?.gameOverTime -= 1
                    if let time = self?.gameOverTime {
                        self?.gameEndingClock.text = time.asSeconds
                    }
                    
                    if self?.gameOverTime == 0 {
                        self?.isGameOver = true
                        if let clock = self?.gameEndingClock {
                            self?.destroy(object: clock)
                        }
                        self?.timer?.invalidate()
                        self?.prepareForScreenshot()
                    }
                }
                RunLoop.current.add(timer!, forMode: .common)
            }
        } else {
            // If all drop-objects fall below the start line, then invalidate the timer and reset timer/timer amount.
            if timer != nil {
                destroy(object: gameEndingClock)
                print("  -invalidating timer")
                timer?.invalidate()
                timer = nil
                gameOverTime = gameoverTimerCount
            }
        }
    }
    
    /// Combines both dropObjects into next dropObjectSize if they are a matching pair (i.e. destroy both and create a new one)
    func handleCollision(between objectA: SKSpriteNode, and objectB: SKSpriteNode) {
//        print("\(type(of: self)).\(#function)")
        switch gameState {
        case .welcome, ._preview: break
            
        case .playing:
            guard let DONode = objectA as? DropObject, let scene = scene else { return }
            let newSize = DONode.dropObjectSize.nextSize
            print("  -currentSize: \(DONode.dropObjectSize.rawValue) - newSize: \(newSize.rawValue)\n")
            let mergeXposition = objectA.position.x + abs(objectA.position.x - objectB.position.x)/2
            let sceneWidth = scene.frame.width-(newSize.rawValue/2)
            let newX = min(mergeXposition, sceneWidth)
            let newY = objectA.position.y + abs(objectA.position.y - objectB.position.y)/2
            let position = CGPoint(x: newX, y: newY)
            
            incrementScore(with: DONode.dropObjectSize)
            
            if let emitter = SKEmitterNode(fileNamed: "merge") {
                emitter.position = position
                emitter.particleSize = CGSize(width: newSize.rawValue, height: newSize.rawValue)
                let action = SKAction.wait(forDuration: 0.4)
                emitter.run(action) { [unowned self] in self.destroy(object: emitter) }
                addChild(emitter)
            }
            
            destroy(object: objectA)
            destroy(object: objectB)
            let newObject = addDropObjectNode(dropObjectSize: newSize, position: position, isDynamic: true)
            newObject?.setBitMasks(to: .booty)
            
#warning("Adjust/replace the next line for merging physics")
            // adds physics push/movement
            newObject?.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -15...15), dy: Int.random(in: -15...15)))
            
            if shouldVibrate { HapticManager.instance.impact(PirateHaptic.merge) }
            playMergeSoundEffect()
        }
    }
    
    func destroy(object: SKNode) {
//        print("\(type(of: self)).\(#function)")
        object.removeFromParent()
    }
    
    func toggleThemeMusic() {
        print("\(type(of: self)).\(#function)_toggling_theme_music: \(shouldPlayMusic)")
        shouldPlayMusic ? backgroundMusic.run(SKAction.play()) : backgroundMusic.run(SKAction.stop())
    }
    
    func playMergeSoundEffect() {
        print("\(type(of: self)).\(#function)_toggling_merge_sound_effect: \(shouldPlaySoundEffects)")
        if shouldPlaySoundEffects {
            scene?.run(mergeSoundEffectAction)
        }
    }
    
    func playDropSoundEffect() {
//        print("\(type(of: self)).\(#function)_toggling_drop_sound_effect: \(shouldPlaySoundEffects)")
        if shouldPlaySoundEffects {
            scene?.run(dropSoundEffectAction)
        }
    }
    
    func updateHighScore() async {
        if score > highScore {
            highScore = score
        }
        try? await GameCenterManager.submit(highScore)
    }
    
    @discardableResult private func addDropObjectNode(dropObjectSize: DropObjectSize, position: CGPoint, isDynamic: Bool = false, withCollision: Bool = false) -> DropObject? {
//        print("  -\(#function)")
        let node = DropObject(size: dropObjectSize, position: position)
        guard let nodeTex = node.texture else { return nil }
        
        node.physicsBody = SKPhysicsBody(texture: nodeTex, size: node.dropObjectSize.actual)
        #warning("This next line replaces the above line. Make sure to fix the actual image-file's sizes to their respective size (in points). Otherwise the size of the objects as your playing the game are all wrong.")
        // node.physicsBody = physicsBodies.getPhysicsBody(for: dropObject.imageName)
        
        node.physicsBody?.restitution = 0
        node.physicsBody?.friction = 0.2
        node.physicsBody?.angularDamping = 6
        node.physicsBody?.linearDamping = 0.3
        node.physicsBody?.isDynamic = isDynamic
        
        if withCollision {
            // WILL collide with everything
            node.setBitMasks(to: .booty)
            // collides with everything and send notifications for all collisions.
//          node.physicsBody?.contactTestBitMask = node.physicsBody?.collisionBitMask ?? 0
        } else {
            // will NOT collide
            node.setBitMasks(to: .none)
        }
        
        addChild(node)
        return node
    }
    
    private func addBackgroundImage(position: CGPoint) {
        print("  -\(#function)")
        guard let scene = scene else { return }
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = position
        background.size = scene.frame.size
        background.zPosition = -2
        background.name = "background"
        addChild(background)
    }
    
    private func addThemeSongNode() {
        print("  -\(#function)")
        if let musicURL = Bundle.main.url(forResource: "theme_song", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic.run(SKAction.stop())
            addChild(backgroundMusic)
            toggleThemeMusic()
        }
    }
    
    private func addStartLine() {
        print("  -\(#function)")
        startLine = SKShapeNode(rect: CGRect(x: 0, y: dropY, width: UIScreen.main.bounds.width, height: 1))
        startLine.strokeColor = .darkGray
        startLine.name = "start_line"
        addChild(startLine)
    }
    
    private func addGameEndingClock() {
        print("  -\(#function)")
        gameEndingClock = SKLabelNode(text: "\(gameOverTime.asSeconds)")
        gameEndingClock.zPosition = 1000
        gameEndingClock.fontSize = 40
        gameEndingClock.fontColor = .red
        gameEndingClock.fontName = CustomFont.rum
        gameEndingClock.position = CGPoint(x: UIScreen.main.bounds.width/2, y: dropY + 30)
        gameEndingClock.name = "gameEndingClock"
        addChild(gameEndingClock)
    }
        
    private func createDropGuide(xPosition: Double) -> SKNode {
        print("  -\(#function)")
        let guideLine = SKSpriteNode(color: .white.withAlphaComponent(0.6), size: CGSize(width: 3, height: dropY))
        guideLine.position.x = xPosition
        guideLine.position.y = dropY/2
        guideLine.name = "guide_line"
        
        addChild(guideLine)
        return guideLine
    }

//    private func createAnimatingDropGuide(xPosition: Double) -> SKNode {
//        print("  -\(#function)")
//        let guideLine = SKSpriteNode(color: .clear, size: CGSize(width: 3, height: dropY))
//        guideLine.position.x = xPosition
//        guideLine.position.y = dropY/2
//        guideLine.name = "guide_line"
//
//        // Add initial dashes
//        let dashSize = CGSize(width: 3, height: 60)
//        for y in stride(from: -dropY/2, to: dropY, by: CGFloat(dashSize.height*2)) {
//            guideLine.addChild(addGuideDash(position: CGPoint(x: 0, y: -y), size: dashSize))
//        }
//        
//        let move = SKAction.moveBy(x: 0, y: -dashSize.height*2, duration: 1)
//
//        // Animate dashes down and add a new dash at the top.
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
//            guard let self = self else { return }
//            let dashLine = self.addGuideDash(position: CGPoint(x: 0, y: self.dropY/2+120), size: self.dashSize)
//            dashLine.alpha = 1
//            guideLine.addChild(dashLine)
//            
//            for child in guideLine.children {
//                child.run(move)
//                if child.position.y < -self.dropY/2 {
//                    self.destroy(object: child)
//                }
//            }
//        })
//        
//        addChild(guideLine)
//        return guideLine
//    }
//    
//    private func addGuideDash(position: CGPoint, size: CGSize) -> SKNode {
//        let dash = SKSpriteNode(color: .white.withAlphaComponent(0.7), size: size)
//        dash.name = "dash"
//        dash.position = position
//        return dash
//    }
    
    private func incrementScore(with dropObjectSize: DropObjectSize) {
        print("  -\(#function).score_increased:\(Int(Double(dropObjectSize.rawValue)*0.1))")
        score += Int(Double(dropObjectSize.rawValue)*0.1)
    }
    
    /// THIS FIXES THE NEXT-OBJECT'S EDGE OVERLAY. So the new drop object bounds does not extend beyond the edge of the scene/screen for dragging.
    private func calculateLastDropPositionForLargerDropObject(in scene: SKScene) {
//        print("  -\(#function)")
        if self.lastDropPosition != nil {
            // Check if next drop-object size is bigger or smaller than previous
            if nextDropObject.dropObjectSize > currentDropObject.dropObjectSize {
                                    
                // Check for leading edge of scene frame
                if lastDropPosition!.x - (nextDropObject.dropObjectSize.rawValue/2) <= scene.frame.minX {
                    // add half the size of the next drop-object size to the lastDropPosition
                    self.lastDropPosition!.x += abs(self.currentDropObject.dropObjectSize.rawValue/2 - nextDropObject.dropObjectSize.rawValue/2)
                    
                // Check for trailing edge of scene
                } else if lastDropPosition!.x + (nextDropObject.dropObjectSize.rawValue/2) >= scene.frame.maxX {
                    // subtract half the size of the next drop-object size to the lastDropPosition
                    self.lastDropPosition!.x -= abs(self.currentDropObject.dropObjectSize.rawValue/2 - nextDropObject.dropObjectSize.rawValue/2)
                }
            }
        }
    }
    
    private func prepareForScreenshot() {
        print("  -\(#function)")
        destroy(object: currentDropObject)
        dropGuide.alpha = 0
        if let snapshot = snapshot() {
            screenshot = snapshot
            print("  -snapshot set")
        }
    }
    
    /// Creates a screen shot from the SKView with the size passed in.
    private func snapshot() -> Image? {
        print("  -\(#function)")
        guard let scene = self.scene, let view = scene.view else { return nil }
        
        let targetSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        view.bounds.origin = CGPoint(x: 0, y: 0)
        
        print("  -screenshot rendering...")
        let image = UIGraphicsImageRenderer(size: targetSize).image { context in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        guard let uiImageCropped = cropImage(
            image,
            toRect:
                CGRect(
                    origin:
                        CGPoint(
                            x: 0,
                            y: startLine.frame.origin.y
                        ),
                    size:
                        CGSize(
                            width: view.bounds.width * 100,
                            height: view.bounds.height * 100
                        )
                )
        ) else { return nil }
        
        return Image(uiImage: uiImageCropped)
    }
    
    private func cropImage(_ image: UIImage, toRect: CGRect) -> UIImage? {
        print("  -\(#function)")
        let cgImage: CGImage! = image.cgImage
        let croppedCGImage: CGImage! = cgImage.cropping(to: toRect)
        return UIImage(cgImage: croppedCGImage)
    }
    
}




enum CollisionCategory: UInt32 {
    case none   = 0x00000000 // 0
//    case ground = 0x00000001 // 1
    case booty  = 0x00000010 //2
    case all    = 0xFFFFFFFF // all bit sets
}

// MARK: SKNode Extension
extension SKNode {
    
    /// Sets category, collision, and contactTest bit masks to the passed in value.
    func setBitMasks(to mask: CollisionCategory) {
        self.physicsBody?.categoryBitMask = mask.rawValue
        self.physicsBody?.collisionBitMask = mask.rawValue
        self.physicsBody?.contactTestBitMask = mask.rawValue
    }
    
}

//class PhysicsBodies {
//    var coinPhysics: SKPhysicsBody!
//    var gem1Physics: SKPhysicsBody!
//    var gem2Physics: SKPhysicsBody!
//    var gem3Physics: SKPhysicsBody!
//    var gem4Physics: SKPhysicsBody!
//    var gem5Physics: SKPhysicsBody!
//    var diamondPhysics: SKPhysicsBody!
//    var nuggetPhysics: SKPhysicsBody!
//    var potionPhysics: SKPhysicsBody!
//    var skullPhysics: SKPhysicsBody!
//    
//    init() {
//        createPhysicsBodies()
//    }
//    
//    func getPhysicsBody(for object: DropObject) -> SKPhysicsBody! {
//        switch object.imageName {
//        case .coin: return coinPhysics.copy() as? SKPhysicsBody
//        case .gem1: return gem1Physics.copy() as? SKPhysicsBody
//        case .gem2: return gem2Physics.copy() as? SKPhysicsBody
//        case .gem3: return gem3Physics.copy() as? SKPhysicsBody
//        case .gem4: return gem4Physics.copy() as? SKPhysicsBody
//        case .gem5: return gem5Physics.copy() as? SKPhysicsBody
//        case .diamond: return diamondPhysics.copy() as? SKPhysicsBody
//        case .potion: return potionPhysics.copy() as? SKPhysicsBody
//        case .goldNugget: return nuggetPhysics.copy() as? SKPhysicsBody
//        case .skull: return skullPhysics.copy() as? SKPhysicsBody
//        }
//    }
//    
//    private func createPhysicsBodies() {
//        let coinTexture = SKTexture(imageNamed: "coin")
//        coinPhysics = SKPhysicsBody(texture: coinTexture, size: coinTexture.size())
//        
//        let gem1Texture = SKTexture(imageNamed: "gem1")
//        gem1Physics = SKPhysicsBody(texture: gem1Texture, size: gem1Texture.size())
//
//        let gem2Texture = SKTexture(imageNamed: "gem2")
//        gem2Physics = SKPhysicsBody(texture: gem2Texture, size: gem2Texture.size())
//
//        let gem3Texture = SKTexture(imageNamed: "gem3")
//        gem3Physics = SKPhysicsBody(texture: gem3Texture, size: gem3Texture.size())
//
//        let gem4Texture = SKTexture(imageNamed: "gem4")
//        gem4Physics = SKPhysicsBody(texture: gem4Texture, size: gem4Texture.size())
//
//        let gem5Texture = SKTexture(imageNamed: "gem5")
//        gem5Physics = SKPhysicsBody(texture: gem5Texture, size: gem5Texture.size())
//
//        let diamondTexture = SKTexture(imageNamed: "diamond")
//        diamondPhysics = SKPhysicsBody(texture: diamondTexture, size: diamondTexture.size())
//
//        let nuggetTexture = SKTexture(imageNamed: "nugget")
//        nuggetPhysics = SKPhysicsBody(texture: nuggetTexture, size: nuggetTexture.size())
//
//        let potionTexture = SKTexture(imageNamed: "potion")
//        potionPhysics = SKPhysicsBody(texture: potionTexture, size: potionTexture.size())
//
//        let skullTexture = SKTexture(imageNamed: "skull")
//        skullPhysics = SKPhysicsBody(texture: skullTexture, size: skullTexture.size())
//
//    }
//}



// MARK: PREVIEW
extension GameScene {
    // Remember these static methods run BEFORE GameScene init
    
    static func previewGameScene(state: GameState) -> GameScene {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.gameState = state
        scene.score = 3929
        return scene
    }
    
    static var previewGameSceneGameEnding: GameScene = {
        print("INIT GAME-ENDING PREVIEW ")
        let scene = GameScene()
        scene.score = 3929
        let addNode = SKAction.run {
            let range: Range<Double> = Range(uncheckedBounds: (lower: 100, upper: scene.frame.width-100))
            let size = DropObjectSize.random
            let node = DropObject(size: size, position: CGPoint(x: Double.random(in: range), y: scene.frame.height-size.actual.height))
//            print("***  -getting static node texture")
            guard let nodeTexture = node.texture else { return }
            node.physicsBody = SKPhysicsBody(texture: nodeTexture, size: node.dropObjectSize.actual)
            node.physicsBody?.restitution = 0
            node.physicsBody?.friction = 0.2
            node.physicsBody?.angularDamping = 6
            node.physicsBody?.linearDamping = 0.3
            node.physicsBody?.isDynamic = true
            
            // collides with everything and send notifications for all collisions.
            node.physicsBody?.contactTestBitMask = node.physicsBody?.collisionBitMask ?? 0
            scene.addChild(node)
//            print("***  -static node added")
        }
        let wait = SKAction.wait(forDuration: 0.3)
        let sequence = SKAction.sequence([addNode, wait])
        let loop = SKAction.repeat(sequence, count: 60)
        scene.run(loop, withKey: "addNodesInSequencedTime")
        
        return scene
    }()
}

#Preview {
    WelcomeView()
        .environmentObject(GameScene.previewGameScene(state: .welcome))
}
