//
//  NodeController.swift
//  ProcFrame
//
//  Created by yury antony on 06/03/25.
//

import SpriteKit

class NodeLifecycleController {
    private unowned var scene: CanvaSpriteScene
    private var nodeStore: NodeStore {
        return scene.nodeStore
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
        
        for procNode in nodeStore.nodes {
            let spriteNode: SKSpriteNode
            if let existing = existingNodes[procNode.id] {
                spriteNode = existing
            } else {
                spriteNode = createSpriteNode(for: procNode)
                scene.addChild(spriteNode)
                existingNodes[procNode.id] = spriteNode
            }
            
            updateSpriteNode(spriteNode, with: procNode)
            
            if nodeStore.selectedNodeID == procNode.id {
                newTargetNode = spriteNode
            }
        }
        
        if let selectedNode = newTargetNode {
            scene.nodeSelectionController.setHighlight(to: selectedNode)
            scene.nodeSelectionController.updateAnchorPointIndicator(for: selectedNode)
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
              let parentIndex = nodeStore.nodes.firstIndex(where: { $0.id == parentID }),
              let childIndex = nodeStore.nodes.firstIndex(where: { $0.id == childID }),
              nodeStore.nodes[childIndex].parentID == nil else {
            return
        }
        
        nodeStore.nodes[parentIndex].addChild(nodeStore.nodes[childIndex].id)
        updateProcNode(from: newChild)
        nodeStore.reorderNodesByZPosition()
    }
    
    func removeNode(nodeID: UUID) {
        guard let nodeToRemove = scene.children.first(where: { $0.nodeID == nodeID }) as? SKSpriteNode else { return }
        nodeToRemove.removeFromParent()
        nodeStore.nodes.removeAll { $0.id == nodeID }
    }
    
    func removeSelectedNode() {
        guard let nodeID = scene.targetNode?.nodeID else { return }
        removeNode(nodeID: nodeID)
    }

    private func updateProcNode(from spriteNode: SKSpriteNode) {
        guard let nodeID = spriteNode.nodeID,
              let index = nodeStore.nodes.firstIndex(where: { $0.id == nodeID }) else { return }

        nodeStore.nodes[index].position = spriteNode.position
        nodeStore.nodes[index].zPosition = spriteNode.zPosition
        nodeStore.nodes[index].rotation = spriteNode.zRotation
        nodeStore.nodes[index].scale = ProcScale(x: spriteNode.xScale, y: spriteNode.yScale)
        nodeStore.nodes[index].opacity = spriteNode.alpha
        nodeStore.nodes[index].anchorPoint = spriteNode.anchorPoint

        if let parentSpriteNode = spriteNode.parent as? SKSpriteNode,
           let parentID = parentSpriteNode.nodeID {
            nodeStore.nodes[index].parentID = parentID
        } else {
            nodeStore.nodes[index].parentID = nil
        }
    }
}
