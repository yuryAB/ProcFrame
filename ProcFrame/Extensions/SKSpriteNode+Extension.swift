//
//  Extensions.swift
//  ProcFrame
//
//  Created by yury antony on 25/01/25.
//

import SpriteKit

extension SKSpriteNode {
    func drawOutline(color: SKColor = .magenta, width: CGFloat = 4) {
        self.childNode(withName: "outline")?.removeFromParent()
        
        let outline = SKShapeNode(rectOf: CGSize(width: self.size.width + width * 1.1,
                                                 height: self.size.height + width * 1.1),
                                  cornerRadius: 5)
        outline.strokeColor = color
        outline.lineWidth = width
        outline.zPosition = 50
        outline.name = "outline"
        outline.isUserInteractionEnabled = false
        
        let offsetX = (0.5 - self.anchorPoint.x) * self.size.width
        let offsetY = (0.5 - self.anchorPoint.y) * self.size.height
        outline.position = CGPoint(x: offsetX, y: offsetY)
        
        self.addChild(outline)
    }
    
    func removeOutline() {
        self.childNode(withName: "outline")?.removeFromParent()
    }
    
    func isPointVisible(_ point: CGPoint) -> Bool {
        guard let texture = self.texture else { return false }
        
        let nodePoint = convert(point, from: scene!)

        let texturePoint = CGPoint(
            x: (nodePoint.x + size.width * anchorPoint.x) / size.width,
            y: (nodePoint.y + size.height * anchorPoint.y) / size.height
        )
        
        return texture.hasAlpha(at: texturePoint)
    }
    
    func parentingLines() {
        guard !children.isEmpty else { return }
        
        childNode(withName: "parentingLines")?.removeFromParent()
        
        let lineContainer = SKNode()
        lineContainer.name = "parentingLines"
        
        for child in children {
            guard let childNode = child as? SKSpriteNode,
                  childNode.isEditionNode() else { continue }

            let startPoint = CGPoint.zero
            let endPoint = childNode.position
            let path = CGMutablePath()
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)

            let lineNode = SKShapeNode(path: path)
            lineNode.strokeColor = .black
            lineNode.lineWidth = 10
            lineNode.zPosition = 20

            lineContainer.addChild(lineNode)
        }
        
        self.addChild(lineContainer)
    }

    func removeParentingLines() {
        self.childNode(withName: "parentingLines")?.removeFromParent()
    }
    
    func isEditionNode() -> Bool {
        return name?.contains("-EDT-") ?? false
    }
}

extension SKTexture {
    func hasAlpha(at point: CGPoint) -> Bool {
        let cgImage = self.cgImage()

        let width = cgImage.width
        let height = cgImage.height

        let x = Int(round(CGFloat(width) * point.x))
        let y = Int(round(CGFloat(height) * point.y))

        guard x >= 0, x < width, y >= 0, y < height else { return false }

        var pixelData = [UInt8](repeating: 0, count: 4)

        _ = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        context?.draw(cgImage, in: CGRect(x: -x, y: -y, width: width, height: height))

        return pixelData[3] > 20
    }
}
