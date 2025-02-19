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
    private var anchorPointIndicator: SKShapeNode?
    private var rotationIndicator: SKShapeNode?
    private var isDraggingAnchorIndicator = false

    private(set) var viewModel: ProcFrameViewModel

    init(size: CGSize, viewModel: ProcFrameViewModel) {
        self.viewModel = viewModel
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        if viewModel.isRotating { return }
        let deltaX = delta.x * 1.5
        let deltaY = delta.y * 1.5
        cameraNode.position = CGPoint(x: cameraNode.position.x - deltaX,
                                      y: cameraNode.position.y + deltaY)
    }

    func zoomCamera(by zoomDelta: CGFloat) {
        if viewModel.isRotating { return }
        let newScale = max(min(cameraNode.xScale - (zoomDelta * 1.5), 5.0), 0.5)
        cameraNode.setScale(newScale)
    }

    func rotateSelectedNode(by deltaRotation: CGFloat) {
        guard viewModel.isRotating, let node = selectedNode, let nodeID = node.nodeID else { return }

        node.zRotation += deltaRotation / 50

        if let index = viewModel.nodes.firstIndex(where: { $0.id == nodeID }) {
            viewModel.nodes[index].rotation = node.zRotation
        }
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
            updateAnchorPointIndicator(for: node)
            return
        }
        guard let selectedNode = selectedNode, let nodeID = selectedNode.nodeID,
              let index = viewModel.nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        viewModel.nodes[index].position = selectedNode.position
        viewModel.nodes[index].anchorPoint = selectedNode.anchorPoint
    }

    private func updateAnchorPoint(for node: SKSpriteNode, with indicator: SKShapeNode, nodeID: UUID) {
        guard let index = viewModel.nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        
        let oldAnchor = node.anchorPoint
        let dragOffset = indicator.position
        
        let newAnchor = CGPoint(
            x: min(max(oldAnchor.x + dragOffset.x / node.size.width, 0), 1),
            y: min(max(oldAnchor.y + dragOffset.y / node.size.height, 0), 1)
        )
    
        let localCompensation = CGPoint(
            x: -(oldAnchor.x - newAnchor.x) * node.size.width * node.xScale,
            y: -(oldAnchor.y - newAnchor.y) * node.size.height * node.yScale
        )
        
        let rotation = node.zRotation
        let globalCompensation = CGPoint(
            x: localCompensation.x * cos(rotation) - localCompensation.y * sin(rotation),
            y: localCompensation.x * sin(rotation) + localCompensation.y * cos(rotation)
        )
        
        node.position.x += globalCompensation.x
        node.position.y += globalCompensation.y
        node.anchorPoint = newAnchor
        
        viewModel.nodes[index].anchorPoint = newAnchor
        viewModel.nodes[index].position = node.position
        
        node.refreshOutline()
    }
}

extension CanvaSpriteScene {
    override func keyDown(with event: NSEvent) {
        guard let action = CanvasKeyAction(rawValue: event.keyCode) else {
            super.keyDown(with: event)
            return
        }
        switch action {
        case .toggleRotation:
            viewModel.isRotating = true
        case .deleteNode:
            removeSelectedNode()
        case .moveZDown:
            if let selectedNode = selectedNode, let nodeID = selectedNode.nodeID {
                viewModel.moveNodeInList(nodeID: nodeID, direction: -1)
            }
        case .moveZUp:
            if let selectedNode = selectedNode, let nodeID = selectedNode.nodeID {
                viewModel.moveNodeInList(nodeID: nodeID, direction: +1)
            }
        case .merge:
            if selectedNode != nil {
                viewModel.isMerging = true
            }
        }
    }

    override func keyUp(with event: NSEvent) {
        guard let action = CanvasKeyAction(rawValue: event.keyCode) else {
            super.keyUp(with: event)
            return
        }
        switch action {
        case .toggleRotation:
            viewModel.isRotating = false
        case .merge:
            viewModel.isMerging = false
        default:
            break
        }
    }
}

extension CanvaSpriteScene {
    private func handleNodeSelection(at location: CGPoint) {
        let tappedNode = atPoint(location)
        if viewModel.isMerging, let currentParent = selectedNode, tappedNode != currentParent {
            if let spriteNode = tappedNode as? SKSpriteNode, spriteNode != currentParent {
                currentParent.adoptChild(spriteNode, from: self)
            }
            return
        }

        if tappedNode.name == "anchorIndicator" {
            isDraggingAnchorIndicator = true
            return
        }

        if tappedNode.name == "outline" {
            return
        }

        guard let tappedSprite = tappedNode as? SKSpriteNode, tappedSprite.name?.contains("-EDT-") == true else {
            deselectCurrentNode()
            removeAnchorPointIndicator()
            return
        }

        if tappedSprite == selectedNode {
            return
        }

        deselectCurrentNode()
        selectedNode = tappedSprite
        tappedSprite.addOutline()
        updateAnchorPointIndicator(for: tappedSprite)
        viewModel.selectedNodeID = tappedSprite.nodeID
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
            viewModel.nodes.removeAll { $0.id == nodeID }
        }
    }

    private func removeAnchorPointIndicator() {
        anchorPointIndicator?.removeFromParent()
        anchorPointIndicator = nil
    }

    private func deselectCurrentNode() {
        selectedNode?.removeOutline()
        selectedNode = nil
        viewModel.selectedNodeID = nil
        removeAnchorPointIndicator()
        rotationIndicator?.removeFromParent()
        rotationIndicator = nil
        viewModel.isRotating = false
    }
}

extension CanvaSpriteScene {
    func updateNodes(with nodes: [ProcNode]) {
        for procNode in nodes {
            if let spriteNode = self.findNode(withID: procNode.id) {
                spriteNode.position = procNode.position
                spriteNode.zRotation = procNode.rotation
                spriteNode.xScale = procNode.scale.x
                spriteNode.yScale = procNode.scale.y
                spriteNode.alpha = procNode.opacity
                spriteNode.anchorPoint = procNode.anchorPoint

                if viewModel.selectedNodeID == procNode.id {
                    updateAnchorPointIndicator(for: spriteNode)
                    selectedNode = spriteNode
                }
            } else {
                let texture = SKTexture(image: procNode.image.fullImage)
                let spriteNode = SKSpriteNode(texture: texture)

                spriteNode.position = procNode.position
                spriteNode.zRotation = procNode.rotation
                spriteNode.xScale = procNode.scale.x
                spriteNode.yScale = procNode.scale.y
                spriteNode.alpha = procNode.opacity
                spriteNode.anchorPoint = procNode.anchorPoint
                spriteNode.name = procNode.nodeName
                spriteNode.userData = ["id": procNode.id.uuidString]

                addChild(spriteNode)

                if viewModel.selectedNodeID == procNode.id {
                    spriteNode.addOutline()
                    updateAnchorPointIndicator(for: spriteNode)
                    selectedNode = spriteNode
                }
            }
        }

        syncZPositions()
    }
    
    func syncZPositions() {
        for (index, procNode) in viewModel.nodes.enumerated() {
            if let spriteNode = children.first(where: { $0.nodeID == procNode.id }) as? SKSpriteNode {
                spriteNode.zPosition = CGFloat(index)
                viewModel.nodes[index].zPosition = CGFloat(index)
            }
        }
    }
}
