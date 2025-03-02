//
//  SKNode+DynamicScaling.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/2/25.
//

import SpriteKit

extension SKNode {
    /**
     Scales the node and all its descendants based on the current zoom level.
     This helps maintain a consistent visual appearance regardless of zoom.
     
     - Parameter zoomScale: The current zoom scale of the parent container
     - Parameter breakpoints: Dictionary of zoom breakpoints and their scale factors
     - Parameter baseSize: Optional base size for shape nodes (default: nil)
     */
    func scaleDynamically(forZoom zoomScale: CGFloat,
                        breakpoints: [CGFloat: CGFloat],
                        baseSize: CGFloat? = nil) {
        // Find the closest breakpoint
        var closestScale: CGFloat = 1.0
        var closestDistance: CGFloat = .infinity
        
        for scale in breakpoints.keys {
            let distance = abs(scale - zoomScale)
            if distance < closestDistance {
                closestDistance = distance
                closestScale = scale
            }
        }
        
        // Get scale factor for this zoom level
        let scaleFactor = breakpoints[closestScale] ?? 1.0
        
        // For shape nodes, update radius or rect size if baseSize is provided
        if let baseSize = baseSize, let shapeNode = self as? SKShapeNode {
            // Recreate the shape with scaled dimensions
            if shapeNode.path?.boundingBox.size.width == shapeNode.path?.boundingBox.size.height {
                // Circle/Ellipse shape
                let newRadius = baseSize * scaleFactor
                shapeNode.path = CGPath(ellipseIn: CGRect(x: -newRadius, y: -newRadius,
                                                       width: newRadius * 2, height: newRadius * 2),
                                     transform: nil)
            } else {
                // Rectangle shape
                let originalSize = shapeNode.path?.boundingBox.size ?? CGSize(width: baseSize * 2, height: baseSize * 2)
                let ratio = originalSize.height / originalSize.width
                let newWidth = baseSize * 2 * scaleFactor
                let newHeight = newWidth * ratio
                
                shapeNode.path = CGPath(rect: CGRect(x: -newWidth/2, y: -newHeight/2,
                                                 width: newWidth, height: newHeight),
                                     transform: nil)
            }
        }
        
        // For sprite nodes, adjust size
        if let spriteNode = self as? SKSpriteNode {
            // Preserve aspect ratio
            let originalSize = spriteNode.size
            let ratio = originalSize.height / originalSize.width
            
            let baseWidth = baseSize ?? originalSize.width
            let newWidth = baseWidth * scaleFactor
            let newHeight = newWidth * ratio
            
            spriteNode.size = CGSize(width: newWidth, height: newHeight)
        }
        
        // For label nodes, adjust font size
        if let labelNode = self as? SKLabelNode {
            let baseFontSize = baseSize ?? labelNode.fontSize
            
            // Scale based on zoom with additional adjustments
            let inverseZoomFactor = 1.0 / zoomScale
            let newFontSize = baseFontSize * scaleFactor * inverseZoomFactor
            
            // Apply font size
            labelNode.fontSize = newFontSize
            
            // Hide text at extreme zoom levels to avoid clutter
            labelNode.isHidden = (zoomScale > 1.8 || zoomScale < 0.6)
        }
        
        // Apply to children recursively
        for child in children {
            if child.name?.contains("_noscale") != true {
                child.scaleDynamically(forZoom: zoomScale, breakpoints: breakpoints, baseSize: baseSize)
            }
        }
    }
}
