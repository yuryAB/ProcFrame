import Foundation
import Combine

final class AppContainer: ObservableObject {
    let store: ProcFrameViewModel
    let logStore: LogManager
    let imageImporter: ImageImportManager
    let spriteSceneAdapter: SpriteSceneAdapter
    private let timelineStorage: TimelineStorage
    private var cancellables: Set<AnyCancellable> = []

    let mediaPanelViewModel: MediaPanelViewModel
    let editionPanelViewModel: EditionPanelViewModel
    let actionTimelineViewModel: ActionTimelineViewModel
    let logConsoleViewModel: LogConsoleViewModel

    init() {
        let store = ProcFrameViewModel()
        let logStore = LogManager()
        let imageImporter = ImageImportManager()
        let spriteSceneAdapter = SpriteSceneAdapter(nodeStore: store)
        let timelineStorage = TimelineStorage()

        self.store = store
        self.logStore = logStore
        self.imageImporter = imageImporter
        self.spriteSceneAdapter = spriteSceneAdapter
        self.timelineStorage = timelineStorage

        if let savedTimeline = timelineStorage.loadTimeline() {
            store.timeline = savedTimeline
        }

        self.mediaPanelViewModel = MediaPanelViewModel(store: store, imageImporter: imageImporter)
        self.editionPanelViewModel = EditionPanelViewModel(store: store)
        self.actionTimelineViewModel = ActionTimelineViewModel(store: store)
        self.logConsoleViewModel = LogConsoleViewModel(logStore: logStore)

        store.$timeline
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] timeline in
                self?.timelineStorage.saveTimeline(timeline)
            }
            .store(in: &cancellables)
    }
}
