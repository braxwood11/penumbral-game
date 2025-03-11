//
//  WorldNode.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import SpriteKit

// Different types of locations the player can visit
enum NodeType {
    case battle(difficulty: Int, enemyType: String)
    case cardRefinery(options: [RefinementOption])
    case narrative(dialogueID: String, character: String)
    case shop(inventory: [ShopItem])
    case mystery // Unknown until visited
    case nexus   // Special hub node in Dawn realm
    
    var icon: String {
        switch self {
        case .battle: return "battle-icon"
        case .cardRefinery: return "forge-icon"
        case .narrative: return "narrative-icon"
        case .shop: return "shop-icon"
        case .mystery: return "mystery-icon"
        case .nexus: return "nexus-icon"
        }
    }
}

extension WorldNode {
    var isNexus: Bool {
        if case .nexus = nodeType {
            return true
        }
        return false
    }
}

// A discrete location in the world that the player can visit
// Replace your WorldNode struct with this version that makes position mutable

struct WorldNode: Identifiable {
    let id: String
    let name: String
    let realm: Realm
    let nodeType: NodeType
    // Change from let to var for position
    var position: CGPoint
    
    // Which nodes this connects to
    var connections: [String] = []
    
    // Whether this node is currently visible to the player
    var isRevealed: Bool = false
    
    // Whether this node is currently accessible (based on realm phase)
    var isAccessible: Bool = false
    
    // Whether the player has already visited this node
    var isVisited: Bool = false
    
    // Optional requirements to access this node
    var requirements: [NodeRequirement]? = nil
    
    // What the player receives upon completing this node
    var rewards: [NodeReward]? = nil
}

// Requirements to access a node
enum NodeRequirement {
    case cardType(suit: Suit, count: Int)
    case cardValue(minValue: Int)
    case special(id: String, description: String)
}

// Rewards for completing a node
enum NodeReward {
    case card(Card)
    case pathfindingCard(ExplorationCard)
    case resource(type: ResourceType, amount: Int)
    case special(id: String, description: String)
}

// Resources used in the game
enum ResourceType: String {
    case luminance // Dawn energy
    case shadow    // Night energy
    case twilight  // Dusk energy
    case essence   // Universal energy
}
