//
//  EditionStates.swift
//  ProcFrame
//
//  Created by yury antony on 04/03/25.
//


import GameplayKit

class SelectionState: GKState {
    weak var scene: CanvaSpriteScene?
    private var viewModel: ProcFrameViewModel
    
    init(scene: CanvaSpriteScene, viewModel: ProcFrameViewModel) {
        self.scene = scene
        self.viewModel = viewModel
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass != SelectionState.self
    }

    override func didEnter(from previousState: GKState?) {
        scene?.setHighlightToTarget()
    }
}

class RotationState: GKState {
    weak var scene: CanvaSpriteScene?
    private var viewModel: ProcFrameViewModel
    
    init(scene: CanvaSpriteScene, viewModel: ProcFrameViewModel) {
        self.scene = scene
        self.viewModel = viewModel
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass != RotationState.self
    }

    override func didEnter(from previousState: GKState?) {
        scene?.setHighlightToTarget()
    }
}

class ParentState: GKState {
    weak var scene: CanvaSpriteScene?
    private var viewModel: ProcFrameViewModel
    
    init(scene: CanvaSpriteScene, viewModel: ProcFrameViewModel) {
        self.scene = scene
        self.viewModel = viewModel
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass != ParentState.self
    }

    override func didEnter(from previousState: GKState?) {
        scene?.setHighlightToTargetAndChildren()
    }
    
    override func willExit(to nextState: GKState) {
        scene?.removeParentingHighlightsFromTarget()
    }
}

class DepthState: GKState {
    weak var scene: CanvaSpriteScene?
    private var viewModel: ProcFrameViewModel
    
    init(scene: CanvaSpriteScene, viewModel: ProcFrameViewModel) {
        self.scene = scene
        self.viewModel = viewModel
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass != DepthState.self
    }

    override func didEnter(from previousState: GKState?) {
        scene?.setHighlightToTarget()
    }
    
    override func willExit(to nextState: GKState) { }
}
