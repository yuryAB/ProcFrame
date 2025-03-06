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
    var nodeSelectionController: NodeSelectionController!

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
        nodeSelectionController = NodeSelectionController(scene: self)
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

// MARK: - Aux methods
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

    override func keyDown(with event: NSEvent) {
        inputController.handleKeyDown(event: event)
    }

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

    func handleNodeSelection(at location: CGPoint) {
        nodeSelectionController.handleNodeSelection(at: location)
    }
}
