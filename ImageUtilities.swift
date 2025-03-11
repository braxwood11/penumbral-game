//
//  ImageUtilities.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import UIKit
import SpriteKit

class ImageUtilities {
    static func createPlaceholderImage(name: String, color: SKColor) -> SKTexture {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Background
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Border
            UIColor.white.setStroke()
            context.stroke(CGRect(origin: .zero, size: size))
            
            // Text
            let text = name as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attributes)
            let textPoint = CGPoint(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2
            )
            text.draw(at: textPoint, withAttributes: attributes)
        }
        
        return SKTexture(image: image)
    }
    
    static func getTexture(for name: String) -> SKTexture {
        // Try to load from Assets
        if let texture = tryLoadTexture(named: name) {
            return texture
        }
        
        // Generate a placeholder if not found
        let colors: [String: SKColor] = [
            "path_icon": .blue,
            "jump_icon": .purple,
            "reveal_icon": .green,
            "phase_icon": .orange,
            "special_icon": .red,
            "battle-icon": .red,
            "forge-icon": .brown,
            "narrative-icon": .cyan,
            "shop-icon": .yellow,
            "mystery-icon": .purple,
            "nexus-icon": .white
        ]
        
        let color = colors[name] ?? .gray
        return createPlaceholderImage(name: name, color: color)
    }
    
    private static func tryLoadTexture(named name: String) -> SKTexture? {
        // Try to load from Images.xcassets
        if let image = UIImage(named: name) {
            return SKTexture(image: image)
        }
        return nil
    }
}
