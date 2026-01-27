import Foundation

struct NodeAnimationTrack: Identifiable, Equatable, Codable {
    var id: UUID { nodeID }
    let nodeID: UUID
    var keyframes: [TransformKeyframe]

    init(nodeID: UUID, keyframes: [TransformKeyframe] = []) {
        self.nodeID = nodeID
        self.keyframes = keyframes
    }
}
