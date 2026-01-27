//
//  ActionMark.swift
//  ProcFrame
//
//  Created by yury antony on 16/03/25.
//

import Foundation

struct ActionMark: Identifiable {
    let id = UUID()
    let nodeID: UUID
    var startTime: Double
    var duration: Double
}
