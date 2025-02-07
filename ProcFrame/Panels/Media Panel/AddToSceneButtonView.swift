//
//  AddToSceneButtonView.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//

import SwiftUI

struct AddToSceneButtonView: View {
    @Binding var isChecked: Bool
    let onAddToScene: () -> Void
    
    var body: some View {
        Button(action: {
            if isChecked {
                onAddToScene()
            }
        }) {
            Image(systemName: "plus.square.on.square")
                .font(.system(size: 12))
                .foregroundStyle(Color.white, Color.blue)
                .symbolRenderingMode(.palette)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .disabled(!isChecked)
        .opacity(isChecked ? 1.0 : 0.5)
    }
}
