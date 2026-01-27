import Foundation

struct AnimationTimeline: Equatable, Codable {
    var duration: Double
    var tracks: [NodeAnimationTrack]

    init(duration: Double = 1.0, tracks: [NodeAnimationTrack] = []) {
        self.duration = duration
        self.tracks = tracks
    }
}
