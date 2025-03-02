//
//  Realm.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import SpriteKit

enum Realm: String, CaseIterable {
    case dawn  // Central hub/nexus
    case dusk  // Middle ring, moderate challenge
    case night // Outer ring, highest challenge/reward
    
    var color: SKColor {
        switch self {
        case .dawn: return SKColor(red: 0xF5/255.0, green: 0xF6/255.0, blue: 0xEC/255.0, alpha: 1.0)
        case .dusk: return SKColor(red: 0xAF/255.0, green: 0x81/255.0, blue: 0xB3/255.0, alpha: 1.0)
        case .night: return SKColor(red: 0x6A/255.0, green: 0x68/255.0, blue: 0x79/255.0, alpha: 1.0)
        }
    }
}
