//
//  TimelineTrackView.swift
//  ProcFrame
//
//  Created by yury antony on 19/03/25.
//

import SwiftUI

struct TimelineTrackView: View {
    @ObservedObject var viewModel: ActionTimelineViewModel
    @Binding var timelineDuration: Double
    @Binding var currentTime: Double
    @State private var positionA = ScrollPosition(edge: .top)
    @State private var positionB = ScrollPosition(edge: .top)
    @State private var isSyncing = false
    @State private var timelineWidth: CGFloat = 1
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.2))
            
            HStack {
                VStack {
                    Rectangle()
                        .frame(width: 70, height: 30)
                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.nodes, id: \.id) { node in
                            TimelineThumbnailRow(viewModel: viewModel, node: node)
                        }
                    }
                    .scrollPosition($positionA)
                    .onChange(of: positionA) {
                        guard !isSyncing else { return }
                        isSyncing = true
                        positionB = positionA
                        DispatchQueue.main.async {
                            isSyncing = false
                        }
                    }
                }
                
                Divider()
                    .frame(width: 1)
                    .background(Color.gray.opacity(0.5))

                VStack {
                    TimelineRulerView(timelineDuration: timelineDuration, currentTime: $currentTime)
                    .frame(height: 30)
                    ScrollView {
                        ForEach(viewModel.nodes, id: \.id) { node in
                            TimelineTrackRow(
                                viewModel: viewModel,
                                node: node,
                                currentTime: $currentTime,
                                timelineDuration: $timelineDuration,
                                timelineWidth: timelineWidth
                            )
                        }
                    }
                    .scrollPosition($positionB)
                    .onChange(of: positionB) {
                                guard !isSyncing else { return }
                                isSyncing = true
                                positionA = positionB
                                DispatchQueue.main.async {
                                    isSyncing = false
                                }
                            }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                timelineWidth = max(1, geo.size.width)
                            }
                            .onChange(of: geo.size.width) {
                                timelineWidth = max(1, geo.size.width)
                            }
                    }
                )
            }
        }
    }
}

struct TimelineRulerView: View {
    let timelineDuration: Double
    @Binding var currentTime: Double

    var body: some View {
        GeometryReader { geo in
            let timelineWidth = geo.size.width
            let tickCount = Int(timelineDuration * 10)
            let tickSpacing = timelineWidth / CGFloat(max(tickCount, 1))
            let playheadX = timelineDuration > 0 ? CGFloat(currentTime / timelineDuration) * timelineWidth : 0
            ZStack(alignment: .leading) {
                ForEach(0...tickCount, id: \.self) { tick in
                    let xPos = CGFloat(tick) * tickSpacing
                    Path { path in
                        path.move(to: CGPoint(x: xPos, y: 0))
                        path.addLine(to: CGPoint(x: xPos, y: 10))
                    }
                    .stroke(Color.primary, lineWidth: 1)
                    if tick % 10 == 0 {
                        Text(String(format: "%.0f", Double(tick) / 10))
                            .font(.caption2)
                            .position(x: xPos, y: 20)
                    }
                }

                Rectangle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 1, height: geo.size.height)
                    .position(x: min(max(playheadX, 0), timelineWidth), y: geo.size.height / 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard timelineDuration > 0 else { return }
                        let ratio = min(max(value.location.x / timelineWidth, 0), 1)
                        currentTime = ratio * timelineDuration
                    }
            )
        }
    }
}

struct TimelineThumbnailRow: View {
    let viewModel: ActionTimelineViewModel
    let node: ProcNode
    
    var body: some View {
        HStack(spacing: 10) {
            if let nsImage = node.image.fullImage.resized(to: CGSize(width: 25, height: 25)) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            Button {
                viewModel.addKeyframe(for: node.id)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 20, height: 20)
                        .shadow(radius: 2)
                    
                    Image(systemName: "plus")
                        .font(.body)
                        .foregroundColor(.black.opacity(0.8))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 70, height: 50, alignment: .leading)
        .background(isSelected ? Color.white.opacity(0.03) : Color.clear)
    }
    
    private var isSelected: Bool {
        viewModel.selectedNodeID == node.id
    }
}

struct TimelineTrackRow: View {
    let viewModel: ActionTimelineViewModel
    let node: ProcNode
    @Binding var currentTime: Double
    @Binding var timelineDuration: Double
    let timelineWidth: CGFloat
    private let minGap: Double = 0.05
    private let snapStep: Double = 0.1

    private var nodeKeyframes: [TransformKeyframe] {
        viewModel.keyframes(for: node.id)
    }
    
    var body: some View {
        HStack() {
            HStack() {
                ForEach(0..<max(nodeKeyframes.count - 1, 0), id: \.self) { index in
                    let startKeyframe = nodeKeyframes[index]
                    let endKeyframe = nodeKeyframes[index + 1]
                    let previousTime = index > 0 ? nodeKeyframes[index - 1].time : 0
                    let nextTime = index + 2 < nodeKeyframes.count ? nodeKeyframes[index + 2].time : timelineDuration
                    ActionTrackView(
                        startTime: startKeyframe.time,
                        endTime: endKeyframe.time,
                        timelineDuration: timelineDuration,
                        availableWidth: timelineWidth,
                        interpolation: startKeyframe.interpolation,
                        isActive: currentTime >= startKeyframe.time && currentTime <= endKeyframe.time,
                        onMoveSegment: { deltaTime in
                            let minDelta = previousTime - startKeyframe.time
                            let maxDelta = nextTime - endKeyframe.time
                            let snappedDelta = (deltaTime / snapStep).rounded() * snapStep
                            let clampedDelta = min(max(snappedDelta, minDelta), maxDelta)
                            let newStart = startKeyframe.time + clampedDelta
                            let newEnd = endKeyframe.time + clampedDelta
                            viewModel.updateKeyframeTime(nodeID: node.id, keyframeID: startKeyframe.id, newTime: newStart)
                            viewModel.updateKeyframeTime(nodeID: node.id, keyframeID: endKeyframe.id, newTime: newEnd)
                        },
                        onUpdateEnd: { newTime in
                            let snapped = (newTime / snapStep).rounded() * snapStep
                            let clamped = max(min(snapped, nextTime), startKeyframe.time + minGap)
                            viewModel.updateKeyframeTime(nodeID: node.id, keyframeID: endKeyframe.id, newTime: clamped)
                        },
                        onUpdateInterpolation: { interpolation in
                            viewModel.updateKeyframeInterpolation(nodeID: node.id, keyframeID: startKeyframe.id, interpolation: interpolation)
                        },
                        onDeleteStart: {
                            viewModel.removeKeyframe(nodeID: node.id, keyframeID: startKeyframe.id)
                        },
                        onDeleteEnd: {
                            viewModel.removeKeyframe(nodeID: node.id, keyframeID: endKeyframe.id)
                        }
                    )
                }
            }
            .padding(.horizontal)
            
        }
        .frame(height: 50)
        .background(isSelected ? Color.white.opacity(0.03) : Color.clear)
        .cornerRadius(3)
        .onTapGesture(perform: toggleSelection)
    }
    
    private var isSelected: Bool {
        viewModel.selectedNodeID == node.id
    }
    
    private func toggleSelection() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.selectedNodeID = isSelected ? nil : node.id
        }
    }
}
