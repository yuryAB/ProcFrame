//
//  MediaPanelView.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//

import SwiftUI

struct MediaPanelView: View {
    let color: Color
    @ObservedObject var viewModel: MediaPanelViewModel

    var body: some View {
        VStack(spacing: 3) {
            ImportButtonView(action: viewModel.importImages)
            nodeList()
            //actionButtons()
        }
        .padding(4)
        .background(color)
        .cornerRadius(8)
    }
    
    private func nodeList() -> some View {
        List {
            ForEach(viewModel.nodes, id: \.id) { procNode in
                SelectableRowView(procNode: procNode)
                    .environmentObject(viewModel)
            }
        }
        .cornerRadius(8)
        .animation(.default, value: viewModel.isStructuralChange)
    }
    
    private func actionButtons() -> some View {
        HStack {
            SelectAllButtonView(
                isChecked: Binding(
                    get: { viewModel.selectedNodeID != nil },
                    set: { isChecked in viewModel.toggleSelectAll(isChecked) }
                )
            )
            .disabled(viewModel.nodes.isEmpty)
            
            MoveToTrashButtonView(isChecked: .constant(viewModel.selectedNodeID != nil))
                .disabled(viewModel.selectedNodeID == nil)
        }
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}
