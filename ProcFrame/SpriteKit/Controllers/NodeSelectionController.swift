//
//  NodeSelectionController.swift
//  ProcFrame
//
//  Created by yury antony on 06/03/25.
//

import SpriteKit
import GameplayKit

class NodeSelectionController {
    private unowned let scene: CanvaSpriteScene
    
    init(scene: CanvaSpriteScene) {
        self.scene = scene
    }
    
    func handleNodeSelection(at location: CGPoint) {
        let nodesAtPoint = scene.nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "anchorIndicator" {
                scene.isDraggingAnchorIndicator = true
                return
            }
            
            guard let spriteNode = node as? SKSpriteNode,
                  spriteNode.name?.contains("-EDT-") == true,
                  spriteNode.isPointVisible(location) else {
                continue
            }
            
            if spriteNode == scene.targetNode { return }
            
            if scene.stateMachine.currentState is DepthState {
                scene.viewModel.editionType = .selection
                scene.stateMachine.enter(SelectionState.self)
            }
            
            switch scene.stateMachine.currentState {
            case is SelectionState, is RotationState:
                scene.targetNode?.removeOutline()
                scene.targetNode = spriteNode
                updateAnchorPointIndicator(for: spriteNode)
                scene.viewModel.selectedNodeID = spriteNode.nodeID
                setHighlight(to: scene.targetNode)
            case is ParentState:
                if scene.targetNode == nil {
                    scene.targetNode = spriteNode
                    setHighlightToTargetAndChildren()
                    return
                }
                guard let tappedNodeID = spriteNode.nodeID,
                      let procNode = scene.viewModel.nodes.first(where: { $0.id == tappedNodeID }) else {
                    return
                }
                if procNode.parentID != nil { return }
                
                spriteNode.zPosition = 1
                scene.targetNode?.adoptChild(spriteNode, from: scene)
                setHighlight(to: spriteNode)
                scene.nodeLifecycleController.updateParenting(forParent: scene.targetNode!, child: spriteNode)
            default:
                break
            }
            
            return
        }
        
        deselectCurrentNode()
        removeAnchorPointIndicator()
    }
    
    private func deselectCurrentNode() {
        scene.targetNode?.removeOutline()
        scene.targetNode = nil
        scene.viewModel.selectedNodeID = nil
        removeAnchorPointIndicator()
        scene.rotationIndicator?.removeFromParent()
        scene.rotationIndicator = nil
    }
    
    // MARK: - Anchor Point Indicator Methods
    
    func updateAnchorPointIndicator(for node: SKSpriteNode) {
        removeAnchorPointIndicator()
        
        let systemImage = NSImage(systemSymbolName: "dot.scope", accessibilityDescription: nil)!
        let texture = SKTexture(image: systemImage)
        
        let indicator = SKSpriteNode(texture: texture)
        indicator.size = CGSize(width: 45, height: 45)
        indicator.zPosition = 20
        indicator.name = "anchorIndicator"
        
        node.addChild(indicator)
        scene.anchorPointIndicator = indicator
    }
    
    func handleAnchorIndicatorDrag(with event: NSEvent) {
        if let node = scene.targetNode, let anchorIndicator = scene.anchorPointIndicator {
            let locationInNode = node.convert(event.location(in: scene), from: scene)
            anchorIndicator.position = locationInNode
        }
    }
    
    func removeAnchorPointIndicator() {
        scene.anchorPointIndicator?.removeFromParent()
        scene.anchorPointIndicator = nil
    }
    
    // MARK: - Highlight Methods
    
    func setHighlight(to node: SKSpriteNode?) {
        switch scene.viewModel.editionType {
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
        guard let targetNode = scene.targetNode else { return }
        setHighlight(to: targetNode)
    }
    
    func setHighlightToTargetAndChildren() {
        guard let targetNode = scene.targetNode else { return }
        setHighlight(to: targetNode)
        for child in targetNode.children {
            if let targetChild = child as? SKSpriteNode, targetChild.name?.contains("-EDT-") == true {
                setHighlight(to: targetChild)
            }
        }
    }
    
    func updateHighlight(for selectedID: UUID?) {
        setHighlight(to: scene.targetNode)
        guard let selectedID = selectedID else {
            scene.targetNode = nil
            return
        }
        if let spriteNode = scene.children.first(where: { $0.nodeID == selectedID }) as? SKSpriteNode {
            scene.targetNode?.removeOutline()
            setHighlight(to: spriteNode)
            updateAnchorPointIndicator(for: spriteNode)
            scene.targetNode = spriteNode
        }
    }
    
    func removeParentingHighlightsFromTarget() {
        guard let targetNode = scene.targetNode else { return }
        for child in targetNode.children {
            if let spriteNode = child as? SKSpriteNode {
                spriteNode.removeOutline()
            }
        }
    }
    
    func updateAnchorPoint(for node: SKSpriteNode, with indicator: SKSpriteNode, nodeID: UUID) {
        guard let index = scene.viewModel.nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        
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
        
        scene.viewModel.nodes[index].anchorPoint = newAnchor
        scene.viewModel.nodes[index].position = node.position
        
        setHighlight(to: node)
    }
}
