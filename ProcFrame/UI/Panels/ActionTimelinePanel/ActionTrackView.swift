//
//  ActionTrackView.swift
//  ProcFrame
//
//  Created by yury antony on 16/03/25.
//

import SwiftUI

struct ActionTrackView: View {
    @Binding var actionMark: ActionMark
    let timelineDuration: Double
    let availableWidth: CGFloat
    
    private var computedWidth: CGFloat {
        CGFloat(actionMark.duration / timelineDuration) * availableWidth
    }
    
    private var computedXPos: CGFloat {
        CGFloat(actionMark.startTime / timelineDuration) * availableWidth
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
            ActionTrackBackground(
                actionMark: $actionMark,
                timelineDuration: timelineDuration,
                availableWidth: availableWidth,
                totalWidth: totalWidth
            )
            HStack(spacing: 0) {
                ActionTrackBorder(
                    timelineDuration: timelineDuration,
                    availableWidth: availableWidth,
                    side: .left
                ) { deltaTime in
                    let newStartTime = max(0, min(actionMark.startTime + deltaTime, timelineDuration - actionMark.duration))
                    actionMark.startTime = newStartTime
                }
                
                ActionTrackDisplay(
                    actionMark: $actionMark,
                    timelineDuration: timelineDuration,
                    availableWidth: availableWidth
                )
                
                ActionTrackBorder(
                    timelineDuration: timelineDuration,
                    availableWidth: availableWidth,
                    side: .right
                ) { deltaTime in
                    let newDuration = max(0.1, min(actionMark.duration + deltaTime, timelineDuration - actionMark.startTime))
                    actionMark.duration = newDuration
                }
            }
        }
        .position(x: clampedXPos + totalWidth / 2, y: 25)
    }
}

struct ActionTrackBackground: View {
    @Binding var actionMark: ActionMark
    let timelineDuration: Double
    let availableWidth: CGFloat
    let totalWidth: CGFloat
    
    private var computedWidth: CGFloat {
        CGFloat(actionMark.duration / timelineDuration) * availableWidth
    }
    
    var body: some View {
        Rectangle()
            .fill(Color(.white))
            .frame(width: totalWidth, height: 30)
            .cornerRadius(5)
    }
}

struct ActionTrackDisplay: View {
    @Binding var actionMark: ActionMark
    let timelineDuration: Double
    let availableWidth: CGFloat
    
    private var computedWidth: CGFloat {
        CGFloat(actionMark.duration / timelineDuration) * availableWidth
    }
    
    var body: some View {
        Button(action: {
            // Sua lógica de ação aqui
        }) {
            Text("action")
                .font(.thinInfo)
                .foregroundColor(.primary)
                .frame(width: computedWidth, height: 25)
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
