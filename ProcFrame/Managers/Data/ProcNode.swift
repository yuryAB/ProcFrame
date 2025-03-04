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
    var children: [ProcNode] = []

    mutating func addChild(_ child: ProcNode) {
        var newChild = child
        newChild.parentID = self.id
        children.append(newChild)
        children.sort { $0.zPosition > $1.zPosition }
    }

    mutating func removeChild(_ childID: UUID) -> ProcNode? {
        if let index = children.firstIndex(where: { $0.id == childID }) {
            var removedChild = children.remove(at: index)
            removedChild.parentID = nil
            return removedChild
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
