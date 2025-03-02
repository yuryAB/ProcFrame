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
    @Published var rotating = false
    @Published var parenting = false
    @Published var isStructuralChange = false
    @Published var notificationMessage: String?
    @Published var notificationType: NotificationType?
    
    lazy var spriteScene: CanvaSpriteScene = {
        CanvaSpriteScene(size: CGSize(width: 650, height: 550), viewModel: self)
    }()
    
    func moveNodeInList(nodeID: UUID, direction: Int) {
        guard let currentIndex = nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        let newIndex = currentIndex + direction
        guard newIndex >= 0, newIndex < nodes.count else { return }

        isStructuralChange = true
        nodes.swapAt(currentIndex, newIndex)
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
