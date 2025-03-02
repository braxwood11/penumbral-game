//
//  AnimationHelper.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/2/25.
//

import SpriteKit

class AnimationHelper {
    /**
     Creates a smooth elastic zoom effect for a node
     
     - Parameter node: The node to zoom
     - Parameter to: Target scale
     - Parameter duration: Animation duration
     - Parameter completion: Optional completion handler
     */
    static func elasticZoom(node: SKNode, to scale: CGFloat, duration: TimeInterval, completion: (() -> Void)? = nil) {
        // Create a sequence with overshoot and settle
        let overshootScale = scale * 1.1
        let actions = SKAction.sequence([
            SKAction.scale(to: overshootScale, duration: duration * 0.6),
            SKAction.scale(to: scale, duration: duration * 0.4)
        ])
        
        // Apply easing for smoother animation
        actions.timingMode = .easeInEaseOut
        
        // Run the action with optional completion
        if let completion = completion {
            node.run(actions) {
                completion()
            }
        } else {
            node.run(actions)
        }
    }
    
    /**
     Creates a smooth pan animation with easing
     
     - Parameter node: The node to move
     - Parameter to: Target position
     - Parameter duration: Animation duration
     - Parameter completion: Optional completion handler
     */
    static func smoothPan(node: SKNode, to position: CGPoint, duration: TimeInterval, completion: (() -> Void)? = nil) {
        let action = SKAction.move(to: position, duration: duration)
        action.timingMode = .easeInEaseOut
        
        if let completion = completion {
            node.run(action) {
                completion()
            }
        } else {
            node.run(action)
        }
    }
    
    /**
     Creates a bouncy appearance animation for a node
     
     - Parameter node: The node to animate
     - Parameter delay: Delay before animation starts
     - Parameter duration: Animation duration
     */
    static func bounceIn(node: SKNode, delay: TimeInterval = 0, duration: TimeInterval = 0.5) {
        // Save original scale
        let originalScale = node.xScale
        
        // Set initial state
        node.setScale(0.01)
        node.alpha = 0
        
        // Create bounce animation
        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: duration * 0.5),
            SKAction.sequence([
                SKAction.scale(to: originalScale * 1.1, duration: duration * 0.6),
                SKAction.scale(to: originalScale, duration: duration * 0.4)
            ])
        ])
        
        // Add delay if needed
        if delay > 0 {
            node.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                appear
            ]))
        } else {
            node.run(appear)
        }
    }
    
    /**
     Creates a pulsing highlight effect around a node
     
     - Parameter node: The node to highlight
     - Parameter color: The highlight color
     - Parameter radius: The highlight radius
     - Parameter duration: Pulse duration
     - Returns: The created highlight node
     */
    static func createPulsingHighlight(around node: SKNode, color: SKColor, radius: CGFloat, duration: TimeInterval = 1.5) -> SKNode {
        let highlight = SKShapeNode(circleOfRadius: radius)
        highlight.fillColor = .clear
        highlight.strokeColor = color
        highlight.lineWidth = 2
        highlight.position = .zero
        highlight.zPosition = -1
        highlight.alpha = 0.8
        highlight.name = "highlight_noscale" // Prevent auto-scaling
        
        // Create pulsing animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: duration/2),
            SKAction.fadeAlpha(to: 0.8, duration: duration/2)
        ])
        
        highlight.run(SKAction.repeatForever(pulse))
        node.addChild(highlight)
        
        return highlight
    }
    
    /**
     Creates a particle trail effect following a node
     
     - Parameter following: The node to follow
     - Parameter color: Particle color
     - Parameter size: Particle size range
     - Parameter birthRate: Particles per second
     - Parameter lifetime: How long particles remain visible
     - Returns: The emitter node
     */
    static func createParticleTrail(following node: SKNode, color: SKColor, size: ClosedRange<CGFloat> = 2...4,
                                  birthRate: Double = 10, lifetime: Double = 1.0) -> SKNode {
        // Create custom emitter since we don't have SpriteKit particle files
        let emitter = SKNode()
        emitter.name = "particleTrail_noscale"
        
        // Set up timer to emit particles
        let wait = SKAction.wait(forDuration: 1.0 / birthRate)
        let emit = SKAction.run {
            // Create a single particle
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: size))
            particle.fillColor = color
            particle.strokeColor = .clear
            
            // Random offset from center
            let offset = CGFloat.random(in: -2...2)
            particle.position = CGPoint(x: offset, y: offset)
            
            // Fade out and remove
            let fade = SKAction.sequence([
                SKAction.wait(forDuration: lifetime * 0.2),
                SKAction.fadeOut(withDuration: lifetime * 0.8),
                SKAction.removeFromParent()
            ])
            
            particle.run(fade)
            emitter.addChild(particle)
        }
        
        // Run continuous emission
        emitter.run(SKAction.repeatForever(SKAction.sequence([wait, emit])))
        
        // Add to the node
        node.addChild(emitter)
        
        return emitter
    }
}
