//
//  ImportedImage.swift
//  ProcFrame
//
//  Created by yury antony on 31/01/25.
//

import Foundation
import SwiftUI

struct ImportedImage: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let fullImage: NSImage

    static func == (lhs: ImportedImage, rhs: ImportedImage) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
