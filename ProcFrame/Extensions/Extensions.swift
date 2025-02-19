//
//  Extensions.swift
//  ProcFrame
//
//  Created by yury antony on 25/01/25.
//

import SwiftUI
import Foundation
import SpriteKit

extension NSImage {
    func resized(to targetSize: CGSize) -> NSImage? {
        let originalSize = self.size
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        let scaleFactor = min(widthRatio, heightRatio)
        let newSize = CGSize(width: originalSize.width * scaleFactor,
                             height: originalSize.height * scaleFactor)
        
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: newSize),
                  from: NSRect(origin: .zero, size: originalSize),
                  operation: .copy,
                  fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}

extension String {
    var deletingPathExtension: String {
        (self as NSString).deletingPathExtension
    }
}

extension SKNode {
    var nodeID: UUID? {
        guard let idString = userData?["id"] as? String else { return nil }
        return UUID(uuidString: idString)
    }
    
    func adoptChild(_ child: SKNode, from scene: SKScene) {
        let globalPosition = child.position
        let localPosition = self.convert(globalPosition, from: scene)
        child.removeFromParent()
        child.position = localPosition
        self.addChild(child)
    }
    
    func emancipate(to scene: SKScene) {
        guard let parent = self.parent else { return }
        let globalPosition = parent.convert(self.position, to: scene)
        self.removeFromParent()
        self.position = globalPosition
        scene.addChild(self)
    }
    
    func findNode(withID id: UUID) -> SKSpriteNode? {
        if let spriteNode = self as? SKSpriteNode, spriteNode.nodeID == id {
            return spriteNode
        }
        for child in children {
            if let found = child.findNode(withID: id) {
                return found
            }
        }
        return nil
    }
}


extension SKSpriteNode {
    func addOutline(color: SKColor = .magenta, width: CGFloat = 10) {
        self.childNode(withName: "outline")?.removeFromParent()
        
        let outline = SKShapeNode(rectOf: CGSize(width: self.size.width + width * 1.5,
                                                 height: self.size.height + width * 1.5),
                                  cornerRadius: 2)
        outline.strokeColor = color
        outline.lineWidth = width
        outline.zPosition = self.zPosition - 1
        outline.name = "outline"
        
        let offsetX = (0.5 - self.anchorPoint.x) * self.size.width
        let offsetY = (0.5 - self.anchorPoint.y) * self.size.height
        outline.position = CGPoint(x: offsetX, y: offsetY)
        
        self.addChild(outline)
    }
    
    func removeOutline() {
        self.childNode(withName: "outline")?.removeFromParent()
    }
    
    func refreshOutline() {
        removeOutline()
        addOutline()
    }
}
