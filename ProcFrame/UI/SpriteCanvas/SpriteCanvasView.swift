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
    override func scrollWheel(with event: NSEvent) {
        guard let scene = self.scene as? CanvaSpriteScene else { return }
        if event.hasPreciseScrollingDeltas {
            let delta = CGPoint(
                x: event.scrollingDeltaX,
                y: event.scrollingDeltaY
            )
            scene.moveCamera(by: delta)
            
            let yDelta: CGFloat = event.scrollingDeltaY
            scene.rotateSelectedNode(by: yDelta)
        } else {
            let zoomDelta: CGFloat = event.scrollingDeltaY * 0.01
            scene.zoomCamera(by: zoomDelta)
            let yDelta: CGFloat = event.scrollingDeltaY
            scene.rotateSelectedNode(by: yDelta)
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
            scene.moveCamera(by: delta)
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
        
        let magnificationGesture = NSMagnificationGestureRecognizer(target: context.coordinator,
                                                                    action: #selector(Coordinator.handleMagnification(_:)))
        skView.addGestureRecognizer(magnificationGesture)
        
        return skView
    }
    
    func updateNSView(_ nsView: SKView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(spriteScene: viewModel.spriteScene)
    }
    
    class Coordinator: NSObject {
        let spriteScene: SKScene
        
        init(spriteScene: SKScene) {
            self.spriteScene = spriteScene
        }
        
        @objc func handleMagnification(_ gesture: NSMagnificationGestureRecognizer) {
            guard let view = gesture.view,
                  let skView = view as? SKView,
                  let scene = skView.scene as? CanvaSpriteScene else { return }
            if gesture.state == .changed {
                scene.zoomCamera(by: gesture.magnification)
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
                if viewModel.isStructuralChange {
                    viewModel.spriteScene.updateNodes()
                    viewModel.isStructuralChange = false
                }
            }
            .onChange(of: viewModel.selectedNodeID) {
                viewModel.spriteScene.updateHighlight(for: viewModel.selectedNodeID)
            }
    }
}
