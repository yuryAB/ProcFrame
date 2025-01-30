struct ImportedImage: Identifiable {
    let id = UUID()
    let name: String
    let thumbnail: NSImage?
}