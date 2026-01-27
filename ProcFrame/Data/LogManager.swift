//
//  LogManager.swift
//  ProcFrame
//
//  Created by yury antony on 08/02/25.
//


import Foundation
import Combine

final class LogManager: ObservableObject, LogStore {
    
    @Published var logs: [String] = []
    
    func addLog(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] \(message)"
        DispatchQueue.main.async {
            self.logs.append(logMessage)
        }
    }

    func clearLogs() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }
}
