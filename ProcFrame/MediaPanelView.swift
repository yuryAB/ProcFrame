struct MediaPanelView: View {
    let color: Color
    @State private var images: [ImportedImage] = []

    var body: some View {
        VStack(spacing: 10) {
            Button(action: importImages) {
                Text("Import Images")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }

            List(images) { image in
                HStack {
                    if let nsImage = image.thumbnail {
                        Image(nsImage: nsImage)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(4)
                            .shadow(radius: 2)
                    }

                    Text(image.name)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .background(Color.clear)
        }
        .padding()
        .background(color)
        .cornerRadius(8)
        .shadow(radius: 4)
    }

    private func importImages() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff]
        panel.allowsMultipleSelection = true

        if panel.runModal() == .OK {
            for url in panel.urls {
                if let thumbnail = generateThumbnail(from: url) {
                    let newImage = ImportedImage(name: url.lastPathComponent, thumbnail: thumbnail)
                    images.append(newImage)
                }
            }
        }
    }

    // Gera uma miniatura de uma imagem a partir de uma URL
    private func generateThumbnail(from url: URL) -> NSImage? {
        guard let nsImage = NSImage(contentsOf: url) else { return nil }
        let size = CGSize(width: 50, height: 50) // Tamanho da miniatura
        return nsImage.resized(to: size)
    }
}

// Modelo para representar imagens importadas
struct ImportedImage: Identifiable {
    let id = UUID()
    let name: String
    let thumbnail: NSImage?
}

extension NSImage {
    // Redimensiona a NSImage para o tamanho especificado
    func resized(to size: CGSize) -> NSImage? {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: size),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}