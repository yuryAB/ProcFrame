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
        outline.zPosition = -1
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
