//
//  Extensions.swift
//  ProcFrame
//
//  Created by yury antony on 25/01/25.
//

import SpriteKit

extension SKSpriteNode {
    func drawOutline(color: SKColor = .magenta, width: CGFloat = 5) {
        self.childNode(withName: "outline")?.removeFromParent()
        
        let outline = SKShapeNode(rectOf: CGSize(width: self.size.width + width * 1.1,
                                                 height: self.size.height + width * 1.1),
                                  cornerRadius: 3)
        outline.strokeColor = color
        outline.lineWidth = width
        outline.zPosition = 10
        outline.name = "outline"
        
        let offsetX = (0.5 - self.anchorPoint.x) * self.size.width
        let offsetY = (0.5 - self.anchorPoint.y) * self.size.height
        outline.position = CGPoint(x: offsetX, y: offsetY)
        
        self.addChild(outline)
    }
    
    func removeOutline() {
        self.childNode(withName: "outline")?.removeFromParent()
    }
}
