//
//  SelectAllButtonView.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//

import SwiftUI

struct SelectAllButtonView: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: toggleChecked) {
            Image(systemName: "checklist.checked")
                .font(.system(size: 12))
                .foregroundColor(isChecked ? .blue : .white)
                .symbolRenderingMode(.monochrome)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private func toggleChecked() {
        isChecked.toggle()
    }
}
