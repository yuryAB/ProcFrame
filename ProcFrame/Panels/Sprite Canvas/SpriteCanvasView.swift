////
////  SpriteCanvasView.swift
////  ProcFrame
////
////  Created by yury antony on 28/01/25.
////

import Foundation
import SpriteKit
import SwiftUI

// MARK: - CustomSKView: Scroll and Special Click Events
class CustomSKView: SKView {
    override func scrollWheel(with event: NSEvent) {
        if let scene = self.scene as? CanvaSpriteScene {
            if event.hasPreciseScrollingDeltas {
                let delta = CGPoint(x: event.scrollingDeltaX, y: event.scrollingDeltaY)
                scene.moveCamera(by: delta)
            } else {
                let zoomDelta: CGFloat = event.scrollingDeltaY * 0.01
                scene.zoomCamera(by: zoomDelta)
            }
        }
        super.scrollWheel(with: event)
    }
    
    override func otherMouseDown(with event: NSEvent) {
        if event.buttonNumber == 2 {
            LogManager.shared.addLog("Middle mouse click detected at: \(event.locationInWindow)")
        } else {
            super.otherMouseDown(with: event)
        }
    }
}

// MARK: - CustomSpriteView: SwiftUI Integration (without pan gesture to avoid conflict with node drag)
struct CustomSpriteView: NSViewRepresentable {
    @EnvironmentObject var viewModel: ProcFrameViewModel
    
    func makeNSView(context: Context) -> SKView {
        let skView = CustomSKView()
        skView.allowsTransparency = true
        skView.presentScene(viewModel.spriteScene)
        
        let clickGesture = NSClickGestureRecognizer(target: context.coordinator,
                                                      action: #selector(Coordinator.handleClick(_:)))
        skView.addGestureRecognizer(clickGesture)
        
        let magnificationGesture = NSMagnificationGestureRecognizer(target: context.coordinator,
                                                                      action: #selector(Coordinator.handleMagnification(_:)))
        skView.addGestureRecognizer(magnificationGesture)
        
        let rotationGesture = NSRotationGestureRecognizer(target: context.coordinator,
                                                            action: #selector(Coordinator.handleRotation(_:)))
        skView.addGestureRecognizer(rotationGesture)
        
        return skView
    }
    
    func updateNSView(_ nsView: SKView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(spriteScene: viewModel.spriteScene)
    }
    
    class Coordinator: NSObject {
        let spriteScene: SKScene
        
        init(spriteScene: SKScene) {
            self.spriteScene = spriteScene
        }
        
        @objc func handleClick(_ gesture: NSClickGestureRecognizer) {
            if gesture.state == .ended,
               let view = gesture.view,
               let skView = view as? SKView,
               let scene = skView.scene as? CanvaSpriteScene {
                let locationInView = gesture.location(in: view)
                let locationInScene = scene.convertPoint(fromView: locationInView)
                LogManager.shared.addLog("Click converted in scene: \(locationInScene)")
            }
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
        
        @objc func handleRotation(_ gesture: NSRotationGestureRecognizer) {
            guard let view = gesture.view,
                  let skView = view as? SKView,
                  let scene = skView.scene as? CanvaSpriteScene else { return }
            if gesture.state == .changed {
                scene.rotateSelectedNode(by: gesture.rotation)
                gesture.rotation = 0
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
            .onAppear {
                viewModel.spriteScene.setViewModel(viewModel)
            }
            .onChange(of: viewModel.nodes) {
                viewModel.spriteScene.updateNodes(with: viewModel.nodes)
            }
            .onChange(of: viewModel.selectedNodeID) {
                viewModel.spriteScene.updateHighlight(for: viewModel.selectedNodeID)
            }
    }
}
