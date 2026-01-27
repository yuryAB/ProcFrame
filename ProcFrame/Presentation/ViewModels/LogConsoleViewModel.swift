import Foundation
import Combine

final class LogConsoleViewModel: ObservableObject {
    private let logStore: any ObservableLogStore
    private var cancellable: AnyCancellable?

    init(logStore: any ObservableLogStore) {
        self.logStore = logStore
        self.cancellable = logStore.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    var logs: [String] {
        logStore.logs
    }

    func clearLogs() {
        logStore.clearLogs()
    }
}
