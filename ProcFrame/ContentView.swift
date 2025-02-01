//
//  ContentView.swift
//  ProcFrame
//
//  Created by yury antony on 24/01/25.
//

import Foundation
import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var spriteScene = CanvaSpriteScene(size: CGSize(width: 650, height: 550))

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 2) {
                PanelView(color: Color(nsColor: .controlColor))
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 0) {
                    MediaPanelView(
                        color: Color(nsColor: .controlColor),
                        onAddToScene: { selectedImages in
                            spriteScene.addImagesAsNodes(images: selectedImages)
                        }
                    )
                    .frame(width: 160)

                    Spacer()
                    
                    SpriteCanvasView(spriteScene: spriteScene)
                    
                    Spacer()

                    PanelView(color: Color(nsColor: .controlColor))
                        .frame(width: 300)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)

                PanelView(color: Color(nsColor: .controlColor))
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: .infinity)
            .padding()
        }
    }
}

struct PanelView: View {
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .cornerRadius(8)
            .shadow(radius: 4)
    }
}

