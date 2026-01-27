//
//  ActionTimelineSettings.swift
//  ProcFrame
//
//  Created by yury antony on 19/03/25.
//

import SwiftUI

struct TimelineSettingsView: View {
    @Binding var timelineDuration: Double
    @Binding var currentTime: Double
    @Binding var isPlaying: Bool
    let togglePlayback: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Text("Duração (s):")
                .font(.subheadline)
            AdjustableValueView(value: $timelineDuration, range: 0...100)
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .padding(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
    }
}

struct AdjustableValueView: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    @State private var isEditing = false
    @State private var dragOffset: CGFloat = 0
    @State private var lastValue: Double = 0

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "line.horizontal.3")
                .font(.title2)
                .foregroundColor(.gray)
                .onHover { hovering in hovering ? NSCursor.resizeLeftRight.push() : NSCursor.pop() }
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let delta = Double(gesture.translation.width) * 0.1
                            let newValue = lastValue + delta
                            value = max(0.5, min(newValue, range.upperBound))
                        }
                        .onEnded { _ in
                            lastValue = value
                        }
                )
            
            if isEditing {
                TextField("", value: $value, format: .number)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        isEditing = false
                    }
                    .onDisappear {
                        lastValue = value
                    }
            } else {
                Text("\(value, specifier: "%.2f")")
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.clear)
                    .onTapGesture {
                        isEditing = true
                    }
            }
        }
    }
}
