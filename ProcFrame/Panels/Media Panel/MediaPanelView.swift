//
//  MediaPanelView.swift
//  ProcFrame
//
//  Created by yury antony on 25/01/25.
//

import Foundation
import SwiftUI

struct MediaPanelView: View {
    let color: Color
    @State private var images: [ImportedImage] = []
    @State private var selectedImages: Set<UUID> = []
    
    var onAddToScene: (([ImportedImage]) -> Void)?
    
    var body: some View {
        VStack(spacing: 3) {
            Button(action: importImages) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .symbolRenderingMode(.hierarchical)
                    .padding(4)
                    .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            
            List {
                ForEach(images) { image in
                    SelectableRow(
                        image: image,
                        isSelected: selectedImages.contains(image.id)
                    ) {
                        toggleSelection(for: image.id)
                    }
                }
            }
            .cornerRadius(8)
            
            HStack {
                SelectAllButton(
                    isChecked: Binding(
                        get: { selectedImages.count == images.count && !images.isEmpty },
                        set: { isChecked in toggleSelectAll(isChecked) }
                    )
                )
                .disabled(images.isEmpty)
                
                AddToSceneButton(isChecked: .constant(!selectedImages.isEmpty)) {
                    let selected = images.filter { selectedImages.contains($0.id) }
                    onAddToScene?(selected)
                }
                .disabled(selectedImages.isEmpty)
                
                MoveToTrashButton(isChecked: .constant(!selectedImages.isEmpty))
                .disabled(selectedImages.isEmpty)
            }
            .frame(maxWidth: .infinity)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
        }
        .padding(4)
        .background(color)
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
        if isChecked {
            selectedImages = Set(images.map { $0.id })
        } else {
            selectedImages.removeAll()
        }
    }
    
    private func importImages() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff]
        panel.allowsMultipleSelection = true
        
        if panel.runModal() == .OK {
            for url in panel.urls {
                if let fullImage = NSImage(contentsOf: url) {
                    let thumbnail = generateThumbnail(from: fullImage)
                    let newImage = ImportedImage(name: url.lastPathComponent, fullImage: fullImage, thumbnail: thumbnail)
                    images.append(newImage)
                }
            }
        }
    }
    
    private func generateThumbnail(from image: NSImage) -> NSImage? {
        let size = CGSize(width: 25, height: 25)
        return image.resized(to: size)
    }
}

struct SelectableRow: View {
    let image: ImportedImage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            if let nsImage = image.thumbnail {
                Image(nsImage: nsImage)
                    .frame(width: 25, height: 25)
                    .cornerRadius(4)
            }
            Text(image.name)
                .lineLimit(2)
                .truncationMode(.tail)
                .font(.system(size: 11))
        }
        .onTapGesture(perform: onTap)
        .background(isSelected ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear)
    }
}

struct SelectAllButton: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: toggleChecked) {
            Image(systemName: "checklist.checked")
                .font(.system(size: 12))
                .foregroundColor(isChecked ? .blue : .white)
                .symbolRenderingMode(.monochrome)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private func toggleChecked() {
        isChecked.toggle()
    }
}

struct AddToSceneButton: View {
    @Binding var isChecked: Bool
    let onAddToScene: () -> Void
    
    var body: some View {
        Button(action: {
            if isChecked {
                onAddToScene()
            }
        }) {
            Image(systemName: "plus.square.on.square")
                .font(.system(size: 12))
                .foregroundStyle(Color.white, Color.blue)
                .symbolRenderingMode(.palette)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .disabled(!isChecked)
        .opacity(isChecked ? 1.0 : 0.5)
    }
}

struct MoveToTrashButton: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: moveToTrash) {
            Image(systemName: "trash.fill")
                .font(.system(size: 12))
                .foregroundColor(.red)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .disabled(!isChecked)
        .opacity(isChecked ? 1.0 : 0.5)
    }
    
    private func moveToTrash() {
        print("Moved to trash")
    }
}
