//
//  SKNode+Extension.swift
//  ProcFrame
//
//  Created by yury antony on 04/03/25.
//

import SpriteKit

extension SKNode {
    var nodeID: UUID? {
        guard let idString = userData?["id"] as? String else { return nil }
        return UUID(uuidString: idString)
    }
    
    func adoptChild(_ child: SKNode, from scene: SKScene) {
        let globalPosition = child.position
        let worldRotation = child.zRotation
        
        let localPosition = self.convert(globalPosition, from: scene)
        child.removeFromParent()
        child.position = localPosition
        child.zRotation = worldRotation - self.zRotation
        self.addChild(child)
    }
    
    func emancipate(to scene: SKScene) {
        guard let parent = self.parent else { return }
        let globalPosition = parent.convert(self.position, to: scene)
        self.removeFromParent()
        self.position = globalPosition
        scene.addChild(self)
    }
}
