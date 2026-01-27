//
//  ActionTimelinePanelView.swift
//  ProcFrame
//
//  Created by yury antony on 11/03/25.
//

import SwiftUI

struct ActionTimelinePanelView: View {
    @ObservedObject var viewModel: ActionTimelineViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            TimelineSettingsView(timelineDuration: $viewModel.timelineDuration,
                                 currentTime: $viewModel.currentTime,
                                 isPlaying: $viewModel.isPlaying,
                                 togglePlayback: viewModel.togglePlayback)
            TimelineTrackView(viewModel: viewModel,
                              timelineDuration: $viewModel.timelineDuration,
                              currentTime: $viewModel.currentTime)
        }
        .padding(10)
        .background(Color(nsColor: .controlColor))
        .cornerRadius(8)
    }
}
