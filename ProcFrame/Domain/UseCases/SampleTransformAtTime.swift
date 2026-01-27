import Foundation
import CoreGraphics

struct SampleTransformAtTime {
    static func run(track: NodeAnimationTrack, time: Double) -> TransformSample? {
        guard !track.keyframes.isEmpty else { return nil }

        let sortedKeyframes = track.keyframes.sorted { $0.time < $1.time }

        if time <= sortedKeyframes[0].time {
            return TransformSample(position: sortedKeyframes[0].position,
                                   rotation: sortedKeyframes[0].rotation)
        }

        if let last = sortedKeyframes.last, time >= last.time {
            return TransformSample(position: last.position, rotation: last.rotation)
        }

        for index in 0..<(sortedKeyframes.count - 1) {
            let start = sortedKeyframes[index]
            let end = sortedKeyframes[index + 1]
            if time >= start.time && time <= end.time {
                let segmentDuration = max(end.time - start.time, 0.0001)
                let rawT = (time - start.time) / segmentDuration
                let easedT = start.interpolation.apply(rawT)
                let position = lerp(start.position, end.position, t: easedT)
                let rotation = lerpAngle(start.rotation, end.rotation, t: easedT)
                return TransformSample(position: position, rotation: rotation)
            }
        }

        return nil
    }

    private static func lerp(_ a: CGPoint, _ b: CGPoint, t: Double) -> CGPoint {
        CGPoint(
            x: a.x + (b.x - a.x) * CGFloat(t),
            y: a.y + (b.y - a.y) * CGFloat(t)
        )
    }

    private static func lerpAngle(_ a: CGFloat, _ b: CGFloat, t: Double) -> CGFloat {
        let delta = atan2(sin(b - a), cos(b - a))
        return a + delta * CGFloat(t)
    }
}
