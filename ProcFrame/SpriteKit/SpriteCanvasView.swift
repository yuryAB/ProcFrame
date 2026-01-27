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
    private var isMiddleMouseDragging = false
    private var lastMiddleMousePosition: CGPoint?
    
    override func scrollWheel(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            let zoomDelta: CGFloat = event.scrollingDeltaY * 0.01
            sceneAdapter.zoomCamera(by: zoomDelta)
            super.scrollWheel(with: event)
            return
        }

        let isMouseScroll = event.phase == .none && event.momentumPhase == .none

        if isMouseScroll {
            if nodeStore.editionType != .rotation {
                let delta = CGPoint(
                    x: event.scrollingDeltaX,
                    y: event.scrollingDeltaY
                )
                sceneAdapter.moveCamera(by: delta)
            } else {
                let yDelta: CGFloat = event.scrollingDeltaY
                sceneAdapter.rotateSelectedNode(by: yDelta)
            }
        } else {
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
        }
        super.scrollWheel(with: event)
    }
    
    override func otherMouseDown(with event: NSEvent) {
        logStore?.addLog("Middle mouse click detected at: \(event.locationInWindow)")
        if event.buttonNumber == 2 {
            isMiddleMouseDragging = true
            lastMiddleMousePosition = event.locationInWindow
        } else {
            super.otherMouseDown(with: event)
        }
    }

    override func otherMouseDragged(with event: NSEvent) {
        if isMiddleMouseDragging {
            let currentPosition = event.locationInWindow
            let previousPosition = lastMiddleMousePosition ?? currentPosition
            let deltaX = currentPosition.x - previousPosition.x
            let deltaY = currentPosition.y - previousPosition.y
            sceneAdapter.moveCamera(by: CGPoint(x: deltaX, y: -deltaY))
            lastMiddleMousePosition = currentPosition
            return
        }
        super.otherMouseDragged(with: event)
    }

    override func otherMouseUp(with event: NSEvent) {
        if event.buttonNumber == 2 {
            isMiddleMouseDragging = false
            lastMiddleMousePosition = nil
            return
        }
        super.otherMouseUp(with: event)
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
                if sceneAdapter.syncNodesIfNeeded(previousCount: &store.previousNodeCount, forceUpdate: true) {
                    store.isStructuralChange = false
                }
            }
            .onChange(of: store.selectedNodeID) {
                sceneAdapter.updateSelectionHighlight(for: store.selectedNodeID)
            }
    }
}
