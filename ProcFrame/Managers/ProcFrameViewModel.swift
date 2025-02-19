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
    @Published var isRotating = false
    @Published var isMerging = false
    @Published var isStructuralChange = false
    
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
}
