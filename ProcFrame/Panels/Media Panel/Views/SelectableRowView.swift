//
//  SelectableRowView.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//


import SwiftUI

struct SelectableRowView: View {
    let image: ImportedImage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            if let nsImage = image.thumbnail {
                Image(nsImage: nsImage)
                    .frame(width: 25, height: 25)
                    .cornerRadius(4)
            }
            Text(image.name)
                .lineLimit(2)
                .truncationMode(.tail)
                .font(.system(size: 11))
        }
        .onTapGesture(perform: onTap)
        .background(isSelected ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear)
    }
}