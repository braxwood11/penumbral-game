//
//  EnhancedCelestialRealmScene+NodeInteraction.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/4/25.
//

import SpriteKit

// Extension to handle node interaction screens
extension EnhancedCelestialRealmScene {
    
    internal func showNodeInteractionScreen(for nodeID: String) {
        // Get the node data
        guard let node = celestialRealm.nodes.first(where: { $0.id == nodeID }) else { return }
        
        // Create and show the appropriate screen based on node type
        let screen: NodeInteractionScreen
        
        switch node.nodeType {
        case .battle:
            screen = BattleNodeScreen(node: node, size: size, parentScene: self)
            
        case .cardRefinery:
            screen = RefineryNodeScreen(node: node, size: size, parentScene: self)
            
        case .narrative:
            screen = NarrativeNodeScreen(node: node, size: size, parentScene: self)
            
        case .shop:
            screen = ShopNodeScreen(node: node, size: size, parentScene: self)
            
        case .mystery:
            screen = MysteryNodeScreen(node: node, size: size, parentScene: self)
            
        case .nexus:
            screen = NexusNodeScreen(node: node, size: size, parentScene: self)
        }
        
        // Add screen to scene with z-position to be above everything else
        screen.zPosition = 2000
        addChild(screen)
    }
    
    // Handle touches for node interaction screens
    internal func handleNodeInteractionTouch(_ location: CGPoint) -> Bool {
        // Check all potential node interaction screens
        for child in children where child is NodeInteractionScreen {
            if let screen = child as? NodeInteractionScreen {
                if screen.handleTouch(at: location) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func handleTouchesForNodeInteractions(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let touch = touches.first else { return false }
        let location = touch.location(in: self)
        
        // Check if any interaction screens should handle this touch
        return handleNodeInteractionTouch(location)
    }
}
