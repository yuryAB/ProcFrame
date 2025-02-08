//
//  CanvaSpriteScene.swift
//  ProcFrame
//
//  Created by yury antony on 04/02/25.
//

import Foundation
import SpriteKit
import SwiftUI

// MARK: - Main Scene for Node Manipulation, Camera, Zoom, and Rotation
class CanvaSpriteScene: SKScene {
    private var cameraNode = SKCameraNode()
    private var lastMousePosition: CGPoint?
    private var selectedNode: SKSpriteNode?
    private var viewModel: ProcFrameViewModel?
    private var anchorPointIndicator: SKShapeNode?
    private var isRotating = false
    private var rotationIndicator: SKShapeNode?
    
    // Initial scene and camera configuration
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
    
    // MARK: - Public Gesture Methods
    /// Moves the camera by the given delta (via trackpad scroll)
    func moveCamera(by delta: CGPoint) {
        guard let camera = camera else { return }
        let newPosition = CGPoint(x: camera.position.x + delta.x, y: camera.position.y + delta.y)
        let moveAction = SKAction.move(to: newPosition, duration: 0.1)
        moveAction.timingMode = .easeOut
        camera.run(moveAction)
    }
    
    /// Zooms the camera based on the given delta value.
    /// Called via mouse scroll or pinch gesture (trackpad).
    func zoomCamera(by zoomDelta: CGFloat) {
        guard let camera = camera else { return }
        let newScale = max(min(camera.xScale + zoomDelta, 5.0), 0.5)
        let scaleAction = SKAction.scale(to: newScale, duration: 0.1)
        scaleAction.timingMode = .easeOut
        camera.run(scaleAction)
    }
    
    /// Rotates the selected node if rotation mode is active (key "R" pressed)
    func rotateSelectedNode(by deltaRotation: CGFloat) {
        guard isRotating, let node = selectedNode else { return }
        node.zRotation += deltaRotation
    }
    
    // MARK: - Node Selection and Drag
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        lastMousePosition = location
        handleNodeSelection(at: location)
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
    
    override func mouseUp(with event: NSEvent) {
        if let selectedNode = selectedNode,
           let nodeIDString = selectedNode.userData?["id"] as? String,
           let nodeID = UUID(uuidString: nodeIDString),
           let index = viewModel?.nodes.firstIndex(where: { $0.id == nodeID }) {
            viewModel?.nodes[index].position.x = selectedNode.position.x
            viewModel?.nodes[index].position.y = selectedNode.position.y
        }
    }
}

// MARK: - Keyboard Management (Rotation Mode and Node Removal)
extension CanvaSpriteScene {
    override func keyDown(with event: NSEvent) {
        if let characters = event.charactersIgnoringModifiers?.lowercased(), characters == "r" {
            isRotating = true
            return
        }
        switch event.keyCode {
        case 7, 6:
            removeSelectedNode()
        default:
            super.keyDown(with: event)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let characters = event.charactersIgnoringModifiers?.lowercased(), characters == "r" {
            isRotating = false
            rotationIndicator?.removeFromParent()
            rotationIndicator = nil
            return
        }
        super.keyUp(with: event)
    }
    
    private func removeSelectedNode() {
        guard let selectedNode = selectedNode,
              let nodeIDString = selectedNode.userData?["id"] as? String,
              let nodeID = UUID(uuidString: nodeIDString) else { return }
        removeNode(nodeID: nodeID)
    }
}

// MARK: - Node Update, Removal, Highlight, and Anchor Point
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
    
    private func removeAnchorPointIndicator() {
        anchorPointIndicator?.removeFromParent()
        anchorPointIndicator = nil
    }
    
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
        removeAnchorPointIndicator()
        rotationIndicator?.removeFromParent()
        rotationIndicator = nil
        isRotating = false
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
}
