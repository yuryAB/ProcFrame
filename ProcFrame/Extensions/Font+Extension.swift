//
//  Font+Extension.swift
//  ProcFrame
//
//  Created by yury antony on 18/03/25.
//


import SwiftUI

extension Font {
    static let thinInfo = Font.custom("Inter", size: 15, relativeTo: .body).weight(.thin).italic()
}

extension Color {
    static let mainDark = Color(nsColor: .controlBackgroundColor)
}
