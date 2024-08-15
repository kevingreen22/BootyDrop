//
//  GameScene.swift
//  BootyDrop
//
//  Created by Kevin Green on 7/15/24.
//

import Foundation
import SwiftUI
import UIKit
import SpriteKit

// A simple game scene with falling pirate booty.
class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    @Published var score: Int = 0
    @Published var nextDropObject: DropObject = .init(size: DropObjectSize.random)
        
    private var startLine: SKShapeNode!
    private var dropObject: SKNode!
    private var dropGuide: SKNode!
    private var lastDropPosition: CGPoint?
    
    private let dropY: CGFloat = 640
    private let dashSize = CGSize(width: 3, height: 60)
//    private var physicsBodies: PhysicsBodies!
    private var timer: Timer?
    private var gameOverTime: Int = 20
    
    
// MARK: SKScene
    
    override func didMove(to view: SKView) {
        /* Setup scene here */
//        print("\(type(of: self)).\(#function)")
        guard let scene, let view = scene.view else { return }
        print("scene size:\(scene.frame) - view size\(view.frame)")
        scene.anchorPoint.x = 0
        scene.anchorPoint.y = 0
        scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
        scene.physicsWorld.contactDelegate = self
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
//        physicsBodies = PhysicsBodies()
        
        addBackgroundImage(position: CGPoint(x: scene.frame.width/2, y: scene.frame.height/2), scene: scene)
        
        addStartLine()
        
        dropGuide = createDropGuide(xPosition: scene.frame.width/2)
        
        dropObject = addDropObjectNode(dropObjectSize: .random, position: CGPoint(x: scene.frame.width/2, y: dropY))
                
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("\(type(of: self)).\(#function)")
        guard let touch = touches.first else { return }
        let location = CGPoint(x: touch.location(in: self).x, y: dropY)
        dropObject.position = location
        dropGuide.position.x = location.x
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("\(type(of: self)).\(#function)")
        guard let scene else { return }
        guard let touch = touches.first else { return }
        let location = CGPoint(x: touch.location(in: self).x, y: dropY)
        
        dropObject.position = location
        dropGuide.position.x = location.x
        
        // Makes it so that the drop-object does not go beyond the scene/screen's edge/
        if dropObject.frame.minX < scene.frame.minX {
            dropObject.position.x = scene.frame.minX + (dropObject.frame.width/2)
            dropGuide.position.x = dropObject.position.x
            lastDropPosition = dropObject.position
        }
        
        if dropObject.frame.maxX > scene.frame.maxX {
            dropObject.position.x = scene.frame.maxX - (dropObject.frame.width/2)
            dropGuide.position.x = dropObject.position.x
            lastDropPosition = dropObject.position
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("\(type(of: self)).\(#function)")
        guard let scene, let view = scene.view else { return }
        guard let touch = touches.first else { return }
        let location = CGPoint(x: touch.location(in: self).x, y: dropY)
        lastDropPosition = dropObject.position
        dropObject.position = location
        dropObject.physicsBody?.isDynamic = true
        dropGuide.alpha = 0
        
        if let emmiter = SKEmitterNode(fileNamed: "finger_touch") {
            emmiter.position = touch.location(in: self)
            addChild(emmiter)
        }
        
        view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.6) { [self] in
            view.isUserInteractionEnabled = true
            
            let size = self.nextDropObject.dropObjectSize
            self.dropGuide.alpha = 1
            
            calculateLastDropPositionForLargerDropObject(in: scene)
            
            self.dropObject = self.addDropObjectNode(dropObjectSize: size, position: lastDropPosition ?? location)
            
            self.dropGuide.position.x = self.dropObject.position.x
            
            self.nextDropObject = .init(size: .random)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let scene = scene else { return }
        startGameEndingSequence(scene)
    }
    
    
// MARK: SKPhysicsContactDelegate

    // Called when there is a collision
    func didBegin(_ contact: SKPhysicsContact) {
//        print("\(type(of: self)).\(#function)")
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        guard nodeA.name != DropObjectIDName.largest.rawValue && nodeB.name != DropObjectIDName.largest.rawValue else { return }
        if let nameA = nodeA.name, let nameB = nodeB.name {
            print("collision detected for: \(nameA) & \(nameB)")
        }
        
        if nodeA.name == nodeB.name {
            print("matched collision detected")
            collision(between: nodeA, objectB: nodeB)
        }
    }
    
    
    
// MARK: Helper Methods
    
    func resetGame() {
        // Remove all drop-objects
        scene?.children.forEach({ node in
            if node.name != "background" && node.name != dropGuide.name && node.name != startLine.name {
                if let child = node as? SKSpriteNode {
                    child.removeFromParent()
                }
            }
        })
        
        // reset drop position
        lastDropPosition = nil
        
        // Reset timer
        timer?.invalidate()
        timer = nil
        
        // Reset score
        score = 0
        
        // Reset gameOverTime amount
        gameOverTime = 20
        
        // Reset first drop-object
        dropObject = addDropObjectNode(dropObjectSize: .random, position: CGPoint(x: (scene?.frame.width ?? 450)/2, y: dropY))
        dropGuide.position.x = (scene?.frame.width ?? 450)/2
        
    }
    
    func startGameEndingSequence(_ scene: SKScene) {
//        print("\(type(of: self)).\(#function)")
        // if any drop object's y position is greater than or equal to the start line,
        if !scene.children.filter({
            $0 != dropObject &&
            $0.name != "background" &&
            $0.name != dropGuide.name &&
            $0.name != startLine.name &&
            $0.position.y <= startLine.position.y
        }).isEmpty {
            // Then start a timer (turn start line color red)
            if timer == nil {
                startLine.strokeColor = .red
                print("creating timer")
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                    print("timer running \(timer)")
                    // When the timer runs out the game ends.
                    self?.gameOverTime -= 1
                    
                    if self?.gameOverTime == 0 {
                        self?.timer?.invalidate()
                        self?.timer = nil
                        self?.gameOverTime = 20
                        self?.startLine.strokeColor = .darkGray
                    }
                }
                RunLoop.current.add(timer!, forMode: .common)
            }
        } else {
            // If all drop-objects fall below the start line, then invalidate the timer
            if timer != nil {
                print("invalidating timer")
                timer?.invalidate()
                timer = nil
                self.gameOverTime = 20
                self.startLine.strokeColor = .darkGray
            }
        }
    }
    
    func collision(between objectA: SKNode, objectB: SKNode) {
//        print("\(type(of: self)).\(#function)")
        // Combine both dropObjects into next dropObject size if they are a matching pair (i.e. destroy both and create a new one)
        let newSize = objectA.dropObjectSize.nextSize
        print("currentSize: \(objectA.dropObjectSize.rawValue) - newSize: \(newSize.rawValue)\n")
        let newX = objectA.position.x + abs(objectA.position.x - objectB.position.x)/2
        let position = CGPoint(x: newX, y: objectA.position.y)
        
        incrementScore(with: objectA.dropObjectSize)
        
        if let emitter = SKEmitterNode(fileNamed: "merge") {
            emitter.position = position
            emitter.particleSize = CGSize(width: newSize.rawValue, height: newSize.rawValue)
            addChild(emitter)
            destroy(object: objectA)
            destroy(object: objectB)
            let newObject = addDropObjectNode(dropObjectSize: newSize, position: position, isDynamic: true)
            newObject?.physicsBody?.applyImpulse(CGVector(dx: 15, dy: -10)) // adds explosion push
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                self.destroy(object: emitter)
            }
        }
    }
    
    func destroy(object: SKNode) {
//        print("\(type(of: self)).\(#function)")
        object.removeFromParent()
    }
    
    @discardableResult private func addDropObjectNode(dropObjectSize: DropObjectSize, position: CGPoint, isDynamic: Bool = false) -> SKSpriteNode? {
//        print("\(type(of: self)).\(#function)")
        let dropObject = DropObject(size: dropObjectSize)
        let texture = SKTexture(imageNamed: dropObject.imageName.rawValue)
        let node = SKSpriteNode(texture: texture, size: dropObject.size)
        
        node.physicsBody = SKPhysicsBody(texture: texture, size: dropObject.size)
        #warning("This next line replaces the above line. Make sure to fix the actual image file's sizes to their respective size (in points). Otherwise the size of the objects as your playing the game are all wrong.")
        // node.physicsBody = physicsBodies.getPhysicsBody(for: dropObject.imageName)
        
        node.physicsBody?.restitution = 0
        node.physicsBody?.friction = 0.7
        node.physicsBody?.angularDamping = 6
        node.physicsBody?.linearDamping = 0.3
        node.physicsBody?.contactTestBitMask = node.physicsBody?.collisionBitMask ?? 0
        node.physicsBody?.isDynamic = isDynamic
        node.position = position
        node.name = dropObject.idName
        
        addChild(node)
        return node
    }
        
    private func addBackgroundImage(position: CGPoint, scene: SKScene) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = position
        background.size = scene.frame.size
        background.zPosition = -2
        background.name = "background"
        addChild(background)
    }
    
    private func addStartLine() {
        startLine = SKShapeNode(rect: CGRect(x: 0, y: dropY, width: UIScreen.main.bounds.width, height: 1))
        startLine.strokeColor = .darkGray
//        startLine.fillColor = .darkGray
        startLine.name = "start_line"
        addChild(startLine)
    }
        
    private func createDropGuide(xPosition: Double) -> SKNode {
        let guideLine = SKSpriteNode(color: .clear, size: CGSize(width: 3, height: dropY))
        guideLine.position.x = xPosition
        guideLine.position.y = dropY/2
        guideLine.name = "guide_line"
        
        // Add initial dashes
        for y in stride(from: -dropY/2, to: dropY, by: CGFloat(dashSize.height*2)) {
            guideLine.addChild(addGuideDash(position: CGPoint(x: 0, y: -y), size: dashSize))
        }
        
        let move = SKAction.moveBy(x: 0, y: -dashSize.height*2, duration: 1)

        // Animate dashes down and add a new dash at the top.
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            let dashLine = self.addGuideDash(position: CGPoint(x: 0, y: self.dropY/2+120), size: self.dashSize)
            dashLine.alpha = 1
            guideLine.addChild(dashLine)
            
            for child in guideLine.children {
                child.run(move)
                if child.position.y < -self.dropY/2 {
//                    print("removing dash")
                    child.removeFromParent()
                }
            }
        })
        
        addChild(guideLine)
        return guideLine
    }
    
    private func addGuideDash(position: CGPoint, size: CGSize) -> SKNode {
        let dash = SKSpriteNode(color: .white.withAlphaComponent(0.7), size: size)
        dash.name = "dash"
        dash.position = position
        return dash
    }
    
    private func incrementScore(with dropObjectSize: DropObjectSize) {
//        print("\(type(of: self)).\(#function).score_increased:\(Int(Double(dropObjectSize.rawValue)*0.1))")
        score += Int(Double(dropObjectSize.rawValue)*0.1)
    }
    
    /// THIS FIXES THE NEXT OBJECT'S EDGE OVERLAY. So the new drop object bounds does not extend beyond the edge of the scene/screen
    private func calculateLastDropPositionForLargerDropObject(in scene: SKScene) {
        print("\(type(of: self)).\(#function)")
        if self.lastDropPosition != nil {
            // Check if next drop-object size is bigger or smaller than previous
            if nextDropObject.dropObjectSize > dropObject.dropObjectSize {
                                    
                // Check for leading edge of scene frame
                if lastDropPosition!.x - (nextDropObject.dropObjectSize.rawValue/2) <= scene.frame.minX {
                    // add half the size of the next drop-object size to the lastDropPosition
                    self.lastDropPosition!.x += abs(self.dropObject.dropObjectSize.rawValue/2 - nextDropObject.dropObjectSize.rawValue/2)
                    
                // Check for trailing edge of scene
                } else if lastDropPosition!.x + (nextDropObject.dropObjectSize.rawValue/2) >= scene.frame.maxX {
                    // subtract half the size of the next drop-object size to the lastDropPosition
                    self.lastDropPosition!.x -= abs(self.dropObject.dropObjectSize.rawValue/2 - nextDropObject.dropObjectSize.rawValue/2)
                }
            }
        }
    }
    
}



// MARK: SKNode Extension
extension SKNode  {
    var dropObjectSize: DropObjectSize {
        print(self.frame.height)
        let sprite = self.childNode(withName: "dropObject")
        return DropObjectSize.sizeFor(float: sprite?.frame.height ?? self.frame.height)
    }
}


// MARK: DropObject Model
struct DropObject {
    var dropObjectSize: DropObjectSize
    var size: CGSize = .zero
    var idName: DropObjectIDName.RawValue = "coin"
    var imageName: DropObjectImageName = .coin
    var shape: CGPath = CGPath(ellipseIn: .zero, transform: .none)

    init(size: DropObjectSize) {
        self.dropObjectSize = size
        self.size = _actual
        self.idName = DropObjectIDName.getNameFor(size: dropObjectSize)
        self.imageName = _imageName
        self.shape = _shape
    }
    
    private var _actual: CGSize {
        let size = self.dropObjectSize.rawValue
        switch self.imageName {
//        case .coin: return CGSize(width: size, height: size)
//        case .blueGem: return CGSize(width: size*0.5, height: size*0.5)
//        case .greenGem: return CGSize(width: size*0.5, height: (size*0.5) + (size*0.33))
//        case .redGem: return CGSize(width: size, height: size)
//        case .goldBrick: return CGSize(width: size*0.5, height: (size*0.5) + (size*0.33))
//        case .skull: return CGSize(width: size*0.5, height: size*0.5)
            
        default: return CGSize(width: size, height: size)
        }
    }
    
    private var _imageName: DropObjectImageName {
        switch self.dropObjectSize {
        case ._30: .coin
        case ._40: .gem1
        case ._50: .gem2
        case ._60: .gem3
        case ._70: .gem4
        case ._80: .gem5
        case ._100: .diamond
        case ._120: .goldNugget
        case ._130: .potion
        case ._150: .skull
        }
    }
    
    private var _shape: CGPath {
        let size = self._actual
        switch self.imageName {
//        case .coin: return MyShape.circle(center: .zero, size: size.height)
//
//        case .blueGem: return MyShape.octagon(center: .zero, radius: size.height)
//
//        case .greenGem: return MyShape.emeraldCut(center: .zero, width: size.width, height: size.height, cornerCut: size.height*0.33)
//
//        case .redGem: return MyShape.gemstoneProfile(center: .zero, size: size.height)
//
//        case .goldBrick: return MyShape.rectangle(rect: CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height)))
//
//        case .skull: return MyShape.circle(center: .zero, size: size.height)
            
        default: return MyShape.circle(center: .zero, size: size.height)
        }
    }
    
}

enum DropObjectImageName: String, RawRepresentable {
    case coin = "coin"
    case gem1 = "gem1"
    case gem2 = "gem2"
    case gem3 = "gem3"
    case gem4 = "gem4"
    case gem5 = "gem5"
    case diamond = "diamond"
    case potion = "potion"
    case goldNugget = "nugget"
    case skull = "skull"
}

enum DropObjectSize: CGFloat, CaseIterable, Comparable {
    static func < (lhs: DropObjectSize, rhs: DropObjectSize) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case _30 = 30
    case _40 = 40
    case _50 = 50
    case _60 = 60
    case _70 = 70
    case _80 = 80
    case _100 = 100
    case _120 = 120
    case _130 = 130
    case _150 = 150
    
//    var actual: CGSize {
//        switch self {
//        case ._30: CGSize(width: 30, height: 30)
//        case ._40: CGSize(width: 40, height: 40)
//        case ._50: CGSize(width: 50, height: 50)
//        case ._60: CGSize(width: 60, height: 60)
//        case ._70: CGSize(width: 70, height: 70)
//        case ._80: CGSize(width: 80, height: 80)
//        case ._100: CGSize(width: 100, height: 100)
//        case ._120: CGSize(width: 120, height: 120)
//        case ._130: CGSize(width: 130, height: 130)
//        case ._150: CGSize(width: 150, height: 150)
//        }
//    }
    
    static var smallest: DropObjectSize {
        return DropObjectSize.allCases.first!
    }
    
    static var largest: DropObjectSize {
        return DropObjectSize.allCases.last!
    }
    
    static var random: DropObjectSize {
        switch self.allCases.randomElement()! {
        case ._30: return ._30
        case ._40: return ._40
        case ._50: return ._50
        case ._60: return ._60
        case ._70: return ._70
        case ._80: return ._80
        default: break
        }
        return self.random
    }
    
    var nextSize: DropObjectSize {
        switch self {
        case ._30: return ._40
        case ._40: return ._50
        case ._50: return ._60
        case ._60: return ._70
        case ._70: return ._80
        case ._80: return ._100
        case ._100: return ._120
        case ._120: return ._130
        case ._130: return ._150
        case ._150: return ._150
        }
    }
    
    static func sizeFor(float: CGFloat) -> DropObjectSize {
        switch float {
        case 0...39.999: return ._30
        case 40...49.999: return ._40
        case 50...59.999: return ._50
        case 60...69.999: return ._60
        case 70...79.999: return ._70
        case 80...99.999: return ._80
        case 100...109.999: return ._100
        case 110...119.999: return ._120
        case 120...149.999: return ._130
        case 150...: return ._150
        default: fatalError()
        }
    }
    
}

enum DropObjectIDName: String, RawRepresentable, CaseIterable {
    case _30 = "30"
    case _40 = "40"
    case _50 = "50"
    case _60 = "60"
    case _70 = "70"
    case _80 = "80"
    case _100 = "100"
    case _120 = "120"
    case _130 = "130"
    case _150 = "150"
    
    static var smallest: DropObjectIDName {
        return DropObjectIDName.allCases.first!
    }
    
    static var largest: DropObjectIDName {
        return DropObjectIDName.allCases.last!
    }
    
    static func getNameFor(size: DropObjectSize) -> String {
        switch size {
        case ._30: "30"
        case ._40: "40"
        case ._50: "50"
        case ._60: "60"
        case ._70: "70"
        case ._80: "80"
        case ._100: "100"
        case ._120: "120"
        case ._130: "130"
        case ._150: "150"
        }
    }
    
}

class PhysicsBodies {
    var coinPhysics: SKPhysicsBody!
    var gem1Physics: SKPhysicsBody!
    var gem2Physics: SKPhysicsBody!
    var gem3Physics: SKPhysicsBody!
    var gem4Physics: SKPhysicsBody!
    var gem5Physics: SKPhysicsBody!
    var diamondPhysics: SKPhysicsBody!
    var nuggetPhysics: SKPhysicsBody!
    var potionPhysics: SKPhysicsBody!
    var skullPhysics: SKPhysicsBody!
    
    init() {
        createPhysicsBodies()
    }
    
    func getPhysicsBody(for object: DropObject) -> SKPhysicsBody! {
        switch object.imageName {
        case .coin: return coinPhysics.copy() as? SKPhysicsBody
        case .gem1: return gem1Physics.copy() as? SKPhysicsBody
        case .gem2: return gem2Physics.copy() as? SKPhysicsBody
        case .gem3: return gem3Physics.copy() as? SKPhysicsBody
        case .gem4: return gem4Physics.copy() as? SKPhysicsBody
        case .gem5: return gem5Physics.copy() as? SKPhysicsBody
        case .diamond: return diamondPhysics.copy() as? SKPhysicsBody
        case .potion: return potionPhysics.copy() as? SKPhysicsBody
        case .goldNugget: return nuggetPhysics.copy() as? SKPhysicsBody
        case .skull: return skullPhysics.copy() as? SKPhysicsBody
        }
    }
    
    private func createPhysicsBodies() {
        let coinTexture = SKTexture(imageNamed: "coin")
        coinPhysics = SKPhysicsBody(texture: coinTexture, size: coinTexture.size())
        
        let gem1Texture = SKTexture(imageNamed: "gem1")
        gem1Physics = SKPhysicsBody(texture: gem1Texture, size: gem1Texture.size())

        let gem2Texture = SKTexture(imageNamed: "gem2")
        gem2Physics = SKPhysicsBody(texture: gem2Texture, size: gem2Texture.size())

        let gem3Texture = SKTexture(imageNamed: "gem3")
        gem3Physics = SKPhysicsBody(texture: gem3Texture, size: gem3Texture.size())

        let gem4Texture = SKTexture(imageNamed: "gem4")
        gem4Physics = SKPhysicsBody(texture: gem4Texture, size: gem4Texture.size())

        let gem5Texture = SKTexture(imageNamed: "gem5")
        gem5Physics = SKPhysicsBody(texture: gem5Texture, size: gem5Texture.size())

        let diamondTexture = SKTexture(imageNamed: "diamond")
        diamondPhysics = SKPhysicsBody(texture: diamondTexture, size: diamondTexture.size())

        let nuggetTexture = SKTexture(imageNamed: "nugget")
        nuggetPhysics = SKPhysicsBody(texture: nuggetTexture, size: nuggetTexture.size())

        let potionTexture = SKTexture(imageNamed: "potion")
        potionPhysics = SKPhysicsBody(texture: potionTexture, size: potionTexture.size())

        let skullTexture = SKTexture(imageNamed: "skull")
        skullPhysics = SKPhysicsBody(texture: skullTexture, size: skullTexture.size())

    }
}






#Preview {
    @StateObject var game: GameScene = {
        let scene = GameScene()
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return scene
    }()
    
    return ContentView()
        .environmentObject(game)
}
