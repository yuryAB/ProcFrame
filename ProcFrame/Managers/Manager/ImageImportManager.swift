//
//  ImageImportManager.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//

import AppKit

class ImageImportManager {
    static func importImages(completion: @escaping ([ImportedImage]) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff]
        panel.allowsMultipleSelection = true

        if panel.runModal() == .OK {
            let images = panel.urls.compactMap { url -> ImportedImage? in
                guard let fullImage = NSImage(contentsOf: url) else { return nil }
                return ImportedImage(
                    name: url.lastPathComponent,
                    fullImage: fullImage
                )
            }
            completion(images)
        }
    }
}
