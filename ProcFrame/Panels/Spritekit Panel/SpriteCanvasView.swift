//
//  SpriteCanvasView.swift
//  ProcFrame
//
//  Created by yury antony on 28/01/25.
//

import Foundation
import SpriteKit
import SwiftUI

class CanvaSpriteScene: SKScene {
    private var cameraNode = SKCameraNode()
    private var lastMousePosition: CGPoint?
    private var selectedNode: SKSpriteNode?

    override func didMove(to view: SKView) {
        backgroundColor = .white

        if cameraNode.parent == nil {
            addChild(cameraNode)
            camera = cameraNode
            cameraNode.setScale(1.0)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        lastMousePosition = location
        if let node = atPoint(location) as? SKSpriteNode, node.name?.contains("-EDT-") == true {
            if selectedNode == node {
            }

            if let previouslySelected = selectedNode {
                removeHighlight(from: previouslySelected)
            }

            selectedNode = node
            addHighlight(to: node)
        } else {
            if selectedNode != nil {
                removeHighlight(from: selectedNode!)
                selectedNode = nil
            }
        }
    }

    override func mouseDragged(with event: NSEvent) {
        let currentPosition = event.location(in: self)
        
        if let selectedNode = selectedNode {
            let delta = CGPoint(x: currentPosition.x - (lastMousePosition?.x ?? currentPosition.x),
                                y: currentPosition.y - (lastMousePosition?.y ?? currentPosition.y))
            selectedNode.position.x += delta.x
            selectedNode.position.y += delta.y
        } else if let lastPosition = lastMousePosition, let cameraNode = self.camera {
            let delta = CGPoint(x: currentPosition.x - lastPosition.x, y: currentPosition.y - lastPosition.y)
            let smoothingFactor: CGFloat = 0.5
            let smoothDelta = CGPoint(x: delta.x * smoothingFactor, y: delta.y * smoothingFactor)
            cameraNode.position.x -= smoothDelta.x
            cameraNode.position.y -= smoothDelta.y
        }
        
        lastMousePosition = currentPosition
    }

    override func mouseUp(with event: NSEvent) {
        lastMousePosition = nil
    }

    override func keyDown(with event: NSEvent) {
        guard let selectedNode = selectedNode else { return }

        switch event.charactersIgnoringModifiers {
        case "[":
            selectedNode.zPosition -= 1
            print("ZPosition Down: \(selectedNode.zPosition)")
        case "]":
            selectedNode.zPosition += 1
            print("ZPosition Up: \(selectedNode.zPosition)")
        default:
            break
        }
    }

    func simulateScroll(deltaY: CGFloat) {
        guard let cameraNode = self.camera else { return }

        let zoomDelta = deltaY * -0.04
        let newScale = cameraNode.xScale + zoomDelta

        let minScale: CGFloat = 0.5
        let maxScale: CGFloat = 5.0

        cameraNode.setScale(max(min(newScale, maxScale), minScale))
    }

    func addImagesAsNodes(images: [ImportedImage]) {
        for (index, image) in images.enumerated() {
            guard let fullImage = image.fullImage else { continue }
            
            let texture = SKTexture(image: fullImage)
            let spriteNode = SKSpriteNode(texture: texture)
            spriteNode.name = "\(image.name)-EDT-"
            spriteNode.position = CGPoint(x: CGFloat(50 + index * 50), y: size.height / 2)

            let nodeID = UUID()
            if spriteNode.userData == nil {
                spriteNode.userData = NSMutableDictionary()
            }
            spriteNode.userData?["id"] = nodeID.uuidString

            addChild(spriteNode)
        }
    }
    
    private func addHighlight(to node: SKSpriteNode) {
        if node.childNode(withName: "highlight") == nil {
            let highlight = SKShapeNode(rectOf: CGSize(width: node.size.width + 10, height: node.size.height + 10), cornerRadius: 5)
            highlight.strokeColor = .magenta
            highlight.lineWidth = 3
            highlight.position = .zero
            highlight.zPosition = -1
            highlight.name = "highlight"
            node.addChild(highlight)
        }
    }

    private func removeHighlight(from node: SKSpriteNode) {
        node.childNode(withName: "highlight")?.removeFromParent()
    }
}

struct SpriteCanvasView: View {
    let spriteScene: CanvaSpriteScene

    var body: some View {
        ZStack {
            ScrollableView { scrollDelta in
                spriteScene.simulateScroll(deltaY: scrollDelta)
            }
            SpriteView(scene: spriteScene)
        }
        .frame(width: 700, height: 600)
        //.background(Color(nsColor: .controlColor))
    }
}
