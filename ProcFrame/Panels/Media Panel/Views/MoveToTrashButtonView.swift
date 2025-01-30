//
//  MoveToTrashButtonView.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//


import SwiftUI

struct MoveToTrashButtonView: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: moveToTrash) {
            Image(systemName: "trash.fill")
                .font(.system(size: 12))
                .foregroundColor(.red)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .disabled(!isChecked)
        .opacity(isChecked ? 1.0 : 0.5)
    }
    
    private func moveToTrash() {
        print("Moved to trash")
    }
}