//
//  NodeController.swift
//  ProcFrame
//
//  Created by yury antony on 06/03/25.
//

import SpriteKit

class NodeLifecycleController {
    private unowned var scene: CanvaSpriteScene
    private var viewModel: ProcFrameViewModel {
        return scene.viewModel
    }
    
    init(scene: CanvaSpriteScene) {
        self.scene = scene
    }
    
    func updateNodes() {
        var existingNodes: [UUID: SKSpriteNode] = [:]
        for case let sprite as SKSpriteNode in scene.children {
            if let id = sprite.nodeID {
                existingNodes[id] = sprite
            }
        }
        
        var newTargetNode: SKSpriteNode?
        
        for procNode in viewModel.nodes {
            let spriteNode: SKSpriteNode
            if let existing = existingNodes[procNode.id] {
                spriteNode = existing
            } else {
                spriteNode = createSpriteNode(for: procNode)
                scene.addChild(spriteNode)
                existingNodes[procNode.id] = spriteNode
            }
            
            updateSpriteNode(spriteNode, with: procNode)
            
            if viewModel.selectedNodeID == procNode.id {
                newTargetNode = spriteNode
            }
        }
        
        if let selectedNode = newTargetNode {
            scene.setHighlight(to: selectedNode)
            scene.updateAnchorPointIndicator(for: selectedNode)
            scene.targetNode = selectedNode
        }
    }
    
    func createSpriteNode(for procNode: ProcNode) -> SKSpriteNode {
        let texture = SKTexture(image: procNode.image.fullImage)
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.name = procNode.nodeName
        spriteNode.userData = ["id": procNode.id.uuidString]
        return spriteNode
    }
    
    func updateSpriteNode(_ spriteNode: SKSpriteNode, with procNode: ProcNode) {
        spriteNode.position = procNode.position
        spriteNode.zRotation = procNode.rotation
        spriteNode.xScale = procNode.scale.x
        spriteNode.yScale = procNode.scale.y
        spriteNode.zPosition = procNode.zPosition
        spriteNode.alpha = procNode.opacity
        spriteNode.anchorPoint = procNode.anchorPoint
    }

    func updateParenting(forParent parent: SKSpriteNode, child newChild: SKSpriteNode) {
        guard let parentID = parent.nodeID,
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
    
    func removeNode(nodeID: UUID) {
        guard let nodeToRemove = scene.children.first(where: { $0.nodeID == nodeID }) as? SKSpriteNode else { return }
        nodeToRemove.removeFromParent()
        viewModel.nodes.removeAll { $0.id == nodeID }
    }
    
    func removeSelectedNode() {
        guard let nodeID = scene.targetNode?.nodeID else { return }
        removeNode(nodeID: nodeID)
    }
}
