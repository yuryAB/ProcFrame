//
//  SpriteKitPanelView.swift
//  ProcFrame
//
//  Created by yury antony on 28/01/25.
//

import SwiftUI
import SpriteKit

class CustomSpriteScene: SKScene {
    private var cameraNode = SKCameraNode()
    private var inputLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        backgroundColor = .white

        if cameraNode.parent == nil {
            cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
            addChild(cameraNode)
            camera = cameraNode
            cameraNode.setScale(1.0)
        }

        inputLabel = SKLabelNode(fontNamed: "Helvetica")
        inputLabel.fontSize = 20
        inputLabel.fontColor = .black
        inputLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        inputLabel.text = "Pressione algo..."
        addChild(inputLabel)
    }

    override func keyDown(with event: NSEvent) {
        let keyPressed = event.charactersIgnoringModifiers ?? "Unknown Key"
        print("Tecla pressionada: \(keyPressed)")
        updateLabel(with: "Tecla: \(keyPressed)")
    }

    override func keyUp(with event: NSEvent) {
        let keyReleased = event.charactersIgnoringModifiers ?? "Unknown Key"
        print("Tecla solta: \(keyReleased)")
        updateLabel(with: "Soltou: \(keyReleased)")
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        print("Clique detectado em: \(location)")
        updateLabel(with: "Clique em: \(Int(location.x)), \(Int(location.y))")

        // Criar um círculo visual no local do clique
        let clickIndicator = SKShapeNode(circleOfRadius: 10)
        clickIndicator.position = location
        clickIndicator.fillColor = .red
        clickIndicator.alpha = 0.7
        addChild(clickIndicator)

        // Fazer o indicador desaparecer após um tempo
        clickIndicator.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }

    override func rightMouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        print("Clique direito detectado em: \(location)")
        updateLabel(with: "Clique Direito em: \(Int(location.x)), \(Int(location.y))")
    }

    override func mouseMoved(with event: NSEvent) {
        let location = event.location(in: self)
        updateLabel(with: "Mouse em: \(Int(location.x)), \(Int(location.y))")
    }

    override func scrollWheel(with event: NSEvent) {
        let direction = event.scrollingDeltaY > 0 ? "🔼 Cima" : "🔽 Baixo"
        print("Scroll detectado: \(direction)")
        updateLabel(with: "Scroll: \(direction)")
    }
    
    func simulateScroll(deltaY: CGFloat) {
        print("Teste")
        guard let cameraNode = self.camera else { return }

        let zoomDelta = deltaY * -0.01
        let newScale = cameraNode.xScale + zoomDelta

        let minScale: CGFloat = 0.5
        let maxScale: CGFloat = 2.5

        cameraNode.setScale(max(min(newScale, maxScale), minScale))
    }

    private func updateLabel(with text: String) {
        inputLabel.text = text
    }

    func addImagesAsNodes(images: [ImportedImage]) {
        for (index, image) in images.enumerated() {
            guard let fullImage = image.fullImage else { continue }
            let texture = SKTexture(image: fullImage)
            let spriteNode = SKSpriteNode(texture: texture)

            spriteNode.position = CGPoint(x: CGFloat(50 + index * 50), y: size.height / 2)
            addChild(spriteNode)
        }
    }
}

struct ScrollableView: NSViewRepresentable {
    var onScroll: (CGFloat) -> Void // Callback para passar o scroll detectado

    func makeNSView(context: Context) -> NSView {
        let view = CustomNSView()
        view.onScroll = onScroll
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    class CustomNSView: NSView {
        var onScroll: ((CGFloat) -> Void)?

        override var acceptsFirstResponder: Bool { true }

        override func scrollWheel(with event: NSEvent) {
            onScroll?(event.scrollingDeltaY)
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0.0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
