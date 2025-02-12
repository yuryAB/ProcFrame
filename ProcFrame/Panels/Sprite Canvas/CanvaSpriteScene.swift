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
    private var isRotating = false
    private var rotationIndicator: SKShapeNode?
    private var isDraggingAnchorIndicator = false

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

    func moveCamera(by delta: CGPoint) {
        if isRotating { return }
        let deltaX = delta.x * 1.5
        let deltaY = delta.y * 1.5
        cameraNode.position = CGPoint(x: cameraNode.position.x - deltaX,
                                      y: cameraNode.position.y + deltaY)
    }

    func zoomCamera(by zoomDelta: CGFloat) {
        if isRotating { return }
        let newScale = max(min(cameraNode.xScale - (zoomDelta * 1.5), 5.0), 0.5)
        cameraNode.setScale(newScale)
    }

    func rotateSelectedNode(by deltaRotation: CGFloat) {
        guard isRotating, let node = selectedNode else { return }
        node.zRotation += deltaRotation / 50
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        lastMousePosition = location
        handleNodeSelection(at: location)
    }

    override func mouseDragged(with event: NSEvent) {
        if isDraggingAnchorIndicator {
            handleAnchorIndicatorDrag(with: event)
            return
        }
        let currentPosition = event.location(in: self)
        if let selectedNode = selectedNode {
            let deltaX = currentPosition.x - (lastMousePosition?.x ?? currentPosition.x)
            let deltaY = currentPosition.y - (lastMousePosition?.y ?? currentPosition.y)
            selectedNode.position.x += deltaX
            selectedNode.position.y += deltaY
        }
        lastMousePosition = currentPosition
    }

    override func mouseUp(with event: NSEvent) {
        if isDraggingAnchorIndicator, let node = selectedNode, let indicator = anchorPointIndicator, let nodeID = node.nodeID {
            updateAnchorPoint(for: node, with: indicator, nodeID: nodeID)
            isDraggingAnchorIndicator = false
            removeAnchorPointIndicator()
            return
        }

        guard let selectedNode = selectedNode, let nodeID = selectedNode.nodeID,
              let index = viewModel?.nodes.firstIndex(where: { $0.id == nodeID }) else { return }

        viewModel?.nodes[index].position = selectedNode.position
        viewModel?.nodes[index].anchorPoint = selectedNode.anchorPoint
    }

    private func updateAnchorPoint(for node: SKSpriteNode, with indicator: SKShapeNode, nodeID: UUID) {
        guard let index = viewModel?.nodes.firstIndex(where: { $0.id == nodeID }) else { return }

        let oldAnchor = node.anchorPoint
        let dragOffset = indicator.position

        let newAnchor = CGPoint(
            x: min(max(oldAnchor.x + dragOffset.x / node.size.width, 0), 1),
            y: min(max(oldAnchor.y + dragOffset.y / node.size.height, 0), 1)
        )

        let compensation = CGPoint(
            x: (oldAnchor.x - newAnchor.x) * node.size.width * node.xScale,
            y: (oldAnchor.y - newAnchor.y) * node.size.height * node.yScale
        )

        node.position.x += compensation.x
        node.position.y += compensation.y
        node.anchorPoint = newAnchor

        viewModel?.nodes[index].anchorPoint = newAnchor
        viewModel?.nodes[index].position = node.position
    }
}

extension CanvaSpriteScene {
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 15:
            isRotating = true
        case 7:
            removeSelectedNode()
        case 33:
            moveSelectedNode(zDelta: -1)
        case 30:
            moveSelectedNode(zDelta: 1)
        default:
            super.keyDown(with: event)
        }
    }

    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 15:
            isRotating = false
            rotationIndicator?.removeFromParent()
            rotationIndicator = nil
            if let node = selectedNode,
               let nodeID = node.nodeID,
               let index = viewModel?.nodes.firstIndex(where: { $0.id == nodeID }) {
                viewModel?.nodes[index].rotation = node.zRotation
            }
        default:
            super.keyUp(with: event)
        }
    }

    private func moveSelectedNode(zDelta: Int) {
        guard let selectedNode = selectedNode,
              let viewModel = viewModel,
              let nodeID = selectedNode.nodeID else { return }
        var sortedNodes = viewModel.nodes.sorted { $0.zPosition < $1.zPosition }
        guard let currentIndex = sortedNodes.firstIndex(where: { $0.id == nodeID }) else { return }
        let newIndex = currentIndex + zDelta
        guard newIndex >= 0, newIndex < sortedNodes.count else { return }
        sortedNodes.swapAt(currentIndex, newIndex)
        for (index, node) in sortedNodes.enumerated() {
            if let originalIndex = viewModel.nodes.firstIndex(where: { $0.id == node.id }) {
                viewModel.nodes[originalIndex].zPosition = CGFloat(index)
            }
        }
    }
}

extension CanvaSpriteScene {
    private func handleNodeSelection(at location: CGPoint) {
        let tappedNode = atPoint(location)

        switch tappedNode.name {
        case "anchorIndicator":
            isDraggingAnchorIndicator = true

        case "outline":
            return

        case let name? where name.contains("-EDT-"):
            guard let spriteNode = tappedNode as? SKSpriteNode else { return }
            guard selectedNode != spriteNode else { return }

            deselectCurrentNode()
            selectedNode = spriteNode
            spriteNode.addOutline()
            updateAnchorPointIndicator(for: spriteNode)
            viewModel?.selectedNodeID = spriteNode.nodeID

        default:
            deselectCurrentNode()
            removeAnchorPointIndicator()
        }
    }

    func updateHighlight(for selectedID: UUID?) {
        if let currentNode = selectedNode {
            currentNode.addOutline()
        }
        guard let selectedID = selectedID else {
            selectedNode = nil
            return
        }
        if let spriteNode = children.first(where: { $0.nodeID == selectedID }) as? SKSpriteNode {
            selectedNode?.removeOutline()
            spriteNode.addOutline()
            updateAnchorPointIndicator(for: spriteNode)
            selectedNode = spriteNode
        }
    }

    private func handleAnchorIndicatorDrag(with event: NSEvent) {
        if let node = selectedNode, let anchorIndicator = anchorPointIndicator {
            let locationInNode = node.convert(event.location(in: self), from: self)
            anchorIndicator.position = locationInNode
        }
    }

    private func updateAnchorPointIndicator(for node: SKSpriteNode) {
        anchorPointIndicator?.removeFromParent()
        
        let indicator = SKShapeNode(circleOfRadius: 10)
        indicator.fillColor = .brown
        indicator.strokeColor = .blue
        indicator.position = .zero
        indicator.zPosition = 20
        indicator.name = "anchorIndicator"
        
        node.addChild(indicator)
        anchorPointIndicator = indicator
    }

    private func removeSelectedNode() {
        guard let selectedNode = selectedNode,
              let nodeID = selectedNode.nodeID else { return }
        removeNode(nodeID: nodeID)
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

    private func deselectCurrentNode() {
        selectedNode?.removeOutline()
        selectedNode = nil
        viewModel?.selectedNodeID = nil
        removeAnchorPointIndicator()
        rotationIndicator?.removeFromParent()
        rotationIndicator = nil
        isRotating = false
    }
}

extension CanvaSpriteScene {
    func updateNodes(with nodes: [ProcNode]) {
        removeAllChildren()
        addChild(cameraNode)
        for procNode in nodes {
            let texture = SKTexture(image: procNode.image.fullImage)
            let spriteNode = SKSpriteNode(texture: texture)
            spriteNode.position = procNode.position
            spriteNode.zPosition = procNode.zPosition
            spriteNode.zRotation = procNode.rotation
            spriteNode.xScale = procNode.scale.x
            spriteNode.yScale = procNode.scale.y
            spriteNode.alpha = procNode.opacity
            spriteNode.name = procNode.nodeName
            spriteNode.anchorPoint = procNode.anchorPoint
            spriteNode.userData = ["id": procNode.id.uuidString]
            addChild(spriteNode)
            if let selectedID = viewModel?.selectedNodeID, selectedID == procNode.id {
                spriteNode.addOutline()
                updateAnchorPointIndicator(for: spriteNode)
                selectedNode = spriteNode
            }
        }
    }
}
