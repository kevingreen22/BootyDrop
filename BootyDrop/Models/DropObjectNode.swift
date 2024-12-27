//
//  DropObjectNode.swift
//  BootyDrop
//
//  Created by Kevin Green on 9/25/24.
//

import SpriteKit

// MARK: DropObject node Model

/// A model containing all information for a DropObject node to be initialized with.
class DropObject: SKSpriteNode {
    var dropObjectSize: DropObjectSize = ._30
    var imageName: DropObjectImageName = .coin
    var shape: CGPath = CGPath(ellipseIn: .zero, transform: .none)
    
    init(size: DropObjectSize, position: CGPoint = .zero) {
        super.init(texture: nil, color: .clear, size: size.actual)
        self.dropObjectSize = size
        self.imageName = getImageName(for: dropObjectSize)
        self.texture = SKTexture(imageNamed: self.imageName.rawValue)
        self.name = DropObjectImageName.asString(for: dropObjectSize)
        self.shape = _shape
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getImageName(for size: DropObjectSize) -> DropObjectImageName {
        switch size {
        case ._30: .coin
        case ._50: .gem1
        case ._60: .gem2
        case ._70: .gem3
        case ._80: .gem4
        case ._100: .gem5
        case ._120: .diamond
        case ._150: .goldNugget
        case ._170: .potion
        case ._200: .skull

        }
    }
    
    private var _shape: CGPath {
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
    case goldNugget = "nugget"
    case potion = "potion"
    case skull = "skull"
    
    static func asString(for size: DropObjectSize) -> String {
        switch size {
        case ._30: DropObjectImageName.coin.rawValue
        case ._50: DropObjectImageName.gem1.rawValue
        case ._60: DropObjectImageName.gem2.rawValue
        case ._70: DropObjectImageName.gem3.rawValue
        case ._80: DropObjectImageName.gem4.rawValue
        case ._100: DropObjectImageName.gem5.rawValue
        case ._120: DropObjectImageName.diamond.rawValue
        case ._150: DropObjectImageName.goldNugget.rawValue
        case ._170: DropObjectImageName.potion.rawValue
        case ._200: DropObjectImageName.skull.rawValue
        }
    }
}

enum DropObjectSize: CGFloat, CaseIterable, Comparable {
    static func < (lhs: DropObjectSize, rhs: DropObjectSize) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case _30 = 30
    case _50 = 50
    case _60 = 60
    case _70 = 70
    case _80 = 80
    case _100 = 100
    case _120 = 120
    case _150 = 150
    case _170 = 170
    case _200 = 200
    
    var actual: CGSize {
        switch self {
        case ._30: CGSize(width: 30, height: 30)
        case ._50: CGSize(width: 50, height: 50)
        case ._60: CGSize(width: 60, height: 60)
        case ._70: CGSize(width: 70, height: 70)
        case ._80: CGSize(width: 80, height: 80)
        case ._100: CGSize(width: 100, height: 100)
        case ._120: CGSize(width: 120, height: 120)
        case ._150: CGSize(width: 150, height: 150)
        case ._170: CGSize(width: 170, height: 170)
        case ._200: CGSize(width: 200, height: 200)
        }
    }
    
    static var smallest: DropObjectSize {
        return DropObjectSize.allCases.first!
    }
    
    static var largest: DropObjectSize {
        return DropObjectSize.allCases.last!
    }
    
    /// Returns a random DropObjectSize from the first 6 sizes.
    static var random: DropObjectSize {
        switch self.allCases.randomElement()! {
        case ._30: return ._30
        case ._50: return ._50
        case ._60: return ._60
        case ._70: return ._70
        case ._80: return ._80
        case ._100: return ._100
        default: break
        }
        return self.random
    }
    
    var nextSize: DropObjectSize {
        switch self {
        case ._30: return ._50
        case ._50: return ._60
        case ._60: return ._70
        case ._70: return ._80
        case ._80: return ._100
        case ._100: return ._120
        case ._120: return ._150
        case ._150: return ._170
        case ._170: return ._200
        case ._200: return ._200
        }
    }
    
    static func sizeFor(float: CGFloat) -> DropObjectSize {
        switch float {
        case 0...49.999: return ._30
        case 50...59.999: return ._50
        case 60...69.999: return ._60
        case 70...79.999: return ._70
        case 80...99.999: return ._80
        case 100...119.999: return ._100
        case 120...149.999: return ._120
        case 150...169.999: return ._150
        case 170...199.999: return ._170
        case 200...: return ._200
        default: return ._200
        }
    }
    
}

