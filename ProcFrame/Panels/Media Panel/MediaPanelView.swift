//
//  MediaPanelView.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//

import SwiftUI

struct MediaPanelView: View {
    let color: Color
    @EnvironmentObject var viewModel: ProcFrameViewModel

    var body: some View {
        VStack(spacing: 3) {
            ImportButtonView(action: importImages)
            nodeList()
            //actionButtons()
        }
        .padding(4)
        .background(color)
        .cornerRadius(8)
    }
    
    private func nodeList() -> some View {
        List {
            ForEach(viewModel.nodes.sorted { $0.zPosition > $1.zPosition }, id: \.id) { procNode in
                SelectableRowView(procNode: procNode)
            }
        }
        .cornerRadius(8)
    }
    
    private func actionButtons() -> some View {
        HStack {
            SelectAllButtonView(
                isChecked: Binding(
                    get: { viewModel.selectedNodeID != nil },
                    set: { isChecked in toggleSelectAll(isChecked) }
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
    
    private func toggleSelectAll(_ isChecked: Bool) {
        viewModel.selectedNodeID = isChecked ? viewModel.nodes.first?.id : nil
    }
    
    private func importImages() {
        ImageImportManager.importImages { newImages in
            let maxZPosition = viewModel.nodes.map { $0.zPosition }.max() ?? 0
            let newNodes = newImages.enumerated().map { index, image in
                ProcNode(image: image, zPosition: CGFloat(Int(maxZPosition) + index + 1))
            }
            viewModel.isStructuralChange = true
            viewModel.nodes.append(contentsOf: newNodes)
        }
    }
}
