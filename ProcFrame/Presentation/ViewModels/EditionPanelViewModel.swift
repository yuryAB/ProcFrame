import Foundation
import Combine
import SwiftUI

final class EditionPanelViewModel: ObservableObject {
    private let store: ProcFrameViewModel
    private var cancellable: AnyCancellable?

    init(store: ProcFrameViewModel) {
        self.store = store
        self.cancellable = store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    var editionType: EditionType {
        get { store.editionType }
        set { store.editionType = newValue }
    }

    var notificationMessage: String? {
        store.notificationMessage
    }

    var notificationType: ProcFrameViewModel.NotificationType? {
        store.notificationType
    }

    func updateZPosition(for nodeID: UUID, to newValue: CGFloat) {
        store.setNodeZPosition(nodeID: nodeID, to: newValue)
    }

    func selectedProcNodeBinding() -> Binding<ProcNode>? {
        guard let selectedID = store.selectedNodeID,
              let index = store.nodes.firstIndex(where: { $0.id == selectedID }) else { return nil }
        return Binding<ProcNode>(
            get: { self.store.nodes[index] },
            set: { self.store.nodes[index] = $0 }
        )
    }
}
