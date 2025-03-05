//
//  ProcNode.swift
//  ProcFrame
//
//  Created by yury antony on 02/02/25.
//

import Foundation
import SwiftUI

struct ProcScale: Equatable, Hashable {
    var x: CGFloat = 1.0
    var y: CGFloat = 1.0
}

struct ProcNode: Identifiable, Equatable {
    let id = UUID()
    let nodeName: String

    var position: CGPoint
    var zPosition: CGFloat
    var rotation: CGFloat
    var anchorPoint: CGPoint
    var scale: ProcScale
    var opacity: CGFloat
    var image: ImportedImage
    var parentID: UUID?
    var children: [UUID] = []

    mutating func addChild(_ childID: UUID) {
        if !children.contains(childID) {
            children.append(childID)
        }
    }

    mutating func removeChild(_ childID: UUID) -> UUID? {
        if let index = children.firstIndex(of: childID) {
            return children.remove(at: index)
        }
        return nil
    }
    
    func isChild(of parentID: UUID) -> Bool {
        return self.parentID == parentID
    }
    
    mutating func detachFromParent() {
        self.parentID = nil
    }

    init(image: ImportedImage,
         position: CGPoint = .zero,
         zPosition: CGFloat = 0,
         rotation: CGFloat = 0,
         anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5),
         scale: ProcScale = ProcScale(),
         opacity: CGFloat = 1.0,
         parentID: UUID? = nil) {
        
        self.nodeName = image.name + "-EDT-"
        self.image = image
        self.position = position
        self.zPosition = zPosition
        self.rotation = rotation
        self.anchorPoint = anchorPoint
        self.scale = scale
        self.opacity = opacity
        self.parentID = parentID
    }
}
