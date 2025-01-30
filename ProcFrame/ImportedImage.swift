//
//  ImportedImage.swift
//  ProcFrame
//
//  Created by yury antony on 25/01/25.
//

import SwiftUI

struct ImportedImage: Identifiable {
    let id = UUID()
    let name: String
    let fullImage: NSImage?
    let thumbnail: NSImage?
}
