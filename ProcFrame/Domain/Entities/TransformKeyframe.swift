import Foundation
import CoreGraphics

struct TransformKeyframe: Identifiable, Equatable, Codable {
    let id: UUID
    let nodeID: UUID
    var time: Double
    var position: CGPoint
    var rotation: CGFloat
    var interpolation: KeyframeInterpolation

    init(id: UUID = UUID(),
         nodeID: UUID,
         time: Double,
         position: CGPoint,
         rotation: CGFloat,
         interpolation: KeyframeInterpolation = .linear) {
        self.id = id
        self.nodeID = nodeID
        self.time = time
        self.position = position
        self.rotation = rotation
        self.interpolation = interpolation
    }
}
