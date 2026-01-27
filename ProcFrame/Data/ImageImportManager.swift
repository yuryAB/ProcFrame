//
//  ImageImportManager.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//

import AppKit

final class ImageImportManager: ImageImporting {
    func importImages(completion: @escaping ([ImportedImage]) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff]
        panel.allowsMultipleSelection = true

        if panel.runModal() == .OK {
            let images = panel.urls.compactMap { url -> ImportedImage? in
                guard let fullImage = NSImage(contentsOf: url),
                      let imageData = fullImage.tiffRepresentation else { return nil }
                return ImportedImage(
                    name: url.lastPathComponent,
                    imageData: imageData
                )
            }
            completion(images)
        }
    }
}
