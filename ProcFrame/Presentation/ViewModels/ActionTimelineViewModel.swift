import Foundation
import Combine
import SwiftUI

final class ActionTimelineViewModel: ObservableObject {
    @Published var currentTime: Double = 0
    @Published var isPlaying: Bool = false
    @Published var timelineDuration: Double = 1.0

    private let store: ProcFrameViewModel
    private var cancellable: AnyCancellable?
    private var timer: Timer?

    init(store: ProcFrameViewModel) {
        self.store = store
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

    func addActionMark(for nodeID: UUID, startTime: Double, duration: Double) {
        store.addActionMark(for: nodeID, startTime: startTime, duration: duration)
    }

    func bindingForActionMark(at index: Int) -> Binding<ActionMark> {
        Binding<ActionMark>(
            get: { self.store.actionMarks[index] },
            set: { self.store.actionMarks[index] = $0 }
        )
    }

    var actionMarkIndices: [Int] {
        store.actionMarks.indices.map { $0 }
    }

    var actionMarks: [ActionMark] {
        store.actionMarks
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

    deinit {
        timer?.invalidate()
    }
}
