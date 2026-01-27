import Foundation

final class TimelineStorage {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let appSupportURL = baseURL ?? fileManager.temporaryDirectory
        let directoryURL = appSupportURL.appendingPathComponent("ProcFrame", isDirectory: true)
        self.fileURL = directoryURL.appendingPathComponent("timeline.json")
    }

    func loadTimeline() -> AnimationTimeline? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(AnimationTimeline.self, from: data)
        } catch {
            return nil
        }
    }

    func saveTimeline(_ timeline: AnimationTimeline) {
        do {
            let directoryURL = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(timeline)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            return
        }
    }
}
