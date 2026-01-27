//
//  CanvasKeyAction.swift
//  ProcFrame
//
//  Created by yury antony on 13/02/25.
//


enum CanvasKeyAction: UInt16 {
    case enterSelectionState = 1   // "s"
    case enterRotationState = 15   // "r"
    case deleteNode = 7      // "x"
    case moveBack = 33       // "["
    case moveFront = 30      // "]"
    case enterParentState = 35  // "p"
}


enum DepthOrientation {
    case forward
    case backward
}
