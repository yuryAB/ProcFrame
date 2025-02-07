//
//  CanvaSpriteScene.swift
//  ProcFrame
//
//  Created by yury antony on 04/02/25.
//

import Foundation
import SpriteKit
import SwiftUI

class CanvaSpriteScene: SKScene {
    private var cameraNode = SKCameraNode()
    private var lastMousePosition: CGPoint?
    private var selectedNode: SKSpriteNode?
    private var viewModel: ProcFrameViewModel?
    private var anchorPointIndicator: SKShapeNode?
    
    func setViewModel(_ viewModel: ProcFrameViewModel) {
        self.viewModel = viewModel
        updateNodes(with: viewModel.nodes)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupCamera()
    }
    
    func setupCamera() {
        if cameraNode.parent == nil {
            addChild(cameraNode)
            camera = cameraNode
            cameraNode.setScale(1.0)
        }
    }
}

extension CanvaSpriteScene {
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        lastMousePosition = location
        handleNodeSelection(at: location)
    }
    
    override func mouseUp(with event: NSEvent) {
        if let selectedNode = selectedNode,
           let nodeIDString = selectedNode.userData?["id"] as? String,
           let nodeID = UUID(uuidString: nodeIDString),
           let index = viewModel?.nodes.firstIndex(where: { $0.id == nodeID }) {
            
            viewModel?.nodes[index].position.x = selectedNode.position.x
            viewModel?.nodes[index].position.y = selectedNode.position.y
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let currentPosition = event.location(in: self)
        
        if let selectedNode = selectedNode {
            let delta = CGPoint(x: currentPosition.x - (lastMousePosition?.x ?? currentPosition.x),
                                y: currentPosition.y - (lastMousePosition?.y ?? currentPosition.y))
            
            selectedNode.position.x += delta.x
            selectedNode.position.y += delta.y
        }
        
        lastMousePosition = currentPosition
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 33:
            moveSelectedNode(zDelta: -1)
        case 30:
            moveSelectedNode(zDelta: 1)
        case 7, 6:
            removeSelectedNode()
        case 126:
            moveCamera(x: 0, y: 60)
        case 125:
            moveCamera(x: 0, y: -60)
        case 123:
            moveCamera(x: -60, y: 0)
        case 124:
            moveCamera(x: 60, y: 0)
        case 27:
            adjustCameraZoom(by: 0.5)
        case 24:
            adjustCameraZoom(by: -0.5)
        default:
            break
        }
    }
}

extension CanvaSpriteScene {
    private func moveSelectedNode(zDelta: Int) {
        guard let selectedNode = selectedNode,
              let viewModel = viewModel,
              let nodeID = selectedNode.nodeID else { return }
        
        var sortedNodes = viewModel.nodes.sorted { $0.position.z < $1.position.z }
        
        guard let currentIndex = sortedNodes.firstIndex(where: { $0.id == nodeID }) else { return }
        
        let newIndex = currentIndex + zDelta
        
        guard newIndex >= 0, newIndex < sortedNodes.count else { return }
        
        sortedNodes.swapAt(currentIndex, newIndex)
        
        for (index, node) in sortedNodes.enumerated() {
            if let originalIndex = viewModel.nodes.firstIndex(where: { $0.id == node.id }) {
                viewModel.nodes[originalIndex].position.z = CGFloat(index)
            }
        }
    }
    
    private func removeSelectedNode() {
        guard let selectedNode = selectedNode,
              let nodeIDString = selectedNode.userData?["id"] as? String,
              let nodeID = UUID(uuidString: nodeIDString) else { return }
        removeNode(nodeID: nodeID)
    }
    
    private func moveCamera(x: CGFloat, y: CGFloat) {
        guard let cameraNode = camera else { return }
        let duration: TimeInterval = 0.15
        let newPosition = CGPoint(x: cameraNode.position.x + x, y: cameraNode.position.y + y)
        let moveAction = SKAction.move(to: newPosition, duration: duration)
        moveAction.timingMode = .easeOut
        cameraNode.run(moveAction)
    }
    
    private func adjustCameraZoom(by zoomDelta: CGFloat) {
        guard let cameraNode = camera else { return }
        let newScale = max(min(cameraNode.xScale + zoomDelta, 5.0), 0.5)
        let duration: TimeInterval = 0.15
        let scaleAction = SKAction.scale(to: newScale, duration: duration)
        scaleAction.timingMode = .easeOut
        cameraNode.run(scaleAction)
    }
}

extension CanvaSpriteScene {
    func updateNodes(with nodes: [ProcNode]) {
        removeAllChildren()
        addChild(cameraNode)
        for procNode in nodes {
            let texture = SKTexture(image: procNode.image.fullImage)
            let spriteNode = SKSpriteNode(texture: texture)
            spriteNode.position = CGPoint(x: procNode.position.x, y: procNode.position.y)
            spriteNode.zPosition = procNode.position.z
            spriteNode.zRotation = procNode.rotation
            spriteNode.xScale = procNode.scale.x
            spriteNode.yScale = procNode.scale.y
            spriteNode.alpha = procNode.opacity
            spriteNode.name = procNode.nodeName
            spriteNode.userData = ["id": procNode.id.uuidString]
            addChild(spriteNode)
            
            if let selectedID = viewModel?.selectedNodeID, selectedID == procNode.id {
                addHighlight(to: spriteNode)
                updateAnchorPointIndicator(for: spriteNode)
                selectedNode = spriteNode
            }
        }
    }
    
    func removeNode(nodeID: UUID) {
        if let nodeToRemove = children.first(where: { ($0.userData?["id"] as? String) == nodeID.uuidString }) {
            nodeToRemove.removeFromParent()
            viewModel?.nodes.removeAll { $0.id == nodeID }
        }
    }
}

// MARK: - HighlightFeature

extension CanvaSpriteScene {
    private func handleNodeSelection(at location: CGPoint) {
        var tappedNode = atPoint(location)

        if tappedNode.name == "highlight", let parent = tappedNode.parent as? SKSpriteNode {
            tappedNode = parent
        }

        if let spriteNode = tappedNode as? SKSpriteNode, spriteNode.name?.contains("-EDT-") == true {
            if selectedNode != spriteNode {
                deselectCurrentNode()
                selectedNode = spriteNode
                addHighlight(to: spriteNode)
                updateAnchorPointIndicator(for: spriteNode)
                viewModel?.selectedNodeID = spriteNode.nodeID
            }
        } else {
            deselectCurrentNode()
            removeAnchorPointIndicator()
        }
    }

    func updateHighlight(for selectedID: UUID?) {
        if let currentNode = selectedNode {
            removeHighlight(from: currentNode)
        }

        guard let selectedID = selectedID else {
            selectedNode = nil
            return
        }

        if let spriteNode = children.first(where: { $0.nodeID == selectedID }) as? SKSpriteNode {
            addHighlight(to: spriteNode)
            selectedNode = spriteNode
        }
    }

    private func deselectCurrentNode() {
        if let current = selectedNode {
            removeHighlight(from: current)
        }
        selectedNode = nil
        viewModel?.selectedNodeID = nil
    }

    private func addHighlight(to node: SKSpriteNode) {
        if node.childNode(withName: "highlight") == nil {
            let highlight = SKShapeNode(rectOf: CGSize(width: node.size.width + 10, height: node.size.height + 10), cornerRadius: 5)
            highlight.strokeColor = .magenta
            highlight.lineWidth = 3
            highlight.position = .zero
            highlight.zPosition = 20
            highlight.name = "highlight"
            node.addChild(highlight)
        }
    }

    private func removeHighlight(from node: SKSpriteNode) {
        node.childNode(withName: "highlight")?.removeFromParent()
    }
}

// MARK: - AnchorPointFeature

extension CanvaSpriteScene {
    private func updateAnchorPointIndicator(for node: SKSpriteNode) {
        anchorPointIndicator?.removeFromParent()
        let localAnchorPosition = CGPoint(
            x: (node.anchorPoint.x - 0.5) * node.size.width,
            y: (node.anchorPoint.y - 0.5) * node.size.height
        )

        let anchorCircle = SKShapeNode(circleOfRadius: 10)
        anchorCircle.fillColor = .brown
        anchorCircle.strokeColor = .blue
        anchorCircle.position = localAnchorPosition
        anchorCircle.zPosition = 20
        anchorCircle.name = "anchorIndicator"

        node.addChild(anchorCircle)
        anchorPointIndicator = anchorCircle
    }

    private func removeAnchorPointIndicator() {
        anchorPointIndicator?.removeFromParent()
        anchorPointIndicator = nil
    }
}
