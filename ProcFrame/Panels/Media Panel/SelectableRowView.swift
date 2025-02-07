//
//  SelectableRowView.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//

import SwiftUI

struct SelectableRowView: View {
    let image: ImportedImage
    @EnvironmentObject var viewModel: ProcFrameViewModel

    var body: some View {
        ZStack(alignment: .leading) {
            if isSelected {
                Color(nsColor: .selectedContentBackgroundColor)
                    .animation(.easeInOut(duration: 0.1), value: isSelected)
            }
            
            HStack(spacing: 8) {
                imageView
                TextView
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: toggleSelection)
        .frame(maxWidth: .infinity, minHeight: 30)
        .cornerRadius(3)
    }
    
    // MARK: - Subviews
    private var imageView: some View {
        Group {
            if let nsImage = image.fullImage.resized(to: CGSize(width: 25, height: 25)) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
        }
    }
    
    private var TextView: some View {
        Group {
            Text(image.name.deletingPathExtension)
                .lineLimit(2)
                .truncationMode(.tail)
                .font(.system(size: 11))
                .multilineTextAlignment(.leading)
        }
    }
    
    // MARK: - Computed Properties
    private var isSelected: Bool {
        viewModel.selectedNodeID == imageID
    }
    
    private var imageID: UUID? {
        viewModel.nodes.first { $0.image == image }?.id
    }
    
    // MARK: - Actions
    private func toggleSelection() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.selectedNodeID = (viewModel.selectedNodeID == imageID) ? nil : imageID
        }
    }
}
