import Foundation
import CoreGraphics

struct ResolveZPositionConflicts {
    static func run(nodes: inout [ProcNode]) {
        let indexedNodes = nodes.enumerated().map { (index: $0.offset, node: $0.element) }
        let sortedNodes = indexedNodes.sorted {
            if $0.node.zPosition == $1.node.zPosition {
                return $0.index < $1.index
            }
            return $0.node.zPosition > $1.node.zPosition
        }

        var usedPositions = Set<CGFloat>()
        for entry in sortedNodes {
            var candidate = entry.node.zPosition
            while usedPositions.contains(candidate) {
                candidate -= 1
            }
            nodes[entry.index].zPosition = candidate
            usedPositions.insert(candidate)
        }
    }
}
