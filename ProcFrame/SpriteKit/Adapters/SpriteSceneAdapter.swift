import Foundation
import SpriteKit
import CoreGraphics

final class SpriteSceneAdapter {
    private let scene: CanvaSpriteScene
    private let nodeStore: NodeStore

    init(nodeStore: NodeStore) {
        self.nodeStore = nodeStore
        self.scene = CanvaSpriteScene(size: CGSize(width: 650, height: 550), nodeStore: nodeStore)
    }

    var skScene: SKScene {
        scene
    }

    var editionType: EditionType {
        nodeStore.editionType
    }

    @discardableResult
    func syncNodesIfNeeded(previousCount: inout Int) -> Bool {
        if nodeStore.nodes.count > previousCount {
            scene.nodeLifecycleController.updateNodes()
            previousCount = nodeStore.nodes.count
            return true
        }
        previousCount = nodeStore.nodes.count
        return false
    }

    func updateSelectionHighlight(for selectedID: UUID?) {
        scene.nodeSelectionController.updateHighlight(for: selectedID)
    }

    func moveCamera(by delta: CGPoint) {
        scene.cameraController.moveCamera(by: delta)
    }

    func zoomCamera(by delta: CGFloat) {
        scene.cameraController.zoomCamera(by: delta)
    }

    func rotateSelectedNode(by delta: CGFloat) {
        scene.rotateSelectedNode(by: delta)
    }
}
