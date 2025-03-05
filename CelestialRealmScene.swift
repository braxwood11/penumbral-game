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
    internal let dawnRadius: CGFloat = 150
    internal let duskRadius: CGFloat = 300
    internal let nightRadius: CGFloat = 450
    
    // World container for panning and zooming
    internal var worldContainer: SKNode!
    
    // Zoom and pan properties
    internal var minScale: CGFloat = 0.5
    internal var maxScale: CGFloat = 2.0
    internal var currentScale: CGFloat = 1.0
    internal var isDragging = false
    internal var lastPanLocation: CGPoint?
    internal var initialPinchDistance: CGFloat?
    internal var initialScale: CGFloat?
    
    // Dynamic node sizing
    internal var baseNodeSize: CGFloat = 20
    internal var nodeScaleBreakpoints: [CGFloat: CGFloat] = [
        0.5: 1.3,  // At 0.5x zoom, show nodes 30% larger
        0.75: 1.2, // At 0.75x zoom, show nodes 20% larger
        1.0: 1.0,  // Normal size at 1.0x zoom
        1.5: 0.9,  // At 1.5x zoom, show nodes 10% smaller
        2.0: 0.8   // At 2.0x zoom, show nodes 20% smaller
    ]
    
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
        
        // Enable multi-touch for pinch gestures
        view.isMultipleTouchEnabled = true
    }
    
    private func setupLayers() {
        // Create a container for all world elements (for panning and zooming)
        worldContainer = SKNode()
        worldContainer.name = "worldContainer"
        worldContainer.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(worldContainer)
        
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
        
        // Add layers to world container
        worldContainer.addChild(backgroundLayer)
        worldContainer.addChild(connectionLayer)
        worldContainer.addChild(dawnLayer)
        worldContainer.addChild(duskLayer)
        worldContainer.addChild(nightLayer)
        
        // UI stays fixed on screen, not part of world container
        addChild(uiLayer)
    }
    
    private func setupBackground() {
        // Create a starfield background
        let background = SKSpriteNode(color: SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1), size: size)
        background.position = CGPoint.zero
        backgroundLayer.addChild(background)
        
        // Add stars
        for _ in 0..<100 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2))
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
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
        dawnBoundary.position = CGPoint.zero
        backgroundLayer.addChild(dawnBoundary)
        
        // Dusk realm (middle)
        let duskBoundary = SKShapeNode(circleOfRadius: duskRadius)
        duskBoundary.strokeColor = Realm.dusk.color
        duskBoundary.lineWidth = 2
        duskBoundary.fillColor = Realm.dusk.color.withAlphaComponent(0.1)
        duskBoundary.position = CGPoint.zero
        backgroundLayer.addChild(duskBoundary)
        
        // Night realm (outermost)
        let nightBoundary = SKShapeNode(circleOfRadius: nightRadius)
        nightBoundary.strokeColor = Realm.night.color
        nightBoundary.lineWidth = 2
        nightBoundary.fillColor = Realm.night.color.withAlphaComponent(0.1)
        nightBoundary.position = CGPoint.zero
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
            
            // Position in the scene (positions are already relative to center)
            nodeSprite.position = node.position
            
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
        
        // Apply dynamic node sizing for current zoom level
        updateNodeSizing()
    }
    
    private func createNodeSprite(_ node: WorldNode) -> SKNode {
        let container = SKNode()
        container.name = "node_\(node.id)"
        
        // Background circle with realm color
        let background = SKShapeNode(circleOfRadius: baseNodeSize)
        background.fillColor = node.realm.color
        background.strokeColor = node.isAccessible ? .white : node.realm.color.withAlphaComponent(0.5)
        background.lineWidth = 2
        background.alpha = node.isRevealed ? 1.0 : 0.5
        background.name = "nodeBackground"
        container.addChild(background)
        
        // Icon representing node type
        let iconTexture = ImageUtilities.getTexture(for: getIconNameForNodeType(node.nodeType))
        let icon = SKSpriteNode(texture: iconTexture)
        icon.size = CGSize(width: baseNodeSize, height: baseNodeSize)
        icon.color = .black
        icon.colorBlendFactor = 0.5
        icon.name = "nodeIcon"
        container.addChild(icon)
        
        // Node name label
        let nameLabel = SKLabelNode(fontNamed: "Copperplate")
        nameLabel.text = node.name
        nameLabel.fontSize = 14
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -baseNodeSize - 10)
        nameLabel.verticalAlignmentMode = .top
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.name = "nodeLabel"
        container.addChild(nameLabel)
        
        // If node is not accessible, dim it
        if !node.isAccessible {
            container.alpha = 0.5
        }
        
        // If node is current position, highlight it
        if node.id == celestialRealm.currentNodeID {
            let highlight = SKShapeNode(circleOfRadius: baseNodeSize + 5)
            highlight.strokeColor = .white
            highlight.lineWidth = 3
            highlight.fillColor = .clear
            highlight.alpha = 0.8
            highlight.name = "currentHighlight"
            
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
                let sourcePos = sourceNode.position
                let targetPos = targetNode.position
                
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
        // Set up fixed UI elements
        setupPhaseIndicator()
        setupNavigationControls()
        setupInfoPanel()
    }
    
    private func setupPhaseIndicator() {
        // Create UI for realm phase indicator
        let phaseContainer = SKNode()
        
        // Background panel
        let panelWidth: CGFloat = 180
        let panelHeight: CGFloat = 40
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 10)
        panel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.8)
        panel.strokeColor = .white
        panel.lineWidth = 1
        phaseContainer.addChild(panel)
        
        // Phase label
        let phaseLabel = SKLabelNode(fontNamed: "Copperplate")
        phaseLabel.text = "Current Phase: Dawn"
        phaseLabel.fontSize = 16
        phaseLabel.fontColor = .white
        phaseLabel.verticalAlignmentMode = .center
        phaseLabel.name = "phaseLabel"
        phaseContainer.addChild(phaseLabel)
        
        // Position in top center of screen
        phaseContainer.position = CGPoint(x: size.width/2, y: size.height - 40)
        phaseContainer.name = "phaseIndicator"
        uiLayer.addChild(phaseContainer)
        
        // Create phase shift button
        let shiftButton = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 10)
        shiftButton.fillColor = .darkGray
        shiftButton.strokeColor = .white
        shiftButton.position = CGPoint(x: size.width/2, y: size.height - 90)
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
    
    private func setupNavigationControls() {
        // Zoom controls
        createZoomButton("+", position: CGPoint(x: 40, y: size.height - 40), name: "zoomInButton")
        createZoomButton("-", position: CGPoint(x: 40, y: size.height - 90), name: "zoomOutButton")
        
        // Reset view button
        createNavButton("Reset View", position: CGPoint(x: 120, y: size.height - 40), name: "resetViewButton")
    }
    
    private func createZoomButton(_ symbol: String, position: CGPoint, name: String) {
        let button = SKShapeNode(circleOfRadius: 20)
        button.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        button.strokeColor = .white
        button.lineWidth = 2
        button.position = position
        button.name = name
        
        let label = SKLabelNode(fontNamed: "Copperplate")
        label.text = symbol
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = position
        
        uiLayer.addChild(button)
        uiLayer.addChild(label)
    }
    
    private func createNavButton(_ text: String, position: CGPoint, name: String) {
        let button = SKShapeNode(rectOf: CGSize(width: 100, height: 30), cornerRadius: 8)
        button.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        button.strokeColor = .white
        button.lineWidth = 1
        button.position = position
        button.name = name
        
        let label = SKLabelNode(fontNamed: "Copperplate")
        label.text = text
        label.fontSize = 12
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = position
        
        uiLayer.addChild(button)
        uiLayer.addChild(label)
    }
    
    private func setupInfoPanel() {
        // Create collapsible info panel for current node
        let panel = SKNode()
        panel.name = "infoPanel"
        
        // Background
            let panelBg = SKShapeNode(rectOf: CGSize(width: 250, height: 200), cornerRadius: 10)
            panelBg.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.8)
            panelBg.strokeColor = .white
            panelBg.lineWidth = 1
            panel.addChild(panelBg)
            
            // Title background
            let titleBg = SKShapeNode(rectOf: CGSize(width: 250, height: 40), cornerRadius: 10)
            titleBg.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
            titleBg.strokeColor = .clear
            titleBg.position = CGPoint(x: 0, y: 80)
            panel.addChild(titleBg)
        
        let title = SKLabelNode(fontNamed: "Copperplate")
        title.text = "Node Information"
        title.fontSize = 18
        title.fontColor = .white
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: 80)
        title.name = "infoTitle"
        panel.addChild(title)
        
        // Content (to be filled when a node is selected)
        let content = SKLabelNode(fontNamed: "Copperplate")
        content.text = "Select a node to view details."
        content.fontSize = 14
        content.fontColor = .white
        content.verticalAlignmentMode = .top
        content.horizontalAlignmentMode = .center
        content.preferredMaxLayoutWidth = 230
        content.numberOfLines = 0
        content.position = CGPoint(x: 0, y: 60)
        content.name = "infoContent"
        panel.addChild(content)
        
        // Collapse/Expand button
        let collapseButton = SKShapeNode(rectOf: CGSize(width: 30, height: 30), cornerRadius: 5)
        collapseButton.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 0.8)
        collapseButton.strokeColor = .white
        collapseButton.lineWidth = 1
        collapseButton.position = CGPoint(x: 110, y: 80)
        collapseButton.name = "collapseButton"
        panel.addChild(collapseButton)
        
        let collapseLabel = SKLabelNode(fontNamed: "Copperplate")
        collapseLabel.text = "-"
        collapseLabel.fontSize = 18
        collapseLabel.fontColor = .white
        collapseLabel.verticalAlignmentMode = .center
        collapseLabel.horizontalAlignmentMode = .center
        collapseLabel.position = CGPoint(x: 110, y: 80)
        collapseLabel.name = "collapseLabel"
        panel.addChild(collapseLabel)
        
        // Initially collapsed
        panel.userData = NSMutableDictionary()
        panel.userData?.setValue(false, forKey: "expanded")
        
        let handViewHeight: CGFloat = 200
        let verticalOffset: CGFloat = 50
        panel.position = CGPoint(x: size.width - 125, y: size.height - handViewHeight - verticalOffset)
        panel.setScale(0.8) // Slightly smaller
        
        // Initial collapsed state
        collapsePanel(panel)
        
        uiLayer.addChild(panel)
    }
    
    private func collapsePanel(_ panel: SKNode) {
        // Collapse to just the title bar
        let panelBg = panel.childNode(withName: "SKShapeNode") as? SKShapeNode
        panelBg?.path = CGPath(roundedRect: CGRect(x: -125, y: 60, width: 250, height: 40), cornerWidth: 10, cornerHeight: 10, transform: nil)
        
        panel.childNode(withName: "infoContent")?.isHidden = true
        
        // Change collapse button to expand
        let collapseLabel = panel.childNode(withName: "collapseLabel") as? SKLabelNode
        collapseLabel?.text = "+"
        
        // Update state
        panel.userData?.setValue(false, forKey: "expanded")
    }
    
    private func expandPanel(_ panel: SKNode) {
        // Expand to show content
        let panelBg = panel.childNode(withName: "SKShapeNode") as? SKShapeNode
        panelBg?.path = CGPath(roundedRect: CGRect(x: -125, y: -100, width: 250, height: 200), cornerWidth: 10, cornerHeight: 10, transform: nil)
        
        panel.childNode(withName: "infoContent")?.isHidden = false
        
        // Change expand button to collapse
        let collapseLabel = panel.childNode(withName: "collapseLabel") as? SKLabelNode
        collapseLabel?.text = "-"
        
        // Update state
        panel.userData?.setValue(true, forKey: "expanded")
    }
    
    private func toggleInfoPanel() {
        if let panel = uiLayer.childNode(withName: "infoPanel") {
            let isExpanded = panel.userData?.value(forKey: "expanded") as? Bool ?? false
            
            if isExpanded {
                collapsePanel(panel)
            } else {
                expandPanel(panel)
            }
        }
    }
    
    private func updateInfoPanel(with node: WorldNode?) {
        guard let panel = uiLayer.childNode(withName: "infoPanel") else { return }
        
        let title = panel.childNode(withName: "infoTitle") as? SKLabelNode
        let content = panel.childNode(withName: "infoContent") as? SKLabelNode
        
        // Calculate vertical position to avoid hand view
        let handViewHeight: CGFloat = 200  // Height of hand view
        let verticalOffset: CGFloat = 50   // Additional offset from hand view
        
        if let node = node {
            // Update with node info
            title?.text = node.name
            
            var contentText = "Type: \(getNodeTypeDescription(node.nodeType))\n"
            contentText += "Realm: \(node.realm.rawValue.capitalized)\n"
            
            if node.isAccessible {
                contentText += "Status: Accessible\n"
            } else {
                contentText += "Status: Inaccessible\n"
                contentText += "(Current phase: \(celestialRealm.currentPhase.rawValue.capitalized))\n"
            }
            
            if node.id == celestialRealm.currentNodeID {
                contentText += "\nThis is your current location."
            }
            
            content?.text = contentText
            
            // Modify panel position to be above hand view
            panel.position = CGPoint(
                x: size.width - 125,
                y: size.height - handViewHeight - verticalOffset
            )
            
            // Ensure panel is expanded and visible
            expandPanel(panel)
        } else {
            // Reset to default
            title?.text = "Node Information"
            content?.text = "Select a node to view details."
            
            // Reset position to default
            panel.position = CGPoint(x: size.width - 125, y: 100)
        }
    }
    
    private func getNodeTypeDescription(_ nodeType: NodeType) -> String {
        switch nodeType {
        case .battle(let difficulty, let enemyType):
            let stars = String(repeating: "⭐️", count: difficulty)
            return "Battle - \(enemyType) \(stars)"
        case .cardRefinery:
            return "Card Refinery"
        case .narrative(_, let character):
            return "Dialogue with \(character)"
        case .shop:
            return "Shop"
        case .mystery:
            return "Mystery"
        case .nexus:
            return "Nexus"
        }
    }
    
    // Update the visualization based on model state
    func updateVisualization() {
        // Update phase label
        if let phaseIndicator = uiLayer.childNode(withName: "phaseIndicator"),
           let phaseLabel = phaseIndicator.childNode(withName: "phaseLabel") as? SKLabelNode {
            phaseLabel.text = "Current Phase: \(celestialRealm.currentPhase.rawValue.capitalized)"
            phaseLabel.fontColor = celestialRealm.currentPhase.color
        }
        
        // Re-visualize nodes with updated states
        visualizeNodes()
        
        // Update info panel if a node is selected
        // Since currentNodeID is not optional, we can use it directly
        if let selectedNode = celestialRealm.nodes.first(where: { $0.id == celestialRealm.currentNodeID }) {
            updateInfoPanel(with: selectedNode)
        }
    }
    
    // Update node sizing based on zoom level
    internal func updateNodeSizing() {
        // Find the closest breakpoint
        var closestScale: CGFloat = 1.0
        var closestDistance: CGFloat = .infinity
        
        for scale in nodeScaleBreakpoints.keys {
            let distance = abs(scale - currentScale)
            if distance < closestDistance {
                closestDistance = distance
                closestScale = scale
            }
        }
        
        // Get scale factor for nodes at this zoom level
        let nodeScaleFactor = nodeScaleBreakpoints[closestScale] ?? 1.0
        
        // Apply sizing to all nodes
        for (_, nodeSprite) in nodeSprites {
            // Update background circle size
            if let background = nodeSprite.childNode(withName: "nodeBackground") as? SKShapeNode {
                background.path = CGPath(ellipseIn: CGRect(x: -baseNodeSize * nodeScaleFactor,
                                                           y: -baseNodeSize * nodeScaleFactor,
                                                           width: baseNodeSize * 2 * nodeScaleFactor,
                                                           height: baseNodeSize * 2 * nodeScaleFactor), transform: nil)
            }
            
            // Update icon size
            if let icon = nodeSprite.childNode(withName: "nodeIcon") as? SKSpriteNode {
                icon.size = CGSize(width: baseNodeSize * nodeScaleFactor, height: baseNodeSize * nodeScaleFactor)
            }
            
            // Update label position
            if let label = nodeSprite.childNode(withName: "nodeLabel") as? SKLabelNode {
                label.position = CGPoint(x: 0, y: -(baseNodeSize * nodeScaleFactor) - 10)
                
                // Adjust font size based on zoom
                let baseFontSize: CGFloat = 14
                label.fontSize = baseFontSize * (1/currentScale) * 0.8
                
                // Hide label text at extreme zoom levels to avoid clutter
                label.isHidden = (currentScale > 1.8 || currentScale < 0.6)
            }
            
            // Update current node highlight if present
            if let highlight = nodeSprite.childNode(withName: "currentHighlight") as? SKShapeNode {
                highlight.path = CGPath(ellipseIn: CGRect(x: -(baseNodeSize + 5) * nodeScaleFactor,
                                                          y: -(baseNodeSize + 5) * nodeScaleFactor,
                                                          width: (baseNodeSize + 5) * 2 * nodeScaleFactor,
                                                          height: (baseNodeSize + 5) * 2 * nodeScaleFactor), transform: nil)
            }
        }
        
        // Adjust connection line widths
        for connection in connectionLayer.children {
            if let line = connection as? SKShapeNode {
                line.lineWidth = 2 * (1/currentScale) * 0.8
                // At extreme zoom levels, make connections more visible
                if currentScale < 0.7 {
                    line.lineWidth = 3 * (1/currentScale) * 0.8
                }
            }
        }
    }
    
    // MARK: - Touch Handling
    
    private func handleUITouch(_ location: CGPoint) -> Bool {
        // Check for UI element touches
        
        // Phase shift button
        if let shiftButton = uiLayer.childNode(withName: "shiftButton"), shiftButton.contains(location) {
            handlePhaseShift()
            return true
        }
        
        // Zoom in button
        if let zoomInButton = uiLayer.childNode(withName: "zoomInButton"), zoomInButton.contains(location) {
            handleZoomIn()
            return true
        }
        
        // Zoom out button
        if let zoomOutButton = uiLayer.childNode(withName: "zoomOutButton"), zoomOutButton.contains(location) {
            handleZoomOut()
            return true
        }
        
        // Reset view button
        if let resetButton = uiLayer.childNode(withName: "resetViewButton"), resetButton.contains(location) {
            resetView()
            return true
        }
        
        // Info panel collapse/expand
        if let infoPanel = uiLayer.childNode(withName: "infoPanel"),
           let collapseButton = infoPanel.childNode(withName: "collapseButton"),
           collapseButton.contains(location) {
            toggleInfoPanel()
            return true
        }
        
        return false
    }
    
    private func handleNodeSelection(at location: CGPoint) {
        var selectedNode: WorldNode? = nil
        
        // Check each node sprite to see if it was touched
        for (nodeID, sprite) in nodeSprites {
            if sprite.contains(location) {
                // Find the corresponding node in the model
                if let node = celestialRealm.nodes.first(where: { $0.id == nodeID }) {
                    selectedNode = node
                    
                    // If node is accessible, make it the current node
                    if node.isAccessible && node.id != celestialRealm.currentNodeID {
                        moveToNode(node)
                    } else {
                        // Just show info without moving
                        updateInfoPanel(with: node)
                    }
                }
                break
            }
        }
        
        // If nothing was touched, clear selection
        if selectedNode == nil {
            updateInfoPanel(with: nil)
        }
    }
    
    private func moveToNode(_ node: WorldNode) {
        // Update current node in the model using our new public method
        celestialRealm.moveToNode(withID: node.id)
        
        // Mark the node as visited
        celestialRealm.markNodeAsVisited(node.id)
        
        // Reveal connected nodes
        celestialRealm.revealNodesConnectedTo(nodeID: node.id)
        
        // Update visualization
        updateVisualization()
        
        // Animate movement to show transition
        let moveAction = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.showMovementEffect(to: node)
            },
            SKAction.wait(forDuration: 0.5)
        ])
        
        run(moveAction)
    }
    
    private func showMovementEffect(to node: WorldNode) {
        // Get target node sprite
        guard let targetSprite = nodeSprites[node.id] else { return }
        
        // Create flash effect
        let flash = SKShapeNode(circleOfRadius: baseNodeSize * 2)
        flash.fillColor = node.realm.color.withAlphaComponent(0.5)
        flash.strokeColor = .white
        flash.lineWidth = 2
        flash.position = targetSprite.position
        flash.zPosition = 50
        flash.alpha = 0
        
        // Add to appropriate layer
        switch node.realm {
        case .dawn: dawnLayer.addChild(flash)
        case .dusk: duskLayer.addChild(flash)
        case .night: nightLayer.addChild(flash)
        }
        
        // Animate flash
        flash.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // First, handle UI element touches
        if handleUITouch(location) {
            return
        }
        
        // Store touch location for dragging
        lastPanLocation = location
        
        // For pinch gestures, we need to track multiple touches
        if touches.count == 2 {
            // Convert set to array to access touches by index
            let touchesArray = Array(touches)
            let touch1 = touchesArray[0]
            let touch2 = touchesArray[1]
            
            let point1 = touch1.location(in: self)
            let point2 = touch2.location(in: self)
            initialPinchDistance = hypot(point2.x - point1.x, point2.y - point1.y)
            initialScale = worldContainer.xScale
            isDragging = false
        } else {
            // Single touch - start dragging
            isDragging = true
            initialPinchDistance = nil
            
            // Check for node selection
            let worldLocation = touch.location(in: worldContainer)
            handleNodeSelection(at: worldLocation)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentLocation = touch.location(in: self)
        
        if touches.count == 2, let initialPinchDistance = initialPinchDistance, let initialScale = initialScale {
            // Convert set to array to access touches by index
            let touchesArray = Array(touches)
            let touch1 = touchesArray[0]
            let touch2 = touchesArray[1]
            
            let point1 = touch1.location(in: self)
            let point2 = touch2.location(in: self)
            let currentDistance = hypot(point2.x - point1.x, point2.y - point1.y)
            
            // Calculate new scale based on the pinch distance ratio
            let pinchRatio = currentDistance / initialPinchDistance
            var newScale = initialScale * pinchRatio
            
            // Constrain scale within minimum and maximum values
            newScale = max(minScale, min(maxScale, newScale))
            
            // Apply scale to world container
            worldContainer.setScale(newScale)
            
            // Update current scale value
            currentScale = newScale
            
            // Update node sizing for the new scale
            updateNodeSizing()
            
            isDragging = false
        } else if isDragging, let lastLocation = lastPanLocation {
            // Handle panning/dragging
            let dx = currentLocation.x - lastLocation.x
            let dy = currentLocation.y - lastLocation.y
            
            // Move the world container
            worldContainer.position = CGPoint(
                x: worldContainer.position.x + dx,
                y: worldContainer.position.y + dy
            )
            
            // Update last position
            lastPanLocation = currentLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset drag state
        isDragging = false
        lastPanLocation = nil
        initialPinchDistance = nil
        initialScale = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle same as touches ended
        touchesEnded(touches, with: event)
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
                flash.zPosition = 500 // Make sure it appears above everything
                addChild(flash)
                
                flash.run(SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.3),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.removeFromParent()
                ]))
            }
            
    internal func handleZoomIn() {
                // Zoom in by a fixed amount
                let targetScale = min(maxScale, currentScale * 1.25)
                animateZoom(to: targetScale)
            }
            
    internal func handleZoomOut() {
                // Zoom out by a fixed amount
                let targetScale = max(minScale, currentScale / 1.25)
                animateZoom(to: targetScale)
            }
            
            private func animateZoom(to targetScale: CGFloat) {
                // Animate zoom smoothly
                let scaleAction = SKAction.scale(to: targetScale, duration: 0.3)
                scaleAction.timingMode = .easeOut
                
                worldContainer.run(scaleAction) {
                    self.currentScale = targetScale
                    self.updateNodeSizing()
                }
            }
            
            private func resetView() {
                // Reset world container position and scale with animation
                let moveAction = SKAction.move(to: CGPoint(x: size.width/2, y: size.height/2), duration: 0.5)
                let scaleAction = SKAction.scale(to: 1.0, duration: 0.5)
                
                worldContainer.run(SKAction.group([moveAction, scaleAction])) {
                    self.currentScale = 1.0
                    self.updateNodeSizing()
                }
            }
            
            // Centers the view on a specific node
            func centerOn(nodeID: String) {
                guard let nodeSprite = nodeSprites[nodeID] else { return }
                
                // Calculate the world position needed to center this node
                let nodeWorldPos = worldContainer.convert(nodeSprite.position, to: self)
                let targetWorldPos = CGPoint(
                    x: worldContainer.position.x + (size.width/2 - nodeWorldPos.x),
                    y: worldContainer.position.y + (size.height/2 - nodeWorldPos.y)
                )
                
                // Animate the centering
                let moveAction = SKAction.move(to: targetWorldPos, duration: 0.5)
                moveAction.timingMode = .easeInEaseOut
                
                worldContainer.run(moveAction)
            }
        }
