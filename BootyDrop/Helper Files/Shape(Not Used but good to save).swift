//
//  Shape.swift
//  BootyDrop
//
//  Created by Kevin Green on 7/23/24.
//

import CoreGraphics

class MyShape {
    
    // Function to create a CGPath representing a circle
    class func circle(center: CGPoint, size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let circleRect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        path.addEllipse(in: circleRect)
        return path
    }
    
    // Function to create a CGPath representing an octagon
    class func octagon(center: CGPoint, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let angleIncrement = CGFloat.pi / 4 // 45 degrees for each segment of the octagon
        
        for i in 0..<8 {
            let angle = angleIncrement * CGFloat(i)
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        return path
    }
    
    // Function to create a CGPath representing a rectangle
    class func rectangle(rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        path.addRect(rect)
        return path
    }
    
    // Function to create a CGPath representing a simple gemstone profile
    class func gemstoneProfile(center: CGPoint, size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let halfSize = size / 2.0
        let cornerOffset = size * 0.2 // Adjust this value for the desired facet depth
        
        // Define the points for the gemstone profile
        let top = CGPoint(x: center.x, y: center.y - halfSize)
        let topLeft = CGPoint(x: center.x - halfSize + cornerOffset, y: center.y - halfSize + cornerOffset)
        let left = CGPoint(x: center.x - halfSize, y: center.y)
        let bottomLeft = CGPoint(x: center.x - halfSize + cornerOffset, y: center.y + halfSize - cornerOffset)
        let bottom = CGPoint(x: center.x, y: center.y + halfSize)
        let bottomRight = CGPoint(x: center.x + halfSize - cornerOffset, y: center.y + halfSize - cornerOffset)
        let right = CGPoint(x: center.x + halfSize, y: center.y)
        let topRight = CGPoint(x: center.x + halfSize - cornerOffset, y: center.y - halfSize + cornerOffset)
        
        // Move to the top point
        path.move(to: top)
        
        // Draw lines and curves to create the faceted shape
        path.addLine(to: topLeft)
        path.addLine(to: left)
        path.addLine(to: bottomLeft)
        path.addLine(to: bottom)
        path.addLine(to: bottomRight)
        path.addLine(to: right)
        path.addLine(to: topRight)
        path.closeSubpath()
        
        return path
    }
    
    // Function to create a CGPath representing an emerald cut gemstone
    class func emeraldCut(center: CGPoint, width: CGFloat, height: CGFloat, cornerCut: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let halfWidth = width / 2.0
        let halfHeight = height / 2.0
        
        // Define the points for the emerald cut shape
        let top = CGPoint(x: center.x, y: center.y - halfHeight + cornerCut)
        let topRight = CGPoint(x: center.x + halfWidth - cornerCut, y: center.y - halfHeight)
        let right = CGPoint(x: center.x + halfWidth, y: center.y - halfHeight + cornerCut)
        let bottomRight = CGPoint(x: center.x + halfWidth, y: center.y + halfHeight - cornerCut)
        let bottom = CGPoint(x: center.x, y: center.y + halfHeight)
        let bottomLeft = CGPoint(x: center.x - halfWidth + cornerCut, y: center.y + halfHeight)
        let left = CGPoint(x: center.x - halfWidth, y: center.y + halfHeight - cornerCut)
        let topLeft = CGPoint(x: center.x - halfWidth, y: center.y - halfHeight + cornerCut)
        
        // Start creating the path
        path.move(to: top)
        path.addLine(to: topRight)
        path.addLine(to: right)
        path.addLine(to: bottomRight)
        path.addLine(to: bottom)
        path.addLine(to: bottomLeft)
        path.addLine(to: left)
        path.addLine(to: topLeft)
        path.closeSubpath()
        
        return path
    }
    
}



import SwiftUI

struct Octagon: Shape {
    var center: CGPoint = .zero
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let cgPath = MyShape.octagon(center: center, radius: radius)
        return Path(cgPath)
    }
}

struct GemstoneProfile: Shape {
    var center: CGPoint = .zero
    var size: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let cgPath = MyShape.gemstoneProfile(center: center, size: size)
        return Path(cgPath)
    }
}

struct Emerald: Shape {
    var center: CGPoint = .zero
    var size: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let cgPath = MyShape.emeraldCut(center: center, width: size, height: size+(size*0.33), cornerCut: size+(size*0.33)/4)
        return Path(cgPath)
    }
}






struct Test: View {
    var body: some View {
        VStack {
            Emerald(size: 100)
                .fill(Color.red)
                .frame(width: 100, height: 100)
            
        }
    }
}

#Preview {
    Test()
}
