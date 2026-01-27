import Foundation
import CoreGraphics

struct ReorderNodesByZPosition {
    static func run(nodes: inout [ProcNode]) {
        var zPositionMap: [UUID: CGFloat] = [:]

        for node in nodes {
            zPositionMap[node.id] = calculateAdjustedZPosition(for: node, in: nodes, cache: &zPositionMap)
        }

        nodes.sort {
            let zPositionA = zPositionMap[$0.id] ?? $0.zPosition
            let zPositionB = zPositionMap[$1.id] ?? $1.zPosition
            return zPositionA > zPositionB
        }
    }

    private static func calculateAdjustedZPosition(
        for node: ProcNode,
        in nodes: [ProcNode],
        cache: inout [UUID: CGFloat]
    ) -> CGFloat {
        if let cachedValue = cache[node.id] {
            return cachedValue
        }

        guard let parentID = node.parentID,
              let parentNode = nodes.first(where: { $0.id == parentID }) else {
            return node.zPosition
        }

        let newPosition = (cache[parentID] ?? parentNode.zPosition) + node.zPosition
        return newPosition
    }
}
