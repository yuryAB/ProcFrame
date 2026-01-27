import Foundation

protocol LogStore: AnyObject {
    var logs: [String] { get }
    func addLog(_ message: String)
    func clearLogs()
}
