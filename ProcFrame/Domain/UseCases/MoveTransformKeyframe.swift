import Foundation

struct MoveTransformKeyframe {
    static func run(
        timeline: inout AnimationTimeline,
        nodeID: UUID,
        keyframeID: UUID,
        newTime: Double,
        duration: Double
    ) {
        guard let trackIndex = timeline.tracks.firstIndex(where: { $0.nodeID == nodeID }),
              let keyframeIndex = timeline.tracks[trackIndex].keyframes.firstIndex(where: { $0.id == keyframeID }) else {
            return
        }

        let clampedTime = max(0, min(newTime, duration))
        timeline.tracks[trackIndex].keyframes[keyframeIndex].time = clampedTime
        timeline.tracks[trackIndex].keyframes.sort { $0.time < $1.time }
    }
}
