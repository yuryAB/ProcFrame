//
//  ImportButtonView.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//


import SwiftUI

struct ImportButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 15))
                .foregroundColor(.white)
                .symbolRenderingMode(.hierarchical)
                .padding(4)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}