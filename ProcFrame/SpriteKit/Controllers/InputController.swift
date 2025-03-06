//
//  InputController.swift
//  ProcFrame
//
//  Created by yury antony on 06/03/25.
//


import SpriteKit

class InputController {
    private unowned let scene: CanvaSpriteScene
    
    init(scene: CanvaSpriteScene) {
        self.scene = scene
    }
    
    func handleMouseDown(event: NSEvent) {
        let location = event.location(in: scene)
        scene.lastMousePosition = location
        scene.handleNodeSelection(at: location)
    }
    
    func handleMouseDragged(event: NSEvent) {
        if scene.isDraggingAnchorIndicator {
            scene.handleAnchorIndicatorDrag(with: event)
            return
        }
        let currentPosition = event.location(in: scene)
        guard let selectedNode = scene.targetNode else {
            scene.lastMousePosition = currentPosition
            return
        }
        if let parent = selectedNode.parent {
            let previousLocation = scene.lastMousePosition ?? currentPosition
            let previousLocationInParent = parent.convert(previousLocation, from: scene)
            let currentLocationInParent = parent.convert(currentPosition, from: scene)
            let deltaX = currentLocationInParent.x - previousLocationInParent.x
            let deltaY = currentLocationInParent.y - previousLocationInParent.y
            selectedNode.position = CGPoint(x: selectedNode.position.x + deltaX,
                                            y: selectedNode.position.y + deltaY)
        } else {
            let previousLocation = scene.lastMousePosition ?? currentPosition
            let deltaX = currentPosition.x - previousLocation.x
            let deltaY = currentPosition.y - previousLocation.y
            selectedNode.position = CGPoint(x: selectedNode.position.x + deltaX,
                                            y: selectedNode.position.y + deltaY)
        }
        scene.lastMousePosition = currentPosition
    }
    
    func handleMouseUp(event: NSEvent) {
        if scene.isDraggingAnchorIndicator,
           let node = scene.targetNode,
           let indicator = scene.anchorPointIndicator,
           let nodeID = node.nodeID {
            scene.updateAnchorPoint(for: node, with: indicator, nodeID: nodeID)
            scene.isDraggingAnchorIndicator = false
            scene.updateAnchorPointIndicator(for: node)
            return
        }
        guard let selectedNode = scene.targetNode,
              let nodeID = selectedNode.nodeID,
              let index = scene.viewModel.nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        scene.viewModel.nodes[index].position = selectedNode.position
        scene.viewModel.nodes[index].anchorPoint = selectedNode.anchorPoint
    }
    
    func handleKeyDown(event: NSEvent) {
        guard let action = CanvasKeyAction(rawValue: event.keyCode) else {
            return
        }
        switch action {
        case .enterSelectionState:
            scene.handleSelectionState()
        case .enterRotationState:
            scene.handleRotationState()
        case .enterParentState:
            scene.handleParentingState()
        case .deleteNode:
            scene.nodeController.removeSelectedNode()
        case .moveBack:
            scene.moveTargetNode(direction: .backward)
        case .moveFront:
            scene.moveTargetNode(direction: .forward)
        }
    }
}
