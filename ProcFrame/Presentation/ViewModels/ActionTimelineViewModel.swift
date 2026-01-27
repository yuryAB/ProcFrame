import Foundation
import Combine

final class ActionTimelineViewModel: ObservableObject {
    @Published var currentTime: Double = 0 {
        didSet {
            updateCurrentTime()
        }
    }
    @Published var isPlaying: Bool = false {
        didSet {
            store.isPlaying = isPlaying
        }
    }
    @Published var timelineDuration: Double = 1.0 {
        didSet {
            updateTimelineDuration()
        }
    }

    private let store: ProcFrameViewModel
    private var cancellable: AnyCancellable?
    private var timer: Timer?
    private var isUpdatingTime = false

    init(store: ProcFrameViewModel) {
        self.store = store
        self.currentTime = store.currentTime
        self.timelineDuration = store.timeline.duration
        self.cancellable = store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    var nodes: [ProcNode] {
        store.nodes
    }

    var selectedNodeID: UUID? {
        get { store.selectedNodeID }
        set { store.selectedNodeID = newValue }
    }

    func addKeyframe(for nodeID: UUID) {
        store.addKeyframe(for: nodeID, time: currentTime)
    }

    func keyframes(for nodeID: UUID) -> [TransformKeyframe] {
        store.keyframes(for: nodeID)
    }

    func updateKeyframeTime(nodeID: UUID, keyframeID: UUID, newTime: Double) {
        store.updateKeyframeTime(nodeID: nodeID, keyframeID: keyframeID, newTime: newTime)
        store.applyTimeline(at: currentTime)
    }

    func removeKeyframe(nodeID: UUID, keyframeID: UUID) {
        store.removeKeyframe(nodeID: nodeID, keyframeID: keyframeID)
        store.applyTimeline(at: currentTime)
    }

    func updateKeyframeInterpolation(nodeID: UUID, keyframeID: UUID, interpolation: KeyframeInterpolation) {
        store.updateKeyframeInterpolation(nodeID: nodeID, keyframeID: keyframeID, interpolation: interpolation)
        store.applyTimeline(at: currentTime)
    }

    func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }

    func startPlayback() {
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }
            let newTime = self.currentTime + 0.01
            if newTime >= self.timelineDuration {
                self.currentTime = self.timelineDuration
                self.pausePlayback()
            } else {
                self.currentTime = newTime
            }
        }
    }

    func pausePlayback() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    private func updateCurrentTime() {
        guard !isUpdatingTime else { return }
        isUpdatingTime = true
        let clampedTime = max(0, min(currentTime, timelineDuration))
        if clampedTime != currentTime {
            currentTime = clampedTime
            isUpdatingTime = false
            return
        }
        store.currentTime = clampedTime
        store.applyTimeline(at: clampedTime)
        isUpdatingTime = false
    }

    private func updateTimelineDuration() {
        let clampedDuration = max(0.1, timelineDuration)
        if clampedDuration != timelineDuration {
            timelineDuration = clampedDuration
            return
        }
        store.updateTimelineDuration(clampedDuration)
        if currentTime > clampedDuration {
            currentTime = clampedDuration
        }
    }

    deinit {
        timer?.invalidate()
    }
}
