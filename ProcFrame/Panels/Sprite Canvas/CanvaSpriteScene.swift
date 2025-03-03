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
    private var targetNode: SKSpriteNode?
    private var anchorPointIndicator: SKShapeNode?
    private var rotationIndicator: SKShapeNode?
    private var isDraggingAnchorIndicator = false
    
    private(set) var viewModel: ProcFrameViewModel
    
    init(size: CGSize, viewModel: ProcFrameViewModel) {
        self.viewModel = viewModel
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implementado")
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
        
        if let view = self.view {
            let mouseLocation = view.convert(NSEvent.mouseLocation, from: nil)
            let locationBeforeZoom = convertPoint(fromView: mouseLocation)
            
            let newScale = max(min(cameraNode.xScale - (zoomDelta * zoomFactor), maxScale), minScale)
            cameraNode.setScale(newScale)
            
            let locationAfterZoom = convertPoint(fromView: mouseLocation)
            let delta = CGPoint(
                x: locationAfterZoom.x - locationBeforeZoom.x,
                y: locationAfterZoom.y - locationBeforeZoom.y
            )
            cameraNode.position.x -= delta.x
            cameraNode.position.y -= delta.y
        }
    }
    
    func rotateSelectedNode(by deltaRotation: CGFloat) {
        guard viewModel.editionType == .rotation, let node = targetNode, let nodeID = node.nodeID else { return }
        let degreesToRadians = { (degrees: CGFloat) -> CGFloat in
            return degrees * (.pi / 180)
        }
        let radiansToDegrees = { (radians: CGFloat) -> CGFloat in
            return radians * (180 / .pi)
        }
        let currentRotationDegrees = radiansToDegrees(node.zRotation)
        let newRotationDegrees = (currentRotationDegrees + deltaRotation).truncatingRemainder(dividingBy: 360)
        node.zRotation = degreesToRadians(newRotationDegrees)
        
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
}

extension CanvaSpriteScene {
    override func keyDown(with event: NSEvent) {
        guard let action = CanvasKeyAction(rawValue: event.keyCode) else {
            super.keyDown(with: event)
            return
        }
        
        switch action {
        case .selectionMode:
            handleSelectionMode()
        case .rotationMode:
            self.handleRotationMode()
        case .parentingMode:
            self.handleParentingMode()
        case .deleteNode:
            removeSelectedNode()
        case .moveBack:
            if let selectedNode = targetNode, let nodeID = selectedNode.nodeID {
                viewModel.moveNodeInList(nodeID: nodeID, direction: -1)
            }
        case .moveFront:
            if let selectedNode = targetNode, let nodeID = selectedNode.nodeID {
                viewModel.moveNodeInList(nodeID: nodeID, direction: +1)
            }
        }
    }
    
    func handleParentingMode() {
        viewModel.setEditionMode(to: .parenting)
        guard let targetNode = targetNode else { return }
        setHighlight(to: targetNode)
        for child in targetNode.children {
            if let targetChild = child as? SKSpriteNode {
                setHighlight(to: targetChild)
            }
        }
    }
    
    func handleRotationMode() {
        viewModel.setEditionMode(to: .rotation)
        setHighlight(to: targetNode)
        removeParentingHighlightsFromTarget()
    }
    
    func handleSelectionMode() {
        viewModel.setEditionMode(to: .selection)
        setHighlight(to: targetNode)
        removeParentingHighlightsFromTarget()
    }
    
    private func removeParentingHighlightsFromTarget() {
        guard let targetNode = targetNode else { return }
        for child in targetNode.children {
            if let spriteNode = child as? SKSpriteNode {
                spriteNode.removeOutline()
            }
        }
    }
    
    func setHighlight(to node:SKSpriteNode?) {
        switch viewModel.editionType {
        case .selection:
            node?.drawOutline(color: .magenta)
        case .rotation:
            node?.drawOutline(color: .orange)
        case .parenting:
            node?.drawOutline(color: .cyan)
        }
    }
}

extension CanvaSpriteScene {
    private func handleNodeSelection(at location: CGPoint) {
        let tappedNode = atPoint(location)
        
        if tappedNode.name == "anchorIndicator" {
            isDraggingAnchorIndicator = true
            return
        }

        if tappedNode.name == "outline" {
            return
        }

        guard let tappedSprite = tappedNode as? SKSpriteNode, tappedSprite.name?.contains("-EDT-") == true else {
            removeParentingHighlightsFromTarget()
            deselectCurrentNode()
            removeAnchorPointIndicator()
            return
        }

        if tappedSprite == targetNode { return }
        
        switch viewModel.editionType {
        case .selection:
            targetNode?.removeOutline()
            targetNode = tappedSprite
            updateAnchorPointIndicator(for: tappedSprite)
            viewModel.selectedNodeID = tappedSprite.nodeID
            setHighlight(to: targetNode)
            
        case .rotation:
            targetNode?.removeOutline()
            targetNode = tappedSprite
            updateAnchorPointIndicator(for: tappedSprite)
            viewModel.selectedNodeID = tappedSprite.nodeID
            setHighlight(to: targetNode)
            
        case .parenting:
            if targetNode == nil {
                targetNode = tappedSprite
                setHighlight(to: targetNode)

                targetNode?.children
                    .compactMap { $0 as? SKSpriteNode }
                    .forEach { setHighlight(to: $0) }

                return
            }
            
            guard let tappedNodeID = tappedSprite.nodeID,
                  let procNode = viewModel.nodes.first(where: { $0.id == tappedNodeID }) else {
                return
            }

            if procNode.parentID != nil {
                return
            }
            
            targetNode?.adoptChild(tappedSprite, from: self)
            setHighlight(to: tappedSprite)
            updateProcNodeParenting(forParent: targetNode!.nodeID!, child: tappedNodeID)
        }
    }
    
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
    
    private func removeSelectedNode() {
        guard let selectedNode = targetNode,
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
        targetNode?.removeOutline()
        targetNode = nil
        viewModel.selectedNodeID = nil
        removeAnchorPointIndicator()
        rotationIndicator?.removeFromParent()
        rotationIndicator = nil
    }
}

extension CanvaSpriteScene {
    private func updateProcNodeParenting(forParent parentID: UUID, child childID: UUID) {
        guard let parentIndex = viewModel.nodes.firstIndex(where: { $0.id == parentID }),
              let childIndex = viewModel.nodes.firstIndex(where: { $0.id == childID }) else {
            return
        }
        
        if viewModel.nodes[childIndex].parentID != nil { return }
        
        var parentNode = viewModel.nodes[parentIndex]
        var childNode = viewModel.nodes[childIndex]
        
        parentNode.addChild(childNode)
        childNode.parentID = parentNode.id
        
        viewModel.nodes[parentIndex] = parentNode
        viewModel.nodes[childIndex] = childNode
    }
    
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
                    targetNode = spriteNode
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
                    setHighlight(to: spriteNode)
                    updateAnchorPointIndicator(for: spriteNode)
                    targetNode = spriteNode
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
