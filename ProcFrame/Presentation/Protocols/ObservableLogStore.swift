import Combine

protocol ObservableLogStore: LogStore, ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {}
