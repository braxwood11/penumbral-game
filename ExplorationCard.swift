//
//  ExplorationCard.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import SpriteKit

// Different types of exploration cards a player might have
enum ExplorationCardType {
    case path(distance: Int)       // Basic movement card
    case jump(realm: Realm)        // Jump directly to a specific realm
    case reveal(radius: Int)       // Reveal hidden nodes within radius
    case phase(newPhase: Realm)    // Force a realm phase shift
    case special(effect: String)   // Special effects (teleport, bypass requirements, etc.)
}

// An individual exploration card
struct ExplorationCard: Identifiable {
    let id: String
    let name: String
    let description: String
    let cardType: ExplorationCardType
    
    // Visual properties
    let rarity: CardRarity
    var artworkName: String
    
    // Which realms this card can be used in
    var validRealms: [Realm]
    
    // Optional special effects
    var specialEffect: ((CelestialRealm) -> Void)?
    
    // Can this card target a specific node?
    func canTarget(node: WorldNode, from currentNode: WorldNode, in realm: CelestialRealm) -> Bool {
        // Card must be valid in the current realm phase
        guard validRealms.contains(realm.currentPhase) else { return false }
        
        // Node must be revealed and accessible
        guard node.isRevealed && node.isAccessible else { return false }
        
        switch cardType {
        case .path(let distance):
            // Check if node is within distance
            let pathDistance = realm.calculatePathDistance(from: currentNode.id, to: node.id)
            return pathDistance <= distance
            
        case .jump(let targetRealm):
            // Can only jump to nodes in the specified realm
            return node.realm == targetRealm
            
        case .reveal:
            // Reveal cards target the current node and affect surrounding areas
            return node.id == currentNode.id
            
        case .phase:
            // Phase cards are played on the current node to shift the realm
            return node.id == currentNode.id
            
        case .special:
            // Special cards may have unique targeting rules
            return true
        }
    }
}

// Rarity of a card (affects appearance and power level)
enum CardRarity: String, CaseIterable {
    case common
    case uncommon
    case rare
    case mythic
    
    var color: SKColor {
        switch self {
        case .common: return .white
        case .uncommon: return SKColor(red: 0.0, green: 0.8, blue: 0.2, alpha: 1.0)
        case .rare: return SKColor(red: 0.2, green: 0.4, blue: 1.0, alpha: 1.0)
        case .mythic: return SKColor(red: 0.8, green: 0.4, blue: 0.9, alpha: 1.0)
        }
    }
}

// Sample exploration cards
func createBasicExplorationDeck() -> [ExplorationCard] {
    var cards: [ExplorationCard] = []
    
    // Path cards (basic movement)
    for i in 1...10 {
        let distance = [1, 1, 1, 2, 2, 2, 3, 3, 4, 5][i-1]
        cards.append(ExplorationCard(
            id: "path_\(i)",
            name: distance > 3 ? "Long Path" : "Path",
            description: "Move up to \(distance) nodes along connected paths",
            cardType: .path(distance: distance),
            rarity: distance > 3 ? .uncommon : .common,
            artworkName: "path_card",
            validRealms: [.dawn, .dusk, .night]
        ))
    }
    
    // Jump cards
    for realm in Realm.allCases {
        cards.append(ExplorationCard(
            id: "jump_to_\(realm.rawValue)",
            name: "\(realm.rawValue.capitalized) Jump",
            description: "Jump to any revealed node in the \(realm.rawValue) realm",
            cardType: .jump(realm: realm),
            rarity: .uncommon,
            artworkName: "\(realm.rawValue)_jump",
            validRealms: [.dawn, .dusk, .night]
        ))
    }
    
    // Reveal cards
    for radius in [1, 2, 3] {
        cards.append(ExplorationCard(
            id: "reveal_\(radius)",
            name: radius > 1 ? "Greater Vision" : "Vision",
            description: "Reveal all nodes within \(radius) steps",
            cardType: .reveal(radius: radius),
            rarity: radius > 1 ? .uncommon : .common,
            artworkName: "reveal_card",
            validRealms: [.dawn, .dusk, .night]
        ))
    }
    
    // Phase shift cards
    for realm in Realm.allCases {
        cards.append(ExplorationCard(
            id: "phase_\(realm.rawValue)",
            name: "\(realm.rawValue.capitalized) Phase",
            description: "Shift the realm to the \(realm.rawValue) phase",
            cardType: .phase(newPhase: realm),
            rarity: .rare,
            artworkName: "\(realm.rawValue)_phase",
            validRealms: [.dawn, .dusk, .night]
        ))
    }
    
    // Special cards
    cards.append(ExplorationCard(
        id: "teleport",
        name: "Teleport",
        description: "Move to any revealed node on the map",
        cardType: .special(effect: "teleport"),
        rarity: .rare,
        artworkName: "teleport_card",
        validRealms: [.dawn, .dusk, .night],
        specialEffect: { realm in
            // Teleport handled by UI
        }
    ))
    
    cards.append(ExplorationCard(
        id: "cosmic_sight",
        name: "Cosmic Sight",
        description: "Reveal all nodes in the current realm",
        cardType: .special(effect: "reveal_realm"),
        rarity: .rare,
        artworkName: "cosmic_sight",
        validRealms: [.dawn, .dusk, .night],
        specialEffect: { realm in
            // Reveal all nodes in the current phase's realm
            let currentPhase = realm.currentPhase
            for i in 0..<realm.nodes.count {
                if realm.nodes[i].realm == currentPhase {
                    realm.nodes[i].isRevealed = true
                }
            }
        }
    ))
    
    return cards
}
