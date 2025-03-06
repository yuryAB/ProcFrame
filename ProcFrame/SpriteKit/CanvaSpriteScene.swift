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
    private(set) var viewModel: ProcFrameViewModel
    
    var rotationIndicator: SKShapeNode?
    var stateMachine: GKStateMachine!
    var anchorPointIndicator: SKSpriteNode?
    var isDraggingAnchorIndicator = false
    var lastMousePosition: CGPoint?
    var targetNode: SKSpriteNode?
    var cameraController: CameraController!
    var inputController: InputController!
    var nodeLifecycleController: NodeLifecycleController!
    
    init(size: CGSize, viewModel: ProcFrameViewModel) {
        self.viewModel = viewModel
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not sido implementado")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        cameraController = CameraController(cameraNode: cameraNode)
        cameraController.setupCamera(in: self)
        stateMachine = GKStateMachine(states: [
            SelectionState(scene: self, viewModel: viewModel),
            RotationState(scene: self, viewModel: viewModel),
            ParentState(scene: self, viewModel: viewModel),
            DepthState(scene: self, viewModel: viewModel)
        ])
        
        stateMachine.enter(SelectionState.self)
        inputController = InputController(scene: self)
        nodeLifecycleController = NodeLifecycleController(scene: self)
    }
}


// MARK: - Mouse delegates
extension CanvaSpriteScene {
    override func mouseDown(with event: NSEvent) {
        inputController.handleMouseDown(event: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        inputController.handleMouseDragged(event: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        inputController.handleMouseUp(event: event)
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
    func updateAnchorPoint(for node: SKSpriteNode, with indicator: SKSpriteNode, nodeID: UUID) {
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
    
    func handleAnchorIndicatorDrag(with event: NSEvent) {
        if let node = targetNode, let anchorIndicator = anchorPointIndicator {
            let locationInNode = node.convert(event.location(in: self), from: self)
            anchorIndicator.position = locationInNode
        }
    }
    
    func updateAnchorPointIndicator(for node: SKSpriteNode) {
        anchorPointIndicator?.removeFromParent()
        
        let systemImage = NSImage(systemSymbolName: "dot.scope", accessibilityDescription: nil)!
        let texture = SKTexture(image: systemImage)
        
        let indicator = SKSpriteNode(texture: texture)
        indicator.size = CGSize(width: 45, height: 45)
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
            if let targetChild = child as? SKSpriteNode, targetChild.name?.contains("-EDT-") == true {
                setHighlight(to: targetChild)
            }
        }
    }
}

// MARK: - Key actions
extension CanvaSpriteScene {
    override func keyDown(with event: NSEvent) {
        inputController.handleKeyDown(event: event)
    }
}

// MARK: - Scene Actions
extension CanvaSpriteScene {
    func handleSelectionState() {
        viewModel.editionType = .selection
        stateMachine.enter(SelectionState.self)
    }
    
    func handleRotationState() {
        viewModel.editionType = .rotation
        stateMachine.enter(RotationState.self)
    }
    
    func handleParentingState() {
        viewModel.editionType = .parent
        stateMachine.enter(ParentState.self)
    }
    
    func moveTargetNode(direction: DepthOrientation) {
        guard let selectedNode = targetNode, let nodeID = selectedNode.nodeID,
              let index = viewModel.nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        viewModel.editionType = .depth
        stateMachine.enter(DepthState.self)
        
        switch direction {
        case .forward:
            selectedNode.zPosition += 1
        case .backward:
            selectedNode.zPosition -= 1
        }
        
        viewModel.nodes[index].zPosition = selectedNode.zPosition
        viewModel.reorderNodesByZPosition()
    }
}

// MARK: - Selection handle
extension CanvaSpriteScene {
    func handleNodeSelection(at location: CGPoint) {
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
                nodeLifecycleController.updateParenting(forParent: targetNode!, child: spriteNode)
                
            default:
                break
            }
            
            return
        }
        deselectCurrentNode()
        removeAnchorPointIndicator()
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
