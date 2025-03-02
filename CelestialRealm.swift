//
//  CelestialRealm.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import Foundation
import SpriteKit

// The world manager that controls the state of the navigation
class CelestialRealm {
    // All nodes in the world
    var nodes: [WorldNode] = []
    
    // Current realm phase
    private(set) var currentPhase: Realm = .dawn
    
    // Player's current position
    private(set) var currentNodeID: String
    
    // Initialize the world
    init(startNodeID: String) {
        self.currentNodeID = startNodeID
        generateWorld()
    }
    
    // Generate the initial world structure
    private func generateWorld() {
        nodes = createSampleWorldNodes()
        updateAccessibility()
    }
    
    private func createSampleWorldNodes() -> [WorldNode] {
        var nodes: [WorldNode] = []
        
        // Constants for node positioning - reduced from original values
        let dawnRadius: CGFloat = 100  // Was 150
        let duskRadius: CGFloat = 200  // Was 300
        let nightRadius: CGFloat = 300  // Was 450
        
        // Create nexus (central node)
        let nexus = WorldNode(
            id: "nexus",
            name: "Nexus",
            realm: .dawn,
            nodeType: .nexus,
            position: CGPoint.zero,
            isRevealed: true,
            isAccessible: true,
            isVisited: true
        )
        nodes.append(nexus)
        
        // Create Dawn realm nodes (in a circle around nexus)
        // Increase from 5 to 8 nodes
        for i in 0..<8 {
            let angle = CGFloat(i) * (2 * .pi / 8)
            let position = CGPoint(
                x: cos(angle) * dawnRadius,
                y: sin(angle) * dawnRadius
            )
            
            let nodeType: NodeType
            switch i % 8 {
            case 0: nodeType = .narrative(dialogueID: "dawn_story_\(i)", character: "Luminary")
            case 1: nodeType = .cardRefinery(options: [])
            case 2: nodeType = .battle(difficulty: 1, enemyType: "Dawn Guardian")
            case 3: nodeType = .shop(inventory: [])
            case 4: nodeType = .mystery
            case 5: nodeType = .battle(difficulty: 2, enemyType: "Dawn Sentinel")
            case 6: nodeType = .cardRefinery(options: [])
            case 7: nodeType = .narrative(dialogueID: "dawn_lore_\(i)", character: "Dawn Oracle")
            default: nodeType = .mystery
            }
            
            let node = WorldNode(
                id: "dawn_\(i)",
                name: "Dawn \(i+1)",
                realm: .dawn,
                nodeType: nodeType,
                position: position,
                isRevealed: true,
                isAccessible: true
            )
            nodes.append(node)
        }
        
        // Create Dusk realm nodes - increase from 8 to 12
        for i in 0..<12 {
            let angle = CGFloat(i) * (2 * .pi / 12)
            let position = CGPoint(
                x: cos(angle) * duskRadius,
                y: sin(angle) * duskRadius
            )
            
            let nodeType: NodeType
            switch i % 6 {
            case 0: nodeType = .battle(difficulty: 2, enemyType: "Dusk Hunter")
            case 1: nodeType = .cardRefinery(options: [])
            case 2: nodeType = .narrative(dialogueID: "dusk_story_\(i)", character: "Twilight Sage")
            case 3: nodeType = .shop(inventory: [])
            case 4: nodeType = .mystery
            case 5: nodeType = .battle(difficulty: 3, enemyType: "Twilight Warrior")
            default: nodeType = .mystery
            }
            
            let node = WorldNode(
                id: "dusk_\(i)",
                name: "Dusk \(i+1)",
                realm: .dusk,
                nodeType: nodeType,
                position: position,
                isRevealed: i < 6, // Only reveal half the dusk nodes initially
                isAccessible: false // Dusk nodes start inaccessible
            )
            nodes.append(node)
        }
        
        // Create Night realm nodes - increase from 12 to 16
        for i in 0..<16 {
            let angle = CGFloat(i) * (2 * .pi / 16)
            let position = CGPoint(
                x: cos(angle) * nightRadius,
                y: sin(angle) * nightRadius
            )
            
            let nodeType: NodeType
            switch i % 8 {
            case 0: nodeType = .battle(difficulty: 3, enemyType: "Night Stalker")
            case 1: nodeType = .cardRefinery(options: [])
            case 2: nodeType = .narrative(dialogueID: "night_story_\(i)", character: "Shadow Oracle")
            case 3: nodeType = .shop(inventory: [])
            case 4: nodeType = .mystery
            case 5: nodeType = .battle(difficulty: 4, enemyType: "Void Walker")
            case 6: nodeType = .narrative(dialogueID: "night_lore_\(i)", character: "Ancient One")
            case 7: nodeType = .mystery
            default: nodeType = .mystery
            }
            
            let node = WorldNode(
                id: "night_\(i)",
                name: "Night \(i+1)",
                realm: .night,
                nodeType: nodeType,
                position: position,
                isRevealed: i < 3, // Only reveal a few night nodes
                isAccessible: false // Night nodes start inaccessible
            )
            nodes.append(node)
        }
        
        // Create more complex connections
        
        // 1. Nexus connects to all Dawn nodes
        var nexusNode = nodes[0]
        nexusNode.connections = nodes.filter { $0.realm == .dawn }.map { $0.id }
        nodes[0] = nexusNode
        
        // 2. Each Dawn node connects to neighboring Dawn nodes and to several Dusk nodes
        for i in 1...8 {
            if i <= nodes.count && nodes[i].realm == .dawn {
                var dawnNode = nodes[i]
                
                // Connect to neighboring Dawn nodes
                let prevIndex = (i == 1) ? 8 : i - 1
                let nextIndex = (i == 8) ? 1 : i + 1
                
                // Add Dawn connections (creating a ring in Dawn realm)
                var dawnConnections = [String]()
                dawnConnections.append("dawn_\(prevIndex-1)")
                dawnConnections.append("dawn_\(nextIndex-1)")
                
                // Connect to Dusk nodes based on position
                let duskNodesStartIndex = 9  // Index of first Dusk node
                let duskConnections = [
                    (i - 1) % 12,  // Direct outward
                    (i + 1) % 12   // Slightly offset
                ]
                
                for duskIndex in duskConnections {
                    dawnConnections.append("dusk_\(duskIndex)")
                }
                
                dawnNode.connections = dawnConnections
                nodes[i] = dawnNode
            }
        }
        
        // 3. Dusk nodes connect to neighboring Dusk nodes and to Night nodes
        let duskStartIndex = 9   // First dusk node index
        let duskCount = 12       // Number of dusk nodes
        for i in 0..<duskCount {
            let nodeIndex = duskStartIndex + i
            if nodeIndex < nodes.count && nodes[nodeIndex].realm == .dusk {
                var duskNode = nodes[nodeIndex]
                
                // Connect to neighboring Dusk nodes
                let prevDusk = "dusk_\((i == 0) ? duskCount - 1 : i - 1)"
                let nextDusk = "dusk_\((i == duskCount - 1) ? 0 : i + 1)"
                
                // Connect to Night nodes
                // Each Dusk node connects to 2 Night nodes
                let nightConnections = [
                    "night_\(i % 16)",
                    "night_\((i + 1) % 16)"
                ]
                
                duskNode.connections = [prevDusk, nextDusk] + nightConnections
                nodes[nodeIndex] = duskNode
            }
        }
        
        // 4. Night nodes connect to neighboring Night nodes and occasionally back to Dusk
        let nightStartIndex = duskStartIndex + duskCount  // First night node index
        let nightCount = 16  // Number of night nodes
        for i in 0..<nightCount {
            let nodeIndex = nightStartIndex + i
            if nodeIndex < nodes.count && nodes[nodeIndex].realm == .night {
                var nightNode = nodes[nodeIndex]
                
                // Connect to neighboring Night nodes
                let prevNight = "night_\((i == 0) ? nightCount - 1 : i - 1)"
                let nextNight = "night_\((i == nightCount - 1) ? 0 : i + 1)"
                
                // Some night nodes connect back to dusk for looping
                var nightConnections = [prevNight, nextNight]
                if i % 4 == 0 {  // Every fourth night node
                    nightConnections.append("dusk_\(i % 12)")
                }
                
                nightNode.connections = nightConnections
                nodes[nodeIndex] = nightNode
            }
        }
        
        return nodes
    }
    
    // Shift to the next realm phase
    func shiftPhase() {
        let allRealms = Realm.allCases
        let currentIndex = allRealms.firstIndex(of: currentPhase)!
        let nextIndex = (currentIndex + 1) % allRealms.count
        currentPhase = allRealms[nextIndex]
        
        // Update node accessibility based on new phase
        updateAccessibility()
    }
    
    // Update which nodes are accessible in the current phase
    func updateAccessibility() {
        for i in 0..<nodes.count {
            var node = nodes[i]
            node.isAccessible = node.realm == currentPhase || node.isNexus
            nodes[i] = node
        }
    }
    
    // Calculate path distance between two nodes
    func calculatePathDistance(from sourceID: String, to targetID: String) -> Int {
        // This would perform a breadth-first search to find the shortest path
        // For now, a simplified implementation
        
        // Get the nodes
        guard let sourceNode = nodes.first(where: { $0.id == sourceID }),
              let targetNode = nodes.first(where: { $0.id == targetID }) else {
            return Int.max
        }
        
        // Direct distance for prototype
        let dx = targetNode.position.x - sourceNode.position.x
        let dy = targetNode.position.y - sourceNode.position.y
        let distance = sqrt(dx*dx + dy*dy)
        
        // Convert to "steps" based on realm
        var steps: Int
        switch targetNode.realm {
        case .dawn: steps = Int((distance / (150 / 2)).rounded())
        case .dusk: steps = Int((distance / (300 / 3)).rounded())
        case .night: steps = Int((distance / (450 / 4)).rounded())
        }
        
        return max(1, steps)
    }
    
    // Get targetable nodes for a card
    func getTargetableNodes(with card: ExplorationCard) -> [WorldNode] {
        guard let currentNode = nodes.first(where: { $0.id == currentNodeID }) else {
            return []
        }
        
        return nodes.filter { node in
            card.canTarget(node: node, from: currentNode, in: self)
        }
    }
    
    // Process playing an exploration card
    func playExplorationCard(_ card: ExplorationCard, targetNodeID: String? = nil) -> Bool {
        guard let currentNode = nodes.first(where: { $0.id == currentNodeID }) else {
            return false
        }
        
        switch card.cardType {
        case .path(let distance):
            // Move to target node if valid
            guard let targetID = targetNodeID,
                  let targetNode = nodes.first(where: { $0.id == targetID }),
                  card.canTarget(node: targetNode, from: currentNode, in: self) else {
                return false
            }
            
            // Move to the target node
            currentNodeID = targetID
            markNodeVisited(targetID)
            revealConnectedNodes(from: targetID)
            return true
            
        case .jump(let targetRealm):
            // Jump to a node in the target realm
            guard let targetID = targetNodeID,
                  let targetNode = nodes.first(where: { $0.id == targetID }),
                  targetNode.realm == targetRealm else {
                return false
            }
            
            // Jump to the target node
            currentNodeID = targetID
            markNodeVisited(targetID)
            revealConnectedNodes(from: targetID)
            return true
            
        case .reveal(let radius):
            // Reveal nodes within radius
            for i in 0..<nodes.count {
                let node = nodes[i]
                let dx = node.position.x - currentNode.position.x
                let dy = node.position.y - currentNode.position.y
                let distance = sqrt(dx*dx + dy*dy)
                
                if distance <= Double(radius * 100) { // Convert radius to coordinate scale
                    var updatedNode = node
                    updatedNode.isRevealed = true
                    nodes[i] = updatedNode
                }
            }
                        return true
                        
                    case .phase(let newPhase):
                        // Change the realm phase
                        currentPhase = newPhase
                        updateAccessibility()
                        return true
                        
                    case .special:
                        // Handle special effects
                        if let specialEffect = card.specialEffect {
                            specialEffect(self)
                        }
                        return true
                    }
                }
                
                // Mark a node as visited
                private func markNodeVisited(_ nodeID: String) {
                    if let index = nodes.firstIndex(where: { $0.id == nodeID }) {
                        var node = nodes[index]
                        node.isVisited = true
                        nodes[index] = node
                    }
                }
                
                // Reveal a specific node
                private func revealNode(_ nodeID: String) {
                    if let index = nodes.firstIndex(where: { $0.id == nodeID }) {
                        var node = nodes[index]
                        node.isRevealed = true
                        nodes[index] = node
                    }
                }
                
                // Reveal nodes connected to a node
                private func revealConnectedNodes(from nodeID: String) {
                    guard let node = nodes.first(where: { $0.id == nodeID }) else { return }
                    
                    for connectionID in node.connections {
                        revealNode(connectionID)
                    }
                }
            }

extension CelestialRealm {
    // Adjust the scale of the world based on screen size
    func adjustScale(for screenSize: CGSize) {
        // Calculate a scale factor based on screen size
        // Use the smaller dimension to ensure everything fits
        let minDimension = min(screenSize.width, screenSize.height)
        
        // For reference, we designed for a 750pt wide screen originally
        let referenceSize: CGFloat = 750
        
        // If on a smaller screen, scale down - using 0.9 instead of 0.7 for closer default zoom
        let scaleFactor = minDimension / referenceSize
        
        for i in 0..<nodes.count {
            // Scale down node positions with a more modest factor
            nodes[i].position = CGPoint(
                x: nodes[i].position.x * scaleFactor * 0.9, // Changed from 0.7 to 0.9
                y: nodes[i].position.y * scaleFactor * 0.9  // Changed from 0.7 to 0.9
            )
        }
    }
}
