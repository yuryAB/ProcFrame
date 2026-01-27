import Foundation
import Combine
import CoreGraphics

final class MediaPanelViewModel: ObservableObject {
    private let store: ProcFrameViewModel
    private let imageImporter: ImageImporting
    private var cancellable: AnyCancellable?

    init(store: ProcFrameViewModel, imageImporter: ImageImporting) {
        self.store = store
        self.imageImporter = imageImporter
        self.cancellable = store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    var nodes: [ProcNode] {
        store.nodes
    }

    var selectedNodeID: UUID? {
        get { store.selectedNodeID }
        set { store.selectedNodeID = newValue }
    }

    var isStructuralChange: Bool {
        store.isStructuralChange
    }

    func toggleSelectAll(_ isChecked: Bool) {
        store.selectedNodeID = isChecked ? store.nodes.first?.id : nil
    }

    func importImages() {
        imageImporter.importImages { [weak self] newImages in
            guard let self else { return }
            let maxZPosition = self.store.nodes.map { $0.zPosition }.max() ?? 0
            let newNodes = newImages.enumerated().map { index, image in
                ProcNode(image: image, zPosition: maxZPosition + CGFloat(index) + 1)
            }
            self.store.nodes.append(contentsOf: newNodes)
            self.store.reorderNodesByZPosition()
        }
    }
}
