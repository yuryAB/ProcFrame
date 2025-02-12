//
//  SceneAssetStore.swift
//  ProcFrame
//
//  Created by yury antony on 02/02/25.
//


import Foundation

extension Notification.Name {
    static let procNodeUpdated = Notification.Name("nodeUpdated")
}

enum NodeUpdateType {
    case added
    case updated
    case removed
}

class SceneAssetStore {
    static let shared = SceneAssetStore()
    
    private(set) var nodes: [ProcNode] = []

    private init() {}

    func addNode(_ node: ProcNode) {
        nodes.append(node)
        notifyUpdate(nodeID: node.id, updateType: "added")
    }

    func removeNode(_ nodeID: UUID) {
        nodes.removeAll { $0.id == nodeID }
        notifyUpdate(nodeID: nodeID, updateType: "removed")
    }

    func updateNode(
        nodeID: UUID,
        position: ProcPosition? = nil,
        rotation: CGFloat? = nil,
        anchorPoint: CGPoint? = nil,
        scale: ProcScale? = nil,
        opacity: CGFloat? = nil,
        parentID: UUID? = nil
    ) {
        if let index = nodes.firstIndex(where: { $0.id == nodeID }) {
            if let position = position {
                nodes[index].position = position
            }
            if let rotation = rotation {
                nodes[index].rotation = rotation
            }
            if let anchorPoint = anchorPoint {
                nodes[index].anchorPoint = anchorPoint
            }
            if let scale = scale {
                nodes[index].scale = scale
            }
            if let opacity = opacity {
                nodes[index].opacity = opacity
            }
            if let parentID = parentID {
                nodes[index].parentID = parentID
            }

            notifyUpdate(nodeID: nodeID, updateType: "updated")
        }
    }
    
    private func notifyUpdate(nodeID: UUID, updateType: String) {
        NotificationCenter.default.post(
            name: .procNodeUpdated,
            object: nil,
            userInfo: ["nodeID": nodeID, "updateType": updateType]
        )
    }
}
