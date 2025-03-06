//
//  CameraController.swift
//  ProcFrame
//
//  Created by yury antony on 06/03/25.
//

import SpriteKit

class CameraController {
    private var cameraNode: SKCameraNode

    init(cameraNode: SKCameraNode) {
        self.cameraNode = cameraNode
    }
    
    func setupCamera(in scene: SKScene) {
        if cameraNode.parent == nil {
            scene.addChild(cameraNode)
            scene.camera = cameraNode
            cameraNode.setScale(1.0)
        }
    }
    
    func moveCamera(by delta: CGPoint) {
        cameraNode.position = CGPoint(
            x: cameraNode.position.x - delta.x * 2,
            y: cameraNode.position.y + delta.y * 2
        )
    }
    
    func zoomCamera(by zoomDelta: CGFloat) {
        let minScale: CGFloat = 0.5
        let maxScale: CGFloat = 6.0
        let zoomFactor: CGFloat = 1.5
        let newScale = max(min(cameraNode.xScale - (zoomDelta * zoomFactor), maxScale), minScale)
        cameraNode.setScale(newScale)
    }
}
