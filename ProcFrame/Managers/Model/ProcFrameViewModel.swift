//
//  ProcFrameViewModel.swift
//  ProcFrame
//
//  Created by yury antony on 04/02/25.
//


import Foundation
import SpriteKit

class ProcFrameViewModel: ObservableObject {
    @Published var nodes: [ProcNode] = []
    @Published var selectedNodeID: UUID?
    @Published var isStructuralChange = false
    @Published var notificationMessage: String?
    @Published var notificationType: NotificationType?
    @Published var editionType: EditionType = .selection
    
    lazy var spriteScene: CanvaSpriteScene = {
        CanvaSpriteScene(size: CGSize(width: 650, height: 550), viewModel: self)
    }()
    
    func reorderNodesByZPosition() {
        var zPositionMap: [UUID: CGFloat] = [:]

        for node in nodes {
            zPositionMap[node.id] = calculateAdjustedZPosition(for: node, in: zPositionMap)
        }

        nodes.sort {
            let zPositionA = zPositionMap[$0.id] ?? $0.zPosition
            let zPositionB = zPositionMap[$1.id] ?? $1.zPosition
            return zPositionA > zPositionB
        }

        isStructuralChange = true
    }

    private func calculateAdjustedZPosition(for node: ProcNode, in cache: [UUID: CGFloat]) -> CGFloat {
        if let cachedValue = cache[node.id] {
            return cachedValue
        }

        guard let parentID = node.parentID, let parentNode = nodes.first(where: { $0.id == parentID }) else {
            return node.zPosition
        }

        let newPosition = (cache[parentID] ?? parentNode.zPosition) + node.zPosition
        return newPosition
    }
    
    func updateProcNode(from spriteNode: SKSpriteNode) {
        guard let nodeID = spriteNode.nodeID,
              let index = nodes.firstIndex(where: { $0.id == nodeID }) else { return }

        nodes[index].position = spriteNode.position
        nodes[index].zPosition = spriteNode.zPosition
        nodes[index].rotation = spriteNode.zRotation
        nodes[index].scale = ProcScale(x: spriteNode.xScale, y: spriteNode.yScale)
        nodes[index].opacity = spriteNode.alpha
        nodes[index].anchorPoint = spriteNode.anchorPoint

        if let parentSpriteNode = spriteNode.parent as? SKSpriteNode,
           let parentID = parentSpriteNode.nodeID {
            nodes[index].parentID = parentID
        } else {
            nodes[index].parentID = nil
        }
    }
    
    func findParentNodes() -> [ProcNode] {
        return nodes.filter { $0.parentID == nil }
    }
    
    func sortedChildren(of parentID: UUID) -> [ProcNode] {
        return nodes.filter { $0.parentID == parentID }
            .sorted { $0.zPosition > $1.zPosition }
    }
    
    func sendNotification(_ message: String, type: NotificationType) {
        notificationMessage = message
        notificationType = type
    }
}

extension ProcFrameViewModel {
    enum NotificationType {
        case warning
        case error
        case success
    }
}

enum EditionType {
    case selection
    case rotation
    case parent
    case depth
}
