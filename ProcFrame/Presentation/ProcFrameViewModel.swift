//
//  ProcFrameViewModel.swift
//  ProcFrame
//
//  Created by yury antony on 04/02/25.
//


import Foundation

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
        ReorderNodesByZPosition.run(nodes: &nodes)
        isStructuralChange = true
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
