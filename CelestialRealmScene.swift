//
//  CelestialRealmScene.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import SpriteKit

class CelestialRealmScene: SKScene {
    
    // Reference to the data model
    var celestialRealm: CelestialRealm!
    
    // Layers for organizing nodes visually
    internal var backgroundLayer: SKNode!
    internal var dawnLayer: SKNode!
    internal var duskLayer: SKNode!
    internal var nightLayer: SKNode!
    internal var connectionLayer: SKNode!
    internal var uiLayer: SKNode!
    
    // Node sprites dictionary
    var nodeSprites: [String: SKNode] = [:]
    
    // Constants for visualization
    private let dawnRadius: CGFloat = 150
    private let duskRadius: CGFloat = 300
    private let nightRadius: CGFloat = 450
    
    // Initialize with the celestial realm model
    init(size: CGSize, celestialRealm: CelestialRealm) {
        self.celestialRealm = celestialRealm
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        setupLayers()
        setupBackground()
        createRealmBoundaries()
        visualizeNodes()
        setupUI()
        
        // Initial update to match model state
        updateVisualization()
    }
    
    private func setupLayers() {
        backgroundLayer = SKNode()
        dawnLayer = SKNode()
        duskLayer = SKNode()
        nightLayer = SKNode()
        connectionLayer = SKNode()
        uiLayer = SKNode()
        
        // Set z-positions for proper layering
        backgroundLayer.zPosition = 0
        connectionLayer.zPosition = 10
        dawnLayer.zPosition = 20
        duskLayer.zPosition = 20
        nightLayer.zPosition = 20
        uiLayer.zPosition = 100
        
        // Center all the realm layers at the center of the screen
           backgroundLayer.position = CGPoint(x: 0, y: 0)
           connectionLayer.position = CGPoint(x: 0, y: 0)
           dawnLayer.position = CGPoint(x: 0, y: 0)
           duskLayer.position = CGPoint(x: 0, y: 0)
           nightLayer.position = CGPoint(x: 0, y: 0)
           
           // Apply an initial scale to zoom in
           let initialScale: CGFloat = 1.5 // Adjust this value as needed
           backgroundLayer.setScale(initialScale)
           connectionLayer.setScale(initialScale)
           dawnLayer.setScale(initialScale)
           duskLayer.setScale(initialScale)
           nightLayer.setScale(initialScale)
        
        addChild(backgroundLayer)
        addChild(connectionLayer)
        addChild(dawnLayer)
        addChild(duskLayer)
        addChild(nightLayer)
        addChild(uiLayer)
    }
    
    private func setupBackground() {
        // Create a starfield background
        let background = SKSpriteNode(color: SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1), size: size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundLayer.addChild(background)
        
        // Add stars
        for _ in 0..<100 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2))
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.3...1.0)
            
            // Subtle twinkling animation
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.3...0.7), duration: CGFloat.random(in: 1.0...3.0)),
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.7...1.0), duration: CGFloat.random(in: 1.0...3.0))
            ])
            star.run(SKAction.repeatForever(twinkle))
            
            backgroundLayer.addChild(star)
        }
    }
    
    private func createRealmBoundaries() {
        // Dawn realm (innermost)
        let dawnBoundary = SKShapeNode(circleOfRadius: dawnRadius)
        dawnBoundary.strokeColor = Realm.dawn.color
        dawnBoundary.lineWidth = 2
        dawnBoundary.fillColor = Realm.dawn.color.withAlphaComponent(0.1)
        dawnBoundary.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundLayer.addChild(dawnBoundary)
        
        // Dusk realm (middle)
        let duskBoundary = SKShapeNode(circleOfRadius: duskRadius)
        duskBoundary.strokeColor = Realm.dusk.color
        duskBoundary.lineWidth = 2
        duskBoundary.fillColor = Realm.dusk.color.withAlphaComponent(0.1)
        duskBoundary.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundLayer.addChild(duskBoundary)
        
        // Night realm (outermost)
        let nightBoundary = SKShapeNode(circleOfRadius: nightRadius)
        nightBoundary.strokeColor = Realm.night.color
        nightBoundary.lineWidth = 2
        nightBoundary.fillColor = Realm.night.color.withAlphaComponent(0.1)
        nightBoundary.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundLayer.addChild(nightBoundary)
    }
    
    func visualizeNodes() {
        // Clear existing node sprites
        dawnLayer.removeAllChildren()
        duskLayer.removeAllChildren()
        nightLayer.removeAllChildren()
        connectionLayer.removeAllChildren()
        nodeSprites.removeAll()
        
        // Get all world nodes from the model
        let worldNodes = celestialRealm.nodes
        
        // Create node sprites and add to appropriate layers
        for node in worldNodes {
            // Skip nodes that aren't revealed
            guard node.isRevealed else { continue }
            
            let nodeSprite = createNodeSprite(node)
            
            // Position in the scene (convert from model coordinates)
            nodeSprite.position = CGPoint(
                x: size.width/2 + node.position.x,
                y: size.height/2 + node.position.y
            )
            
            // Add to appropriate layer based on realm
            switch node.realm {
            case .dawn:
                dawnLayer.addChild(nodeSprite)
            case .dusk:
                duskLayer.addChild(nodeSprite)
            case .night:
                nightLayer.addChild(nodeSprite)
            }
            
            // Store reference
            nodeSprites[node.id] = nodeSprite
        }
        
        // Create connections between nodes
        visualizeConnections(worldNodes)
    }
    
    private func createNodeSprite(_ node: WorldNode) -> SKNode {
        let container = SKNode()
        
        // Background circle with realm color
        let background = SKShapeNode(circleOfRadius: 20)
        background.fillColor = node.realm.color
        background.strokeColor = node.isAccessible ? .white : node.realm.color.withAlphaComponent(0.5)
        background.lineWidth = 2
        background.alpha = node.isRevealed ? 1.0 : 0.5
        container.addChild(background)
        
        // Icon representing node type
        let iconTexture = ImageUtilities.getTexture(for: getIconNameForNodeType(node.nodeType))
        let icon = SKSpriteNode(texture: iconTexture)
        icon.size = CGSize(width: 20, height: 20)
        icon.color = .black
        icon.colorBlendFactor = 0.5
        container.addChild(icon)
        
        // Node name label
        let nameLabel = SKLabelNode(fontNamed: "Copperplate")
        nameLabel.text = node.name
        nameLabel.fontSize = 14
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -30)
        container.addChild(nameLabel)
        
        // If node is not accessible, dim it
        if !node.isAccessible {
            container.alpha = 0.5
        }
        
        // If node is current position, highlight it
        if node.id == celestialRealm.currentNodeID {
            let highlight = SKShapeNode(circleOfRadius: 25)
            highlight.strokeColor = .white
            highlight.lineWidth = 3
            highlight.fillColor = .clear
            highlight.alpha = 0.8
            
            // Pulsing animation
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.8),
                SKAction.fadeAlpha(to: 0.8, duration: 0.8)
            ])
            highlight.run(SKAction.repeatForever(pulse))
            
            container.addChild(highlight)
        }
        
        return container
    }
    
    private func getIconNameForNodeType(_ nodeType: NodeType) -> String {
        switch nodeType {
        case .battle: return "crossed-swords"
        case .cardRefinery: return "forge"
        case .narrative: return "speech-bubble"
        case .shop: return "merchant"
        case .mystery: return "question-mark"
        case .nexus: return "nexus-crystal"
        }
    }
    
    private func visualizeConnections(_ nodes: [WorldNode]) {
        // Create lines between connected nodes
        for sourceNode in nodes {
            guard sourceNode.isRevealed else { continue }
            
            for connectionID in sourceNode.connections {
                guard let targetNode = nodes.first(where: { $0.id == connectionID }),
                      targetNode.isRevealed else { continue }
                
                // Convert positions to scene coordinates
                let sourcePos = CGPoint(
                    x: size.width/2 + sourceNode.position.x,
                    y: size.height/2 + sourceNode.position.y
                )
                
                let targetPos = CGPoint(
                    x: size.width/2 + targetNode.position.x,
                    y: size.height/2 + targetNode.position.y
                )
                
                // Create connection line
                let path = CGMutablePath()
                path.move(to: sourcePos)
                path.addLine(to: targetPos)
                
                let connection = SKShapeNode(path: path)
                connection.strokeColor = getConnectionColor(sourceNode.realm, targetNode.realm)
                connection.lineWidth = 2
                connection.alpha = sourceNode.isAccessible && targetNode.isAccessible ? 0.8 : 0.3
                connection.zPosition = 5 // Between background and nodes
                
                connectionLayer.addChild(connection)
            }
        }
    }
    
    private func getConnectionColor(_ sourceRealm: Realm, _ targetRealm: Realm) -> SKColor {
        if sourceRealm == targetRealm {
            return sourceRealm.color
        } else {
            // Blend colors for cross-realm connections
            let sourceColor = sourceRealm.color
            let targetColor = targetRealm.color
            return SKColor(
                red: (sourceColor.redComponent + targetColor.redComponent) / 2,
                green: (sourceColor.greenComponent + targetColor.greenComponent) / 2,
                blue: (sourceColor.blueComponent + targetColor.blueComponent) / 2,
                alpha: 1.0
            )
        }
    }
    
    private func setupUI() {
        // Create UI for realm phase indicator
        let phaseLabel = SKLabelNode(fontNamed: "Copperplate")
        phaseLabel.text = "Current Phase: Dawn"
        phaseLabel.fontSize = 20
        phaseLabel.fontColor = .white
        phaseLabel.position = CGPoint(x: size.width/2, y: size.height - 50)
        phaseLabel.name = "phaseLabel"
        uiLayer.addChild(phaseLabel)
        
        // Create phase shift button
        let shiftButton = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 10)
        shiftButton.fillColor = .darkGray
        shiftButton.strokeColor = .white
        shiftButton.position = CGPoint(x: size.width/2, y: size.height - 100)
        shiftButton.name = "shiftButton"
        
        let shiftLabel = SKLabelNode(fontNamed: "Copperplate")
        shiftLabel.text = "Shift Phase"
        shiftLabel.fontSize = 16
        shiftLabel.fontColor = .white
        shiftLabel.verticalAlignmentMode = .center
        shiftLabel.position = shiftButton.position
        
        uiLayer.addChild(shiftButton)
        uiLayer.addChild(shiftLabel)
    }
    
    // Update the visualization based on model state
    func updateVisualization() {
        // Update phase label
        if let phaseLabel = uiLayer.childNode(withName: "phaseLabel") as? SKLabelNode {
            phaseLabel.text = "Current Phase: \(celestialRealm.currentPhase.rawValue.capitalized)"
            phaseLabel.fontColor = celestialRealm.currentPhase.color
        }
        
        // Re-visualize nodes with updated states
        visualizeNodes()
    }
    
    // MARK: - Interaction
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Handle phase shift button
        if let shiftButton = uiLayer.childNode(withName: "shiftButton"),
           shiftButton.contains(location) {
            handlePhaseShift()
            return
        }
        
        // Handle node selection
        for (nodeID, sprite) in nodeSprites {
            if sprite.contains(location) {
                print("Tapped on node: \(nodeID)")
                // Implement node selection handling
                break
            }
        }
    }
    
    private func handlePhaseShift() {
        // Call model to shift phase
        celestialRealm.shiftPhase()
        
        // Update visualization
        updateVisualization()
        
        // Visual effect for phase shift
        let flash = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        flash.fillColor = celestialRealm.currentPhase.color.withAlphaComponent(0.3)
        flash.strokeColor = .clear
        flash.alpha = 0
        addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
}
