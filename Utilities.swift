//
//  Utilities.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import SpriteKit

// For color operations in connections
extension SKColor {
    var redComponent: CGFloat {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return r
    }
    
    var greenComponent: CGFloat {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return g
    }
    
    var blueComponent: CGFloat {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return b
    }
}

// Placeholder structures (expand these later)
struct RefinementOption {
    let id: String
    let name: String
    let description: String
    let cost: Int
}

struct ShopItem {
    let id: String
    let name: String
    let description: String
    let cost: Int
}
