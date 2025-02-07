//
//  SpriteCanvasView.swift
//  ProcFrame
//
//  Created by yury antony on 28/01/25.
//

import Foundation
import SpriteKit
import SwiftUI

struct SpriteCanvasView: View {
    @EnvironmentObject var viewModel: ProcFrameViewModel
    
    var body: some View {
        CustomSpriteView()
            .frame(width: 700, height: 600)
            .onAppear {
                viewModel.spriteScene.setViewModel(viewModel)
            }
            .onChange(of: viewModel.nodes) {
                viewModel.spriteScene.updateNodes(with: viewModel.nodes)
            }
            .onChange(of: viewModel.selectedNodeID) {
                viewModel.spriteScene.updateHighlight(for: viewModel.selectedNodeID)
            }
    }
}

struct CustomSpriteView: NSViewRepresentable {
    @EnvironmentObject var viewModel: ProcFrameViewModel

    func makeNSView(context: Context) -> SKView {
        let skView = SKView()
        skView.allowsTransparency = true
        skView.presentScene(viewModel.spriteScene)
        return skView
    }

    func updateNSView(_ nsView: SKView, context: Context) { }
}
