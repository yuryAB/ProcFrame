//
//  ProcFrameApp.swift
//  ProcFrame
//
//  Created by yury antony on 24/01/25.
//

import SwiftUI

@main
struct ProcFrameApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
