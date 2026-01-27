import AppKit

extension ImportedImage {
    var fullImage: NSImage {
        NSImage(data: imageData) ?? NSImage()
    }
}
