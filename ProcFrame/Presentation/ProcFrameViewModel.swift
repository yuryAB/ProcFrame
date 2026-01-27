//
//  ProcFrameViewModel.swift
//  ProcFrame
//
//  Created by yury antony on 04/02/25.
//


import Foundation
import CoreGraphics

class ProcFrameViewModel: ObservableObject, NodeStore {
    @Published var nodes: [ProcNode] = []
    @Published var selectedNodeID: UUID?
    @Published var isStructuralChange = false
    @Published var notificationMessage: String?
    @Published var notificationType: NotificationType?
    @Published var actionMarks: [ActionMark] = []
    @Published var editionType: EditionType = .selection
    var previousNodeCount: Int = 0
    
    func addActionMark(for nodeID: UUID, startTime: Double, duration: Double) {
        let newActionMark = ActionMark(
            nodeID: nodeID,
            startTime: startTime,
            duration: duration
        )
        actionMarks.append(newActionMark)
    }
    
    func reorderNodesByZPosition() {
        ResolveZPositionConflicts.run(nodes: &nodes)
        ReorderNodesByZPosition.run(nodes: &nodes)
        isStructuralChange = true
    }

    func setNodeZPosition(nodeID: UUID, to newZPosition: CGFloat) {
        guard let sourceIndex = nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        let currentZPosition = nodes[sourceIndex].zPosition
        guard currentZPosition != newZPosition else { return }

        if let targetIndex = nodes.firstIndex(where: { $0.zPosition == newZPosition && $0.id != nodeID }) {
            nodes[targetIndex].zPosition = currentZPosition
        }

        nodes[sourceIndex].zPosition = newZPosition
        reorderNodesByZPosition()
    }

    func moveNodeZPosition(nodeID: UUID, step: Int) {
        guard step != 0 else { return }
        guard let sourceIndex = nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        let newZPosition = nodes[sourceIndex].zPosition + CGFloat(step)
        setNodeZPosition(nodeID: nodeID, to: newZPosition)
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
