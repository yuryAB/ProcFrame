//
//  CanvaSpriteScene.swift
//  ProcFrame
//
//  Created by yury antony on 04/02/25.
//

import Foundation
import SpriteKit
import SwiftUI
import GameplayKit

class CanvaSpriteScene: SKScene {
    private var cameraNode = SKCameraNode()
    private var lastMousePosition: CGPoint?
    private var anchorPointIndicator: SKShapeNode?
    private var rotationIndicator: SKShapeNode?
    private var isDraggingAnchorIndicator = false
    private var stateMachine: GKStateMachine!
    private(set) var viewModel: ProcFrameViewModel
    
    var targetNode: SKSpriteNode?
    
    init(size: CGSize, viewModel: ProcFrameViewModel) {
        self.viewModel = viewModel
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not sido implementado")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupCamera()
        stateMachine = GKStateMachine(states: [
            SelectionState(scene: self, viewModel: viewModel),
            RotationState(scene: self, viewModel: viewModel),
            ParentState(scene: self, viewModel: viewModel),
            DepthState(scene: self, viewModel: viewModel)
        ])
        
        stateMachine.enter(SelectionState.self)
    }
}

// MARK: - Camera
extension CanvaSpriteScene {
    func setupCamera() {
        if cameraNode.parent == nil {
            addChild(cameraNode)
            camera = cameraNode
            cameraNode.setScale(1.0)
        }
    }
    
    func moveCamera(by delta: CGPoint) {
        if viewModel.editionType == .rotation { return }
        let deltaX = delta.x * 2
        let deltaY = delta.y * 2
        cameraNode.position = CGPoint(x: cameraNode.position.x - deltaX,
                                      y: cameraNode.position.y + deltaY)
    }
    
    func zoomCamera(by zoomDelta: CGFloat) {
        if viewModel.editionType == .rotation { return }
        
        let minScale: CGFloat = 0.5
        let maxScale: CGFloat = 6.0
        let zoomFactor: CGFloat = 1.5
        
        let newScale = max(min(cameraNode.xScale - (zoomDelta * zoomFactor), maxScale), minScale)
        cameraNode.setScale(newScale)
    }
}

// MARK: - Mouse delegates
extension CanvaSpriteScene {
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
        if let selectedNode = targetNode {
            let deltaX = currentPosition.x - (lastMousePosition?.x ?? currentPosition.x)
            let deltaY = currentPosition.y - (lastMousePosition?.y ?? currentPosition.y)
            selectedNode.position.x += deltaX
            selectedNode.position.y += deltaY
        }
        lastMousePosition = currentPosition
    }
    
    override func mouseUp(with event: NSEvent) {
        if isDraggingAnchorIndicator, let node = targetNode, let indicator = anchorPointIndicator, let nodeID = node.nodeID {
            updateAnchorPoint(for: node, with: indicator, nodeID: nodeID)
            isDraggingAnchorIndicator = false
            updateAnchorPointIndicator(for: node)
            return
        }
        guard let selectedNode = targetNode, let nodeID = selectedNode.nodeID,
              let index = viewModel.nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        viewModel.nodes[index].position = selectedNode.position
        viewModel.nodes[index].anchorPoint = selectedNode.anchorPoint
    }
}

// MARK: - Rotation mode
extension CanvaSpriteScene {
    func rotateSelectedNode(by deltaRotation: CGFloat) {
        guard viewModel.editionType == .rotation,
              let node = targetNode,
              let nodeID = node.nodeID,
              let index = viewModel.nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        
        let deltaRadians = deltaRotation * (.pi / 180)
        node.zRotation = (node.zRotation + deltaRadians).truncatingRemainder(dividingBy: .pi * 2)
        viewModel.nodes[index].rotation = node.zRotation
    }
}

// MARK: - Anchor point
extension CanvaSpriteScene {
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
        
        setHighlight(to: node)
    }
    
    private func handleAnchorIndicatorDrag(with event: NSEvent) {
        if let node = targetNode, let anchorIndicator = anchorPointIndicator {
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
    
    private func removeAnchorPointIndicator() {
        anchorPointIndicator?.removeFromParent()
        anchorPointIndicator = nil
    }
}

// MARK: - Highlights
extension CanvaSpriteScene {
    func updateHighlight(for selectedID: UUID?) {
        setHighlight(to: targetNode)
        guard let selectedID = selectedID else {
            targetNode = nil
            return
        }
        if let spriteNode = children.first(where: { $0.nodeID == selectedID }) as? SKSpriteNode {
            targetNode?.removeOutline()
            setHighlight(to: spriteNode)
            updateAnchorPointIndicator(for: spriteNode)
            targetNode = spriteNode
        }
    }
    
    func removeParentingHighlightsFromTarget() {
        guard let targetNode = targetNode else { return }
        for child in targetNode.children {
            if let spriteNode = child as? SKSpriteNode {
                spriteNode.removeOutline()
            }
        }
    }
    
    func setHighlight(to node: SKSpriteNode?) {
        switch viewModel.editionType {
        case .selection:
            node?.drawOutline(color: .magenta)
        case .rotation:
            node?.drawOutline(color: .orange)
        case .parent:
            node?.drawOutline(color: .cyan)
        case .depth:
            node?.drawOutline(color: .purple)
        }
    }
    
    func setHighlightToTarget() {
        guard let targetNode = targetNode else { return }
        setHighlight(to: targetNode)
    }
    
    func setHighlightToTargetAndChildren() {
        guard let targetNode = targetNode else { return }
        setHighlight(to: targetNode)
        for child in targetNode.children {
            if let targetChild = child as? SKSpriteNode {
                setHighlight(to: targetChild)
            }
        }
    }
}

// MARK: - Key actions
extension CanvaSpriteScene {
    override func keyDown(with event: NSEvent) {
        guard let action = CanvasKeyAction(rawValue: event.keyCode) else {
            super.keyDown(with: event)
            return
        }
        
        switch action {
        case .enterSelectionState:
            handleSelectionState()
        case .enterRotationState:
            self.handleRotationState()
        case .enterParentState:
            self.handleParentingState()
        case .deleteNode:
            removeSelectedNode()
        case .moveBack:
            moveTargetNode(direction: .backward)
        case .moveFront:
            moveTargetNode(direction: .forward)
        }
    }
    
    private func moveTargetNode(direction: DepthOrientation) {
        guard let selectedNode = targetNode, let nodeID = selectedNode.nodeID,
        let index = viewModel.nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        viewModel.editionType = .depth
        stateMachine.enter(DepthState.self)
        
        switch direction {
        case .forward:
            selectedNode.zPosition +=  1
        case .backward:
            selectedNode.zPosition -=  1
        }
        
        viewModel.nodes[index].zPosition = selectedNode.zPosition
        viewModel.reorderNodesByZPosition()
    }
    
    private func handleSelectionState() {
        viewModel.editionType = .selection
        stateMachine.enter(SelectionState.self)
    }
    
    private func handleRotationState() {
        viewModel.editionType = .rotation
        stateMachine.enter(RotationState.self)
    }
    
    private func handleParentingState() {
        viewModel.editionType = .parent
        stateMachine.enter(ParentState.self)
    }
}

// MARK: - Selection handle
extension CanvaSpriteScene {
    private func handleNodeSelection(at location: CGPoint) {
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            if node.name == "anchorIndicator" {
                isDraggingAnchorIndicator = true
                return
            }

            guard let spriteNode = node as? SKSpriteNode,
                  spriteNode.name?.contains("-EDT-") == true,
                  spriteNode.isPointVisible(location) else { 
                continue
            }

            if spriteNode == targetNode { return }

            if stateMachine.currentState is DepthState {
                viewModel.editionType = .selection
                stateMachine.enter(SelectionState.self)
            }

            switch stateMachine.currentState {
            case is SelectionState, is RotationState:
                targetNode?.removeOutline()
                targetNode = spriteNode
                updateAnchorPointIndicator(for: spriteNode)
                viewModel.selectedNodeID = spriteNode.nodeID
                setHighlight(to: targetNode)

            case is ParentState:
                if targetNode == nil {
                    targetNode = spriteNode
                    setHighlightToTargetAndChildren()
                    return
                }

                guard let tappedNodeID = spriteNode.nodeID,
                      let procNode = viewModel.nodes.first(where: { $0.id == tappedNodeID }) else {
                    return
                }

                if procNode.parentID != nil { return }

                spriteNode.zPosition = 1
                targetNode?.adoptChild(spriteNode, from: self)
                setHighlight(to: spriteNode)
                updateProcNodeParenting(forParent: targetNode!, child: spriteNode)

            default:
                break
            }

            return
        }
        deselectCurrentNode()
        removeAnchorPointIndicator()
    }
}

// MARK: - Delete/Remove methods
extension CanvaSpriteScene {
    private func removeSelectedNode() {
        guard let nodeID = targetNode?.nodeID else { return }
        removeNode(nodeID: nodeID)
    }
    
    func removeNode(nodeID: UUID) {
        guard let nodeToRemove = children.first(where: { $0.nodeID == nodeID }) else { return }
        nodeToRemove.removeFromParent()
        viewModel.nodes.removeAll { $0.id == nodeID }
    }
    
    private func deselectCurrentNode() {
        targetNode?.removeOutline()
        targetNode = nil
        viewModel.selectedNodeID = nil
        removeAnchorPointIndicator()
        rotationIndicator?.removeFromParent()
        rotationIndicator = nil
    }
}

// MARK: - Update methods
extension CanvaSpriteScene {
    private func updateProcNodeParenting(forParent targetNode: SKSpriteNode, child newChild: SKSpriteNode) {
        guard let parentID = targetNode.nodeID,
              let childID = newChild.nodeID,
              let parentIndex = viewModel.nodes.firstIndex(where: { $0.id == parentID }),
              let childIndex = viewModel.nodes.firstIndex(where: { $0.id == childID }),
              viewModel.nodes[childIndex].parentID == nil else {
            return
        }
        
        viewModel.nodes[parentIndex].addChild(viewModel.nodes[childIndex].id)
        viewModel.updateProcNode(from: newChild)
        viewModel.reorderNodesByZPosition()
    }
    
    func updateNodes() {
        var existingNodes: [UUID: SKSpriteNode] = children.compactMap { $0 as? SKSpriteNode }
            .reduce(into: [UUID: SKSpriteNode]()) { dict, node in
                if let nodeID = node.nodeID {
                    dict[nodeID] = node
                }
            }
        
        var newTargetNode: SKSpriteNode?

        for procNode in viewModel.nodes {
            let spriteNode = existingNodes[procNode.id] ?? createSpriteNode(for: procNode)
            
            updateSpriteNode(spriteNode, with: procNode)
            
            if existingNodes[procNode.id] == nil {
                addChild(spriteNode)
                existingNodes[procNode.id] = spriteNode
            }

            if viewModel.selectedNodeID == procNode.id {
                newTargetNode = spriteNode
            }
        }

        if let selectedNode = newTargetNode {
            setHighlight(to: selectedNode)
            updateAnchorPointIndicator(for: selectedNode)
            targetNode = selectedNode
        }
    }

    private func createSpriteNode(for procNode: ProcNode) -> SKSpriteNode {
        let texture = SKTexture(image: procNode.image.fullImage)
        let spriteNode = SKSpriteNode(texture: texture)
        
        spriteNode.name = procNode.nodeName
        spriteNode.userData = ["id": procNode.id.uuidString]
        
        return spriteNode
    }

    private func updateSpriteNode(_ spriteNode: SKSpriteNode, with procNode: ProcNode) {
        spriteNode.position = procNode.position
        spriteNode.zRotation = procNode.rotation
        spriteNode.xScale = procNode.scale.x
        spriteNode.yScale = procNode.scale.y
        spriteNode.zPosition = procNode.zPosition
        spriteNode.alpha = procNode.opacity
        spriteNode.anchorPoint = procNode.anchorPoint
    }
}
