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

    lazy var spriteScene: CanvaSpriteScene = {
        CanvaSpriteScene(size: CGSize(width: 650, height: 550), viewModel: self)
    }()
}
