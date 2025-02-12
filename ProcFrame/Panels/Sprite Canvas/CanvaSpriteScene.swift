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

    private lazy var borderShader: SKShader = {
        let source = """
        void main() {
            vec2 uv = v_tex_coord;
            float bw = u_borderWidth;
            vec4 texColor = texture2D(u_texture, uv);
            // Se estivermos na região da borda, usa a cor magenta
            if (uv.x < bw || uv.x > 1.0 - bw || uv.y < bw || uv.y > 1.0 - bw) {
                gl_FragColor = vec4(u_borderColor.rgb, 1.0);
            } else {
                gl_FragColor = texColor;
            }
        }
        """
        let shader = SKShader(source: source, uniforms: [
            SKUniform(name: "u_borderWidth", float: 0.05),
            SKUniform(name: "u_borderColor", vectorFloat4: vector_float4(1.0, 0.0, 1.0, 1.0))
        ])
        return shader
    }()

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
        guard let camera = camera else { return }
        let deltaX = delta.x * 1.5
        let deltaY = delta.y * 1.5
        camera.position = CGPoint(x: camera.position.x - deltaX, y: camera.position.y + deltaY)
    }

    func zoomCamera(by zoomDelta: CGFloat) {
        if isRotating { return }
        guard let camera = camera else { return }
        let newScale = max(min(camera.xScale - (zoomDelta * 1.5), 5.0), 0.5)
        camera.setScale(newScale)
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
            let delta = CGPoint(x: currentPosition.x - (lastMousePosition?.x ?? currentPosition.x),
                                y: currentPosition.y - (lastMousePosition?.y ?? currentPosition.y))
            selectedNode.position.x += delta.x
            selectedNode.position.y += delta.y
        }
        lastMousePosition = currentPosition
    }

    override func mouseUp(with event: NSEvent) {
        if isDraggingAnchorIndicator,
           let node = selectedNode,
           let indicator = anchorPointIndicator,
           let nodeID = node.nodeID,
           let index = viewModel?.nodes.firstIndex(where: { $0.id == nodeID }) {
            
            let oldAnchor = node.anchorPoint
            let dragOffset = indicator.position
            
            let anchorChange = CGPoint(
                x: dragOffset.x / node.size.width,
                y: dragOffset.y / node.size.height
            )
            
            var newAnchor = CGPoint(
                x: oldAnchor.x + anchorChange.x,
                y: oldAnchor.y + anchorChange.y
            )
            
            newAnchor.x = min(max(newAnchor.x, 0), 1)
            newAnchor.y = min(max(newAnchor.y, 0), 1)
            
            let compensation = CGPoint(
                x: (oldAnchor.x - newAnchor.x) * node.size.width * node.xScale,
                y: (oldAnchor.y - newAnchor.y) * node.size.height * node.yScale
            )
            
            node.position = CGPoint(
                x: node.position.x + compensation.x,
                y: node.position.y + compensation.y
            )
            
            node.anchorPoint = newAnchor
            LogManager.shared.addLog("new node anchor point: \(node.anchorPoint)")
            
            viewModel?.nodes[index].anchorPoint = node.anchorPoint
            viewModel?.nodes[index].position.x = node.position.x
            viewModel?.nodes[index].position.y = node.position.y
            
            isDraggingAnchorIndicator = false
            removeAnchorPointIndicator()
            return
        }
        
        if let selectedNode = selectedNode,
           let nodeIDString = selectedNode.userData?["id"] as? String,
           let nodeID = UUID(uuidString: nodeIDString),
           let index = viewModel?.nodes.firstIndex(where: { $0.id == nodeID }) {
            viewModel?.nodes[index].position.x = selectedNode.position.x
            viewModel?.nodes[index].position.y = selectedNode.position.y
            viewModel?.nodes[index].anchorPoint = selectedNode.anchorPoint
        }
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
               let nodeIDString = node.userData?["id"] as? String,
               let nodeID = UUID(uuidString: nodeIDString),
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
        var sortedNodes = viewModel.nodes.sorted { $0.position.z < $1.position.z }
        guard let currentIndex = sortedNodes.firstIndex(where: { $0.id == nodeID }) else { return }
        let newIndex = currentIndex + zDelta
        guard newIndex >= 0, newIndex < sortedNodes.count else { return }
        sortedNodes.swapAt(currentIndex, newIndex)
        for (index, node) in sortedNodes.enumerated() {
            if let originalIndex = viewModel.nodes.firstIndex(where: { $0.id == node.id }) {
                viewModel.nodes[originalIndex].position.z = CGFloat(index)
            }
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
        if let spriteNode = tappedNode as? SKSpriteNode, spriteNode.name?.contains("-EDT-") == true {
            if selectedNode != spriteNode {
                deselectCurrentNode()
                selectedNode = spriteNode
                spriteNode.shader = borderShader
                updateAnchorPointIndicator(for: spriteNode)
                LogManager.shared.addLog("selected spriteNode anchor point: \(spriteNode.anchorPoint)")
                viewModel?.selectedNodeID = spriteNode.nodeID
            }
        } else {
            deselectCurrentNode()
            removeAnchorPointIndicator()
        }
    }

    func updateHighlight(for selectedID: UUID?) {
        if let currentNode = selectedNode {
            currentNode.shader = borderShader
        }
        guard let selectedID = selectedID else {
            selectedNode = nil
            return
        }
        if let spriteNode = children.first(where: { $0.nodeID == selectedID }) as? SKSpriteNode {
            spriteNode.shader = borderShader
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
              let nodeIDString = selectedNode.userData?["id"] as? String,
              let nodeID = UUID(uuidString: nodeIDString) else { return }
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
        if let current = selectedNode {
            current.shader = nil
        }
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
            spriteNode.position = CGPoint(x: procNode.position.x, y: procNode.position.y)
            spriteNode.zPosition = procNode.position.z
            spriteNode.zRotation = procNode.rotation
            spriteNode.xScale = procNode.scale.x
            spriteNode.yScale = procNode.scale.y
            spriteNode.alpha = procNode.opacity
            spriteNode.name = procNode.nodeName
            spriteNode.anchorPoint = procNode.anchorPoint
            spriteNode.userData = ["id": procNode.id.uuidString]
            addChild(spriteNode)
            if let selectedID = viewModel?.selectedNodeID, selectedID == procNode.id {
                spriteNode.shader = borderShader
                updateAnchorPointIndicator(for: spriteNode)
                selectedNode = spriteNode
            }
        }
    }
}
