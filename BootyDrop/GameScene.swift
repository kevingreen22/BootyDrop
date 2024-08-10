//
//  GameScene.swift
//  BallDrop
//
//  Created by Kevin Green on 7/15/24.
//

import Foundation
import SwiftUI
import UIKit
import SpriteKit

// A simple game scene with falling balls
class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    @Published var score: Int = 0
    @Published var nextDropObject: DropObject = .init(size: DropObjectSize.random)
    
    static let backgoundColor: UIColor = .clear
    
    private var dropObject: SKNode!
    private var dropGuide: SKNode!
    private var lastDropPosition: CGPoint?
    private let dropY: CGFloat = 640
    private let dashSize = CGSize(width: 3, height: 60)
    
    
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
        
        addBackgroundImage(position: CGPoint(x: scene.frame.width/2, y: scene.frame.height/2), scene: scene)
        
        addStartLine()
        
        dropGuide = createDropGuide(position: CGPoint(x: scene.frame.width/2, y: 0))
        
//        addBackgroundTopCutImage(position: CGPoint(x: scene.frame.width/2, y: scene.frame.height/2), scene: scene)
        
        addChild(sceneHeader(position: CGPoint(x: position.x, y: scene.frame.height-dashSize.height-15), size: CGSize(width: scene.frame.width*2, height: scene.frame.height-dropY)))
        
        dropObject = addBallNode(dropObjectSize: .random, position: CGPoint(x: scene.frame.width/2, y: dropY))
                
//        addBottomLine()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = CGPoint(x: touch.location(in: self).x, y: dropY)
        dropObject.position = location
        dropGuide.position.x = location.x
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene else { return }
        guard let touch = touches.first else { return }
        let location = CGPoint(x: touch.location(in: self).x, y: dropY)
        
        dropObject.position = location
        dropGuide.position.x = location.x
        
        // Makes it so that the ball does not go beyond the scene/screen's edge/
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
            
            calculateLastDropPositionForLargerBall(in: scene)
            
            self.dropObject = self.addBallNode(dropObjectSize: size, position: lastDropPosition ?? location)
            
            self.dropGuide.position.x = self.dropObject.position.x
            
            self.nextDropObject = .init(size: .random)
        }
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
    
    func collision(between objectA: SKNode, objectB: SKNode) {
//        print("\(type(of: self)).\(#function)")
        // Combine both balls into next ball size if they are a matching pair (i.e. destroy both balls and create a new one)
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
            addBallNode(dropObjectSize: newSize, position: position, isDynamic: true)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                self.destroy(object: emitter)
            }
        }
    }
    
    func destroy(object: SKNode) {
//        print("\(type(of: self)).\(#function)")
        object.removeFromParent()
    }
    
    @discardableResult private func addBallNode(dropObjectSize: DropObjectSize, position: CGPoint, isDynamic: Bool = false) -> SKSpriteNode? {
//        let dropObject = SKSpriteNode(color: getColor(for: size), size: CGSize(width: size.rawValue, height: size.rawValue))
        let dropObject = DropObject(size: dropObjectSize)
        let texture = SKTexture(imageNamed: dropObject.imageName.rawValue)
        let node = SKSpriteNode(texture: texture, size: dropObject.customSize)
        node.physicsBody = SKPhysicsBody(polygonFrom: dropObject.shape)
        node.physicsBody?.restitution = 0
        node.physicsBody?.friction = 0.7
        node.physicsBody?.angularDamping = 6
        node.physicsBody?.linearDamping = 0.3
        node.physicsBody?.contactTestBitMask = node.physicsBody?.collisionBitMask ?? 0
        node.physicsBody?.isDynamic = isDynamic
        node.position = position
        node.name = dropObject.idName
        
        #warning("temp label")
//        let label = SKLabelNode(fontNamed: "Verdana")
//        label.text = "\(ball.frame.width)"
//        label.fontSize = 18
//        label.position = CGPoint(x: 0, y: 0)
//        dropObject.addChild(label)
        
//        print("adding ball")
        addChild(node)
        return node
    }
    
    private func addBackgroundImage(position: CGPoint, scene: SKScene) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = position
        background.size = scene.frame.size
        background.zPosition = -2
        addChild(background)
    }
    
    private func addBackgroundTopCutImage(position: CGPoint, scene: SKScene) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = position
        background.size = CGSize(width: scene.frame.width, height: abs(scene.frame.width - dropY))
        background.zPosition = 1
        addChild(background)
    }
    
    private func addStartLine() {
        let startLine = SKShapeNode(rect: CGRect(x: 0, y: dropY, width: UIScreen.main.bounds.width, height: 1))
        startLine.strokeColor = .black
        startLine.fillColor = .black
        addChild(startLine)
    }
    
    private func addBottomLine() {
        let bottomLine = SKShapeNode(rect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 3))
        bottomLine.strokeColor = .black
        bottomLine.fillColor = .black
        addChild(bottomLine)
    }
    
    private func createDropGuide(position: CGPoint) -> SKNode {
        let guideLine = SKSpriteNode(color: .clear, size: CGSize(width: 3, height: dropY))
        guideLine.position.x = position.x
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
    
    private func sceneHeader(position: CGPoint, size: CGSize) -> SKNode {
        let header = SKSpriteNode(color: GameScene.backgoundColor, size: size)
        header.name = "header"
        header.position = position
        return header
    }
    
    private func incrementScore(with dropObjectSize: DropObjectSize) {
        print("score increated \(Int(Double(dropObjectSize.rawValue)*0.1))")
        score += Int(Double(dropObjectSize.rawValue)*0.1)
    }
    
    /// THIS FIXES THE NEXT OBJECT'S EDGE OVERLAY. So the new ball does not extend beyond the edge of the scene/screen
    private func calculateLastDropPositionForLargerBall(in scene: SKScene) {
        if self.lastDropPosition != nil {
            // Check if next ballsize is bigger or smaller than previous
            if nextDropObject.dropObjectSize > dropObject.dropObjectSize {
                                    
                // Check for leading edge of scene frame
                if lastDropPosition!.x - (nextDropObject.dropObjectSize.rawValue/2) <= scene.frame.minX {
                    // add half the size of the nextBallSize to the lastDropPosition
                    self.lastDropPosition!.x += abs(self.dropObject.dropObjectSize.rawValue/2 - nextDropObject.dropObjectSize.rawValue/2)
                    
                // Check for trailing edge of scene
                } else if lastDropPosition!.x + (nextDropObject.dropObjectSize.rawValue/2) >= scene.frame.maxX {
                    // subtract half the size of the nextBallSize to the lastDropPosition
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
    var customSize: CGSize = .zero
    var idName: DropObjectIDName.RawValue = "coin"
    var imageName: DropObjectImageName = .coin
    var shape: CGPath = CGPath(ellipseIn: .zero, transform: .none)

    init(size: DropObjectSize) {
        self.dropObjectSize = size
        self.customSize = _customSize
        self.idName = DropObjectIDName.getNameFor(size: dropObjectSize)
        self.imageName = _imageName
        self.shape = _shape
    }
    
    private var _customSize: CGSize {
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
        let size = self.customSize
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

