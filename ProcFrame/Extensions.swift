//
//  Extensions.swift
//  ProcFrame
//
//  Created by yury antony on 25/01/25.
//

import SwiftUI

extension NSImage {
    func resized(to targetSize: CGSize) -> NSImage? {
        let originalSize = self.size
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        let scaleFactor = min(widthRatio, heightRatio)
        let newSize = CGSize(width: originalSize.width * scaleFactor,
                             height: originalSize.height * scaleFactor)
        
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: newSize),
                  from: NSRect(origin: .zero, size: originalSize),
                  operation: .copy,
                  fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}
