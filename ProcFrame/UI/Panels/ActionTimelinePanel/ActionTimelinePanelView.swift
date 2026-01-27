//
//  ActionTimelinePanelView.swift
//  ProcFrame
//
//  Created by yury antony on 11/03/25.
//

import SwiftUI

struct ActionTimelinePanelView: View {
    @EnvironmentObject var viewModel: ProcFrameViewModel
    @State private var currentTime: Double = 0
    @State private var isPlaying: Bool = false
    @State private var timer: Timer? = nil
    @State private var timelineDuration: Double = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
            TimelineSettingsView(timelineDuration: $timelineDuration, currentTime: $currentTime,
                                 isPlaying: $isPlaying, togglePlayback: togglePlayback)
            TimelineTrackView(timelineDuration: $timelineDuration, currentTime: $currentTime, isPlaying: $isPlaying)
        }
        .padding(10)
        .background(Color(nsColor: .controlColor))
        .cornerRadius(8)
        .environmentObject(viewModel)
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
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            let newTime = currentTime + 0.01
            if newTime >= timelineDuration {
                currentTime = timelineDuration
                pausePlayback()
            } else {
                currentTime = newTime
            }
        }
    }
    
    func pausePlayback() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
}
