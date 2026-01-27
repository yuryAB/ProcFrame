//
//  ProcFrameViewModel.swift
//  ProcFrame
//
//  Created by yury antony on 04/02/25.
//


import Foundation
import CoreGraphics

class ProcFrameViewModel: ObservableObject, NodeStore {
    @Published var nodes: [ProcNode] = [] {
        didSet {
            handleNodeChanges(oldNodes: oldValue)
        }
    }
    @Published var selectedNodeID: UUID?
    @Published var isStructuralChange = false
    @Published var notificationMessage: String?
    @Published var notificationType: NotificationType?
    @Published var actionMarks: [ActionMark] = []
    @Published var editionType: EditionType = .selection
    @Published var timeline: AnimationTimeline = AnimationTimeline()
    var previousNodeCount: Int = 0
    var currentTime: Double = 0
    var isPlaying: Bool = false
    private var isApplyingTimeline = false
    private var isAutoKeyEnabled = true
    
    func addActionMark(for nodeID: UUID, startTime: Double, duration: Double) {
        let newActionMark = ActionMark(
            nodeID: nodeID,
            startTime: startTime,
            duration: duration
        )
        actionMarks.append(newActionMark)
    }
    
    func reorderNodesByZPosition() {
        ResolveZPositionConflicts.run(nodes: &nodes)
        ReorderNodesByZPosition.run(nodes: &nodes)
        isStructuralChange = true
    }

    func setNodeZPosition(nodeID: UUID, to newZPosition: CGFloat) {
        guard let sourceIndex = nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        let currentZPosition = nodes[sourceIndex].zPosition
        guard currentZPosition != newZPosition else { return }

        if let targetIndex = nodes.firstIndex(where: { $0.zPosition == newZPosition && $0.id != nodeID }) {
            nodes[targetIndex].zPosition = currentZPosition
        }

        nodes[sourceIndex].zPosition = newZPosition
        reorderNodesByZPosition()
    }

    func moveNodeZPosition(nodeID: UUID, step: Int) {
        guard step != 0 else { return }
        guard let sourceIndex = nodes.firstIndex(where: { $0.id == nodeID }) else { return }
        let newZPosition = nodes[sourceIndex].zPosition + CGFloat(step)
        setNodeZPosition(nodeID: nodeID, to: newZPosition)
    }
    
    func findParentNodes() -> [ProcNode] {
        return nodes.filter { $0.parentID == nil }
    }
    
    func sortedChildren(of parentID: UUID) -> [ProcNode] {
        return nodes.filter { $0.parentID == parentID }
            .sorted { $0.zPosition > $1.zPosition }
    }

    func updateTimelineDuration(_ newDuration: Double) {
        let clampedDuration = max(0.1, newDuration)
        timeline.duration = clampedDuration
        for trackIndex in timeline.tracks.indices {
            for keyframeIndex in timeline.tracks[trackIndex].keyframes.indices {
                if timeline.tracks[trackIndex].keyframes[keyframeIndex].time > clampedDuration {
                    timeline.tracks[trackIndex].keyframes[keyframeIndex].time = clampedDuration
                }
            }
            timeline.tracks[trackIndex].keyframes.sort { $0.time < $1.time }
        }
    }

    func addKeyframe(for nodeID: UUID, time: Double) {
        guard let node = nodes.first(where: { $0.id == nodeID }) else { return }
        let clampedTime = max(0, min(time, timeline.duration))
        let keyframe = TransformKeyframe(nodeID: nodeID,
                                         time: clampedTime,
                                         position: node.position,
                                         rotation: node.rotation,
                                         interpolation: .linear)
        let startTransform = TransformSample(position: node.position, rotation: node.rotation)
        UpsertTransformKeyframe.run(timeline: &timeline,
                                    keyframe: keyframe,
                                    insertStartIfNeeded: true,
                                    startTransform: startTransform,
                                    shouldUpdateInterpolation: true)
    }

    func keyframes(for nodeID: UUID) -> [TransformKeyframe] {
        guard let track = timeline.tracks.first(where: { $0.nodeID == nodeID }) else { return [] }
        return track.keyframes.sorted { $0.time < $1.time }
    }

    func updateKeyframeTime(nodeID: UUID, keyframeID: UUID, newTime: Double) {
        MoveTransformKeyframe.run(timeline: &timeline,
                                  nodeID: nodeID,
                                  keyframeID: keyframeID,
                                  newTime: newTime,
                                  duration: timeline.duration)
    }

    func updateKeyframeInterpolation(nodeID: UUID, keyframeID: UUID, interpolation: KeyframeInterpolation) {
        guard let trackIndex = timeline.tracks.firstIndex(where: { $0.nodeID == nodeID }),
              let keyframeIndex = timeline.tracks[trackIndex].keyframes.firstIndex(where: { $0.id == keyframeID }) else {
            return
        }
        timeline.tracks[trackIndex].keyframes[keyframeIndex].interpolation = interpolation
    }

    func removeKeyframe(nodeID: UUID, keyframeID: UUID) {
        RemoveTransformKeyframe.run(timeline: &timeline, nodeID: nodeID, keyframeID: keyframeID)
    }

    func applyTimeline(at time: Double) {
        let clampedTime = max(0, min(time, timeline.duration))
        guard !timeline.tracks.isEmpty else { return }

        isApplyingTimeline = true
        defer { isApplyingTimeline = false }

        let trackMap = Dictionary(uniqueKeysWithValues: timeline.tracks.map { ($0.nodeID, $0) })
        for index in nodes.indices {
            let nodeID = nodes[index].id
            guard let track = trackMap[nodeID],
                  let sample = SampleTransformAtTime.run(track: track, time: clampedTime) else {
                continue
            }
            nodes[index].position = sample.position
            nodes[index].rotation = sample.rotation
        }
    }

    func sendNotification(_ message: String, type: NotificationType) {
        notificationMessage = message
        notificationType = type
    }

    private func handleNodeChanges(oldNodes: [ProcNode]) {
        let oldIDs = Set(oldNodes.map { $0.id })
        let newIDs = Set(nodes.map { $0.id })
        let removedIDs = oldIDs.subtracting(newIDs)
        if !removedIDs.isEmpty {
            timeline.tracks.removeAll { removedIDs.contains($0.nodeID) }
        }

        guard isAutoKeyEnabled, !isApplyingTimeline, !isPlaying else { return }

        let oldMap = Dictionary(uniqueKeysWithValues: oldNodes.map { ($0.id, $0) })
        for node in nodes {
            guard let oldNode = oldMap[node.id] else { continue }
            if node.position != oldNode.position || node.rotation != oldNode.rotation {
                recordKeyframeFromChange(current: node, previous: oldNode)
            }
        }
    }

    private func recordKeyframeFromChange(current: ProcNode, previous: ProcNode) {
        let clampedTime = max(0, min(currentTime, timeline.duration))
        let keyframe = TransformKeyframe(nodeID: current.id,
                                         time: clampedTime,
                                         position: current.position,
                                         rotation: current.rotation,
                                         interpolation: .linear)
        let startTransform = TransformSample(position: previous.position, rotation: previous.rotation)
        UpsertTransformKeyframe.run(timeline: &timeline,
                                    keyframe: keyframe,
                                    insertStartIfNeeded: true,
                                    startTransform: startTransform,
                                    shouldUpdateInterpolation: false)
    }
}

extension ProcFrameViewModel {
    enum NotificationType {
        case warning
        case error
        case success
    }
}
