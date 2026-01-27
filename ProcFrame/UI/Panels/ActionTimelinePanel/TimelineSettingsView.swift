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
            Text("Tempo (s):")
                .font(.subheadline)
            AdjustableValueView(value: $currentTime, range: 0...timelineDuration)
            Text("Duração (s):")
                .font(.subheadline)
            AdjustableValueView(value: $timelineDuration, range: 0.1...100)
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
    @State private var lastValue: Double = 0
    @State private var isDragging = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "line.horizontal.3")
                .font(.title2)
                .foregroundColor(.gray)
                .onHover { hovering in hovering ? NSCursor.resizeLeftRight.push() : NSCursor.pop() }
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if !isDragging {
                                lastValue = value
                                isDragging = true
                            }
                            let delta = Double(gesture.translation.width) * 0.1
                            let newValue = lastValue + delta
                            value = min(max(newValue, range.lowerBound), range.upperBound)
                        }
                        .onEnded { _ in
                            lastValue = value
                            isDragging = false
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
        .onAppear {
            lastValue = value
        }
        .onChange(of: value) {
            if !isEditing && !isDragging {
                lastValue = value
            }
        }
    }
}
