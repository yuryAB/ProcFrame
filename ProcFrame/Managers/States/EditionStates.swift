//
//  EditionStates.swift
//  ProcFrame
//
//  Created by yury antony on 04/03/25.
//


import GameplayKit

class SelectionState: GKState {
    weak var scene: CanvaSpriteScene?
    
    init(scene: CanvaSpriteScene) {
        self.scene = scene
    }
    
    override func didEnter(from previousState: GKState?) {
        scene?.setHighlightToTarget()
    }
    
    override func willExit(to nextState: GKState) { }
}

class RotationState: GKState {
    weak var scene: CanvaSpriteScene?
    
    init(scene: CanvaSpriteScene) {
        self.scene = scene
    }
    
    override func didEnter(from previousState: GKState?) {
        scene?.setHighlightToTarget()
    }
    
    override func willExit(to nextState: GKState) { }
}

class ParentState: GKState {
    weak var scene: CanvaSpriteScene?
    
    init(scene: CanvaSpriteScene) {
        self.scene = scene
    }
    
    override func didEnter(from previousState: GKState?) {
        scene?.setHighlightToTargetAndChilds()
    }
    
    override func willExit(to nextState: GKState) {
        scene?.removeParentingHighlightsFromTarget()
    }
}
