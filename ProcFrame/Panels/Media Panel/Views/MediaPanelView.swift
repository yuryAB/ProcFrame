//
//  MediaPanelView.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//

import SwiftUI

struct MediaPanelView: View {
    let color: Color
    @State private var images: [ImportedImage] = []
    @State private var selectedImages: Set<UUID> = []
    
    var onAddToScene: (([ImportedImage]) -> Void)?
    
    var body: some View {
        VStack(spacing: 3) {
            ImportButtonView(action: importImages)
            imageList()
            actionButtons()
        }
        .padding(4)
        .background(color)
        .cornerRadius(8)
    }
    
    private func imageList() -> some View {
        List {
            ForEach(images) { image in
                SelectableRowView(
                    image: image,
                    isSelected: selectedImages.contains(image.id),
                    onTap: { toggleSelection(for: image.id) }
                )
            }
        }
        .cornerRadius(8)
    }
    
    private func actionButtons() -> some View {
        HStack {
            SelectAllButtonView(
                isChecked: Binding(
                    get: { selectedImages.count == images.count && !images.isEmpty },
                    set: { isChecked in toggleSelectAll(isChecked) }
                )
            )
            .disabled(images.isEmpty)
            
            MoveToTrashButtonView(isChecked: .constant(!selectedImages.isEmpty))
                .disabled(selectedImages.isEmpty)
        }
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private func toggleSelection(for id: UUID) {
        if selectedImages.contains(id) {
            selectedImages.remove(id)
        } else {
            selectedImages.insert(id)
        }
    }
    
    private func toggleSelectAll(_ isChecked: Bool) {
        selectedImages = isChecked ? Set(images.map { $0.id }) : []
    }
    
    private func importImages() {
        ImageImportManager.importImages { newImages in
            images.append(contentsOf: newImages)
            onAddToScene?(newImages)
        }
    }
}
