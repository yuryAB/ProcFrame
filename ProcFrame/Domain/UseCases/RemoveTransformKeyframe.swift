import Foundation

struct RemoveTransformKeyframe {
    static func run(
        timeline: inout AnimationTimeline,
        nodeID: UUID,
        keyframeID: UUID
    ) {
        guard let trackIndex = timeline.tracks.firstIndex(where: { $0.nodeID == nodeID }) else { return }

        timeline.tracks[trackIndex].keyframes.removeAll { $0.id == keyframeID }
        if timeline.tracks[trackIndex].keyframes.isEmpty {
            timeline.tracks.remove(at: trackIndex)
        }
    }
}
