import Foundation

final class AppContainer: ObservableObject {
    let store: ProcFrameViewModel
    let logStore: LogManager
    let imageImporter: ImageImportManager
    let spriteSceneAdapter: SpriteSceneAdapter

    let mediaPanelViewModel: MediaPanelViewModel
    let editionPanelViewModel: EditionPanelViewModel
    let actionTimelineViewModel: ActionTimelineViewModel
    let logConsoleViewModel: LogConsoleViewModel

    init() {
        let store = ProcFrameViewModel()
        let logStore = LogManager()
        let imageImporter = ImageImportManager()
        let spriteSceneAdapter = SpriteSceneAdapter(nodeStore: store)

        self.store = store
        self.logStore = logStore
        self.imageImporter = imageImporter
        self.spriteSceneAdapter = spriteSceneAdapter

        self.mediaPanelViewModel = MediaPanelViewModel(store: store, imageImporter: imageImporter)
        self.editionPanelViewModel = EditionPanelViewModel(store: store)
        self.actionTimelineViewModel = ActionTimelineViewModel(store: store)
        self.logConsoleViewModel = LogConsoleViewModel(logStore: logStore)
    }
}
