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
    @State private var keyframes: [Double] = []
    @Binding var isPlaying: Bool
    @State private var positionA = ScrollPosition(edge: .top)
    @State private var positionB = ScrollPosition(edge: .top)
    @State private var isSyncing = false
    
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
                    TimelineRulerView(timelineDuration: timelineDuration)
                    .frame(height: 30)
                    ScrollView {
                        ForEach(viewModel.nodes, id: \.id) { node in
                            TimelineTrackRow(
                                viewModel: viewModel,
                                node: node,
                                currentTime: $currentTime,
                                keyframes: $keyframes,
                                timelineDuration: $timelineDuration
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
            }
        }
    }
}

struct TimelineRulerView: View {
    let timelineDuration: Double
    var body: some View {
        GeometryReader { geo in
            let timelineWidth = geo.size.width
            let tickCount = Int(timelineDuration * 10)
            let tickSpacing = timelineWidth / CGFloat(max(tickCount, 1))
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
            }
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
                viewModel.addActionMark(for: node.id, startTime: 0.2, duration: 0.5)
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
    @Binding var keyframes: [Double]
    @Binding var timelineDuration: Double
    
    var body: some View {
        HStack() {
            HStack() {
                ForEach(viewModel.actionMarkIndices.filter { viewModel.actionMarks[$0].nodeID == node.id }, id: \.self) { index in
                    ActionTrackView(
                        actionMark: viewModel.bindingForActionMark(at: index),
                        timelineDuration: timelineDuration,
                        availableWidth: 1900
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
