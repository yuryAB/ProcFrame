//
//  SpriteCanvasView.swift
//  ProcFrame
//
//  Created by yury antony on 28/01/25.
//

import Foundation
import SpriteKit
import SwiftUI

// MARK: - CustomSKView: Scroll and Special Click Events
class CustomSKView: SKView {
    var viewModel: ProcFrameViewModel!
    
    override func scrollWheel(with event: NSEvent) {
        guard let scene = self.scene as? CanvaSpriteScene else { return }
        if event.hasPreciseScrollingDeltas {
            let delta = CGPoint(
                x: event.scrollingDeltaX,
                y: event.scrollingDeltaY
            )
            if viewModel.editionType != .rotation {
                scene.cameraController.moveCamera(by: delta)
            } else {
                let yDelta: CGFloat = event.scrollingDeltaY
                scene.rotateSelectedNode(by: yDelta)
            }
        } else {
            let zoomDelta: CGFloat = event.scrollingDeltaY * 0.01
            if viewModel.editionType != .rotation {
                scene.cameraController.zoomCamera(by: zoomDelta)
            } else {
                let yDelta: CGFloat = event.scrollingDeltaY
                scene.rotateSelectedNode(by: yDelta)
            }
        }
        super.scrollWheel(with: event)
    }
    
    override func otherMouseDown(with event: NSEvent) {
        LogManager.shared.addLog("Middle mouse click detected at: \(event.locationInWindow)")
        guard let scene = self.scene as? CanvaSpriteScene else { return }
        if event.buttonNumber == 2 {
            let delta = CGPoint(
                x: event.scrollingDeltaX,
                y: event.scrollingDeltaY
            )
            scene.cameraController.moveCamera(by: delta)
        } else {
            super.otherMouseDown(with: event)
        }
    }
}

// MARK: - CustomSpriteView: SwiftUI Integration
struct CustomSpriteView: NSViewRepresentable {
    @EnvironmentObject var viewModel: ProcFrameViewModel
    
    func makeNSView(context: Context) -> SKView {
        let skView = CustomSKView()
        skView.allowsTransparency = true
        skView.presentScene(viewModel.spriteScene)
        skView.viewModel = viewModel
        
        let magnificationGesture = NSMagnificationGestureRecognizer(target: context.coordinator,
                                                                    action: #selector(Coordinator.handleMagnification(_:)))
        skView.addGestureRecognizer(magnificationGesture)
        
        return skView
    }
    
    func updateNSView(_ nsView: SKView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(spriteScene: viewModel.spriteScene, viewModel: viewModel)
    }
    
    class Coordinator: NSObject {
        let spriteScene: SKScene
        let viewModel: ProcFrameViewModel
        
        init(spriteScene: SKScene, viewModel: ProcFrameViewModel) {
            self.spriteScene = spriteScene
            self.viewModel = viewModel
        }
        
        @objc func handleMagnification(_ gesture: NSMagnificationGestureRecognizer) {
            guard let view = gesture.view,
                  let skView = view as? SKView,
                  let scene = skView.scene as? CanvaSpriteScene else { return }
            if gesture.state == .changed {
                scene.cameraController.zoomCamera(by: gesture.magnification)
                gesture.magnification = 0
            }
        }
    }
}

// MARK: - SwiftUI Wrapper
struct SpriteCanvasView: View {
    @EnvironmentObject var viewModel: ProcFrameViewModel
    
    var body: some View {
        CustomSpriteView()
            .frame(width: 700, height: 600)
            .onChange(of: viewModel.nodes) {
                if viewModel.nodes.count > viewModel.previousNodeCount {
                    viewModel.spriteScene.nodeLifecycleController.updateNodes()
                    viewModel.isStructuralChange = false
                }
                viewModel.previousNodeCount = viewModel.nodes.count
            }
            .onChange(of: viewModel.selectedNodeID) {
                viewModel.spriteScene.nodeSelectionController.updateHighlight(for: viewModel.selectedNodeID)
            }
    }
}
