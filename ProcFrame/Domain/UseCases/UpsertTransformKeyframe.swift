import Foundation

struct UpsertTransformKeyframe {
    static func run(
        timeline: inout AnimationTimeline,
        keyframe: TransformKeyframe,
        insertStartIfNeeded: Bool,
        startTransform: TransformSample?,
        shouldUpdateInterpolation: Bool
    ) {
        let nodeID = keyframe.nodeID

        if let trackIndex = timeline.tracks.firstIndex(where: { $0.nodeID == nodeID }) {
            upsert(in: &timeline.tracks[trackIndex],
                   keyframe: keyframe,
                   insertStartIfNeeded: insertStartIfNeeded,
                   startTransform: startTransform,
                   shouldUpdateInterpolation: shouldUpdateInterpolation)
        } else {
            var track = NodeAnimationTrack(nodeID: nodeID)
            upsert(in: &track,
                   keyframe: keyframe,
                   insertStartIfNeeded: insertStartIfNeeded,
                   startTransform: startTransform,
                   shouldUpdateInterpolation: shouldUpdateInterpolation)
            timeline.tracks.append(track)
        }
    }

    private static func upsert(
        in track: inout NodeAnimationTrack,
        keyframe: TransformKeyframe,
        insertStartIfNeeded: Bool,
        startTransform: TransformSample?,
        shouldUpdateInterpolation: Bool
    ) {
        if insertStartIfNeeded,
           track.keyframes.isEmpty,
           keyframe.time > 0 {
            let start = startTransform ?? TransformSample(position: keyframe.position,
                                                          rotation: keyframe.rotation)
            let startKeyframe = TransformKeyframe(nodeID: keyframe.nodeID,
                                                  time: 0,
                                                  position: start.position,
                                                  rotation: start.rotation,
                                                  interpolation: .linear)
            track.keyframes.append(startKeyframe)
        }

        if let existingIndex = track.keyframes.firstIndex(where: { $0.time == keyframe.time }) {
            track.keyframes[existingIndex].position = keyframe.position
            track.keyframes[existingIndex].rotation = keyframe.rotation
            if shouldUpdateInterpolation {
                track.keyframes[existingIndex].interpolation = keyframe.interpolation
            }
        } else {
            track.keyframes.append(keyframe)
        }

        track.keyframes.sort { $0.time < $1.time }
    }
}
