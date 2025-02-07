//
//  ProcNode.swift
//  ProcFrame
//
//  Created by yury antony on 02/02/25.
//

import Foundation
import SwiftUI

struct ProcPosition: Equatable, Hashable {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var z: CGFloat = 0
}

struct ProcAnchorPoint: Equatable {
    var x: CGFloat = 0.5
    var y: CGFloat = 0.5
}

struct ProcScale: Equatable, Hashable {
    var x: CGFloat = 1.0
    var y: CGFloat = 1.0
}

struct ProcNode: Identifiable, Equatable {
    let id = UUID()
    let nodeName: String

    var position: ProcPosition
    var rotation: CGFloat
    var anchorPoint: ProcAnchorPoint
    var scale: ProcScale
    var opacity: CGFloat
    var image: ImportedImage

    var parentID: UUID?

    init(image: ImportedImage,
         position: ProcPosition = ProcPosition(),
         rotation: CGFloat = 0,
         anchorPoint: ProcAnchorPoint = ProcAnchorPoint(),
         scale: ProcScale = ProcScale(),
         opacity: CGFloat = 1.0,
         parentID: UUID? = nil) {
        
        self.nodeName = image.name + "-EDT-"
        self.image = image
        self.position = position
        self.rotation = rotation
        self.anchorPoint = anchorPoint
        self.scale = scale
        self.opacity = opacity
        self.parentID = parentID
    }
}
