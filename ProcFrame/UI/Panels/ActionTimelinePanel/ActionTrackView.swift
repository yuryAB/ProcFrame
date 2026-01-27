//
//  ActionTrackView.swift
//  ProcFrame
//
//  Created by yury antony on 16/03/25.
//

import SwiftUI

struct ActionTrackView: View {
    let startTime: Double
    let endTime: Double
    let timelineDuration: Double
    let availableWidth: CGFloat
    let interpolation: KeyframeInterpolation
    let isActive: Bool
    let onMoveSegment: (Double) -> Void
    let onUpdateEnd: (Double) -> Void
    let onUpdateInterpolation: (KeyframeInterpolation) -> Void
    let onDeleteStart: () -> Void
    let onDeleteEnd: () -> Void
    
    private var segmentDuration: Double {
        max(0, endTime - startTime)
    }
    
    private var computedWidth: CGFloat {
        guard timelineDuration > 0 else { return 0 }
        return CGFloat(segmentDuration / timelineDuration) * availableWidth
    }
    
    private var computedXPos: CGFloat {
        guard timelineDuration > 0 else { return 0 }
        return CGFloat(startTime / timelineDuration) * availableWidth
    }
    
    private var totalWidth: CGFloat {
        computedWidth + 30
    }
    
    private var clampedXPos: CGFloat {
        if computedXPos < 0 {
            return 0
        }
        if computedXPos + totalWidth > availableWidth {
            return max(0, availableWidth - totalWidth)
        }
        return computedXPos
    }
    
    var body: some View {
        ZStack {
            ActionTrackBackground(totalWidth: totalWidth, isActive: isActive)
            HStack(spacing: 0) {
                ActionTrackBorder(timelineDuration: timelineDuration,
                                  availableWidth: availableWidth,
                                  side: .left) { deltaTime in
                    onMoveSegment(deltaTime)
                }
                
                ActionTrackDisplay(width: computedWidth, label: interpolation.displayName)
                
                ActionTrackBorder(timelineDuration: timelineDuration,
                                  availableWidth: availableWidth,
                                  side: .right) { deltaTime in
                    onUpdateEnd(endTime + deltaTime)
                }
            }
        }
        .position(x: clampedXPos + totalWidth / 2, y: 25)
        .contextMenu {
            ForEach(KeyframeInterpolation.allCases, id: \.self) { option in
                Button(option.displayName) {
                    onUpdateInterpolation(option)
                }
            }
            Divider()
            Button("Remove Start Keyframe") {
                onDeleteStart()
            }
            Button("Remove End Keyframe") {
                onDeleteEnd()
            }
        }
    }
}

struct ActionTrackBackground: View {
    let totalWidth: CGFloat
    let isActive: Bool
    
    var body: some View {
        Rectangle()
            .fill(isActive ? Color.green.opacity(0.7) : Color.white)
            .frame(width: totalWidth, height: 30)
            .cornerRadius(5)
    }
}

struct ActionTrackDisplay: View {
    let width: CGFloat
    let label: String
    
    var body: some View {
        Button(action: { }) {
            Text(label)
                .font(.thinInfo)
                .foregroundColor(.primary)
                .frame(width: width, height: 25)
                .background(Color.mainDark)
                .cornerRadius(5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActionTrackBorder: View {
    let timelineDuration: Double
    let availableWidth: CGFloat
    let side: BorderSide
    let onDrag: (Double) -> Void
    
    enum BorderSide {
        case left
        case right
    }
    
    private var handleImageName: String {
        side == .right ? "chevron.compact.left.chevron.compact.right" : "pause"
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 10, height: 30)
                .cornerRadius(5)
            Image(systemName: handleImageName)
                .font(.system(size: 15))
                .foregroundStyle(Color.mainDark)
                .symbolRenderingMode(.palette)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
        }
        .onHover { isHovering in
            if isHovering {
                NSCursor.resizeLeftRight.push()
            } else {
                NSCursor.pop()
            }
        }
        .gesture(DragGesture()
            .onChanged { value in
                let deltaTime = (value.translation.width / availableWidth) * timelineDuration
                onDrag(deltaTime)
            }
        )
    }
}
