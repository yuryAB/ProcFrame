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
    var sceneAdapter: SpriteSceneAdapter!
    var nodeStore: NodeStore!
    var logStore: LogStore?
    
    override func scrollWheel(with event: NSEvent) {
        if event.hasPreciseScrollingDeltas {
            let delta = CGPoint(
                x: event.scrollingDeltaX,
                y: event.scrollingDeltaY
            )
            if nodeStore.editionType != .rotation {
                sceneAdapter.moveCamera(by: delta)
            } else {
                let yDelta: CGFloat = event.scrollingDeltaY
                sceneAdapter.rotateSelectedNode(by: yDelta)
            }
        } else {
            let zoomDelta: CGFloat = event.scrollingDeltaY * 0.01
            if nodeStore.editionType != .rotation {
                sceneAdapter.zoomCamera(by: zoomDelta)
            } else {
                let yDelta: CGFloat = event.scrollingDeltaY
                sceneAdapter.rotateSelectedNode(by: yDelta)
            }
        }
        super.scrollWheel(with: event)
    }
    
    override func otherMouseDown(with event: NSEvent) {
        logStore?.addLog("Middle mouse click detected at: \(event.locationInWindow)")
        if event.buttonNumber == 2 {
            let delta = CGPoint(
                x: event.scrollingDeltaX,
                y: event.scrollingDeltaY
            )
            sceneAdapter.moveCamera(by: delta)
        } else {
            super.otherMouseDown(with: event)
        }
    }
}

// MARK: - CustomSpriteView: SwiftUI Integration
struct CustomSpriteView: NSViewRepresentable {
    let sceneAdapter: SpriteSceneAdapter
    let nodeStore: NodeStore
    let logStore: LogStore?
    
    func makeNSView(context: Context) -> SKView {
        let skView = CustomSKView()
        skView.allowsTransparency = true
        skView.presentScene(sceneAdapter.skScene)
        skView.sceneAdapter = sceneAdapter
        skView.nodeStore = nodeStore
        skView.logStore = logStore
        
        let magnificationGesture = NSMagnificationGestureRecognizer(target: context.coordinator,
                                                                    action: #selector(Coordinator.handleMagnification(_:)))
        skView.addGestureRecognizer(magnificationGesture)
        
        return skView
    }
    
    func updateNSView(_ nsView: SKView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(sceneAdapter: sceneAdapter)
    }
    
    class Coordinator: NSObject {
        let sceneAdapter: SpriteSceneAdapter
        
        init(sceneAdapter: SpriteSceneAdapter) {
            self.sceneAdapter = sceneAdapter
        }
        
        @objc func handleMagnification(_ gesture: NSMagnificationGestureRecognizer) {
            if gesture.state == .changed {
                sceneAdapter.zoomCamera(by: gesture.magnification)
                gesture.magnification = 0
            }
        }
    }
}

// MARK: - SwiftUI Wrapper
struct SpriteCanvasView: View {
    @ObservedObject var store: ProcFrameViewModel
    let sceneAdapter: SpriteSceneAdapter
    let logStore: LogStore
    
    var body: some View {
        CustomSpriteView(sceneAdapter: sceneAdapter, nodeStore: store, logStore: logStore)
            .frame(width: 750, height: 600)
            .onChange(of: store.nodes) {
                if sceneAdapter.syncNodesIfNeeded(previousCount: &store.previousNodeCount) {
                    store.isStructuralChange = false
                }
            }
            .onChange(of: store.selectedNodeID) {
                sceneAdapter.updateSelectionHighlight(for: store.selectedNodeID)
            }
    }
}
