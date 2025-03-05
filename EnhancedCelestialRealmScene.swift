//
//  EnhancedCelestialRealmScene.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import SpriteKit

// Enhanced CelestialRealm scene with exploration hand management
class EnhancedCelestialRealmScene: CelestialRealmScene, ExplorationHandDelegate {
    
    private var explorationDeck: ExplorationDeck!
    private var handView: ExplorationHandView!
    private var targetableNodes: [String] = []
    private var returnButton: SKNode!
    private var helpButton: SKNode!
    
    // Override initialization to include exploration deck
    init(size: CGSize, celestialRealm: CelestialRealm, explorationDeck: ExplorationDeck) {
        self.explorationDeck = explorationDeck
        
        // Adjust the scale of the celestial realm
        celestialRealm.adjustScale(for: size)
        
        super.init(size: size, celestialRealm: celestialRealm)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Set up the hand view
        setupExplorationHand()
        
        // Add navigation features
        setupReturnButton()
        setupHelpButton()

        // Apply initial zoom - start with the world a bit more zoomed in
        if let container = childNode(withName: "worldContainer") {
            // Scale the world container to make everything bigger at start
            container.setScale(1.3)
            // Update currentScale to match
            currentScale = 1.3
            // Update node sizing for this scale
            updateNodeSizing()
        }
        
        // Focus on current node
        if let currentNode = celestialRealm.nodes.first(where: { $0.id == celestialRealm.currentNodeID }) {
            centerOn(nodeID: currentNode.id)
        }
    }
    
    private func setupExplorationHand() {
        // Create hand view at the bottom of the screen
        handView = ExplorationHandView()
        handView.position = CGPoint(x: size.width/2, y: 100)
        handView.delegate = self
        handView.zPosition = 1000
        
        // Add background panel for hand view
        let handBg = SKShapeNode(rectOf: CGSize(width: size.width - 40, height: 200), cornerRadius: 15)
        handBg.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.7)
        handBg.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)
        handBg.lineWidth = 2
        handBg.position = handView.position
        handBg.zPosition = 990
        addChild(handBg)
        
        addChild(handView)
        
        // Update with current cards
        updateHandView()
    }
    
    private func createLegendItem(realm: Realm, position: CGPoint, parent: SKNode) {
        let itemNode = SKNode()
        
        // Color circle
        let circle = SKShapeNode(circleOfRadius: 6)
        circle.fillColor = realm.color
        circle.strokeColor = .white
        circle.lineWidth = 1
        circle.position = CGPoint(x: -50, y: position.y)
        itemNode.addChild(circle)
        
        // Label
        let label = SKLabelNode(fontNamed: "Copperplate")
        label.text = realm.rawValue.capitalized
        label.fontSize = 12
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: -40, y: position.y)
        itemNode.addChild(label)
        
        parent.addChild(itemNode)
    }
    
    private func setupReturnButton() {
        // Create a return button - Positioned lower on the screen
        let buttonBackground = SKShapeNode(rectOf: CGSize(width: 140, height: 40), cornerRadius: 10)
        buttonBackground.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        buttonBackground.strokeColor = .white
        buttonBackground.lineWidth = 2
        
        let buttonLabel = SKLabelNode(fontNamed: "Copperplate")
        buttonLabel.text = "Return to Battle"
        buttonLabel.fontSize = 16
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        
        returnButton = SKNode()
        returnButton.addChild(buttonBackground)
        returnButton.addChild(buttonLabel)
        returnButton.position = CGPoint(x: size.width - 90, y: size.height - 140)
        returnButton.name = "returnButton"
        returnButton.zPosition = 1100
        addChild(returnButton)
        
        // Add a subtle pulse animation to make it noticeable
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        returnButton.run(SKAction.repeatForever(pulse))
    }
    
    private func setupHelpButton() {
        // Create a help button
        let buttonSize: CGFloat = 30
        let helpBg = SKShapeNode(circleOfRadius: buttonSize/2)
        helpBg.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        helpBg.strokeColor = .white
        helpBg.lineWidth = 2
        
        let helpLabel = SKLabelNode(fontNamed: "Copperplate")
        helpLabel.text = "?"
        helpLabel.fontSize = 18
        helpLabel.fontColor = .white
        helpLabel.verticalAlignmentMode = .center
        helpLabel.horizontalAlignmentMode = .center
        
        helpButton = SKNode()
        helpButton.addChild(helpBg)
        helpButton.addChild(helpLabel)
        helpButton.position = CGPoint(x: size.width - 160, y: size.height - 40)
        helpButton.name = "helpButton"
        helpButton.zPosition = 1100
        addChild(helpButton)
    }
    
    private func updateHandView() {
        handView.updateWithCards(explorationDeck.hand)
    }
    
    // MARK: - ExplorationHandDelegate
    
    func didSelectCard(at index: Int) {
        // Get the selected card
        let card = explorationDeck.hand[index]
        
        // Find which nodes can be targeted with this card
        targetableNodes = celestialRealm.getTargetableNodes(with: card).map { $0.id }
        
        // Highlight targetable nodes
        highlightTargetableNodes()
        
        // Enter targeting mode in hand view
        handView.enterTargetingMode()
    }
    
    func didDeselectCard() {
        // Clear targeting
        clearNodeHighlights()
        targetableNodes.removeAll()
    }
    
    // MARK: - Highlighting
    
    private func highlightTargetableNodes() {
        // Clear any existing highlights
        clearNodeHighlights()
        
        // Add highlights to targetable nodes
        for nodeID in targetableNodes {
            if let node = nodeSprites[nodeID] {
                let highlight = SKShapeNode(circleOfRadius: 25)
                highlight.strokeColor = .green
                highlight.lineWidth = 3
                highlight.fillColor = .clear
                highlight.name = "target_highlight"
                
                // Pulsing animation
                highlight.alpha = 0.8
                highlight.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.4, duration: 0.8),
                    SKAction.fadeAlpha(to: 0.8, duration: 0.8)
                ])))
                
                node.addChild(highlight)
            }
        }
    }
    
    private func clearNodeHighlights() {
        // Remove all targeting highlights
        for (_, node) in nodeSprites {
            node.childNode(withName: "target_highlight")?.removeFromParent()
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check for popups first
        if let popup = childNode(withName: "nodePopup") {
            // Check popup button across entire scene
            if let buttonBg = popup.childNode(withName: "popupButton"),
               buttonBg.contains(convert(location, to: popup)) {
                if let callback = popup.userData?.value(forKey: "callback") as? () -> Void {
                    callback()
                    return
                }
            }
            
            // If popup is visible, block further touches
            if popup.alpha > 0 {
                return
            }
        }
        
        // Check if return button was tapped
        if let returnButton = childNode(withName: "returnButton"), returnButton.contains(location) {
            dismissExploration()
            return
        }
        
        // Check if help button was tapped
        if let helpButton = childNode(withName: "helpButton"), helpButton.contains(location) {
            showHelpOverlay()
            return
        }
        
        // Check for zoom controls
        if let zoomInButton = childNode(withName: "zoomInButton"), zoomInButton.contains(location) {
            handleZoomIn()
            return
        }
        
        if let zoomOutButton = childNode(withName: "zoomOutButton"), zoomOutButton.contains(location) {
            handleZoomOut()
            return
        }
        
        // Check for touches on the hand first
        if handView.handleTouch(at: handView.convert(location, from: self)) {
            return
        }
        
        // If we're in targeting mode, check for node selection
        if !targetableNodes.isEmpty, let selectedCardIndex = handView.getSelectedCardIndex() {
            // Check if a targetable node was touched
            let worldLocation = touch.location(in: worldContainer)
            
            for (nodeID, sprite) in nodeSprites {
                if sprite.contains(sprite.convert(worldLocation, from: worldContainer)) && targetableNodes.contains(nodeID) {
                    // Play the card targeting this node
                    playCard(at: selectedCardIndex, targetingNode: nodeID)
                    return
                }
            }
            
            // If touched outside of targetable nodes, exit targeting mode
            handView.exitTargetingMode()
            clearNodeHighlights()
            targetableNodes.removeAll()
            return
        }
        
        // Otherwise, pass the touch to the parent implementation
        super.touchesBegan(touches, with: event)
    }
    
    
    // MARK: - Card Playing
    
    private func playCard(at index: Int, targetingNode nodeID: String) {
        // Get the card from the deck
        if let card = explorationDeck.playCard(at: index) {
            // Apply the card effect
            if celestialRealm.playExplorationCard(card, targetNodeID: nodeID) {
                // Card was successfully played
                
                // Update the hand
                updateHandView()
                
                // Update the visualization
                updateVisualization()
                
                // Show effect animation
                animateCardEffect(card, targetNodeID: nodeID)
                
                // Check for special node effects
                handleNodeArrival(at: nodeID)
            }
        }
        
        // Exit targeting mode
        handView.exitTargetingMode()
        clearNodeHighlights()
        targetableNodes.removeAll()
    }
    
    // MARK: - Node Arrival Handling
    
    private func handleNodeArrival(at nodeID: String) {
        // Get the node data
        guard let node = celestialRealm.nodes.first(where: { $0.id == nodeID }) else { return }
        
        // Process based on node type
        switch node.nodeType {
        case .battle(let difficulty, let enemyType):
            // Show difficulty level and opponent popup
            showBattlePopup(difficulty: difficulty, enemyType: enemyType, nodeID: nodeID)
            
        case .cardRefinery:
            // Show card refinement UI
            showRefineryPopup(nodeID: nodeID)
            
        case .narrative(let dialogueID, let character):
            // Show narrative dialogue
            showNarrativePopup(character: character, dialogueID: dialogueID, nodeID: nodeID)
            
        case .shop:
            // Show shop interface
            showShopPopup(nodeID: nodeID)
            
        case .mystery:
            // Reveal random effect
            revealMysteryNode(nodeID: nodeID)
            
        case .nexus:
            // Return to hub functionality
            showNexusPopup()
        }
    }
    
    private func showPopup(title: String, description: String, buttonText: String = "Continue", callback: @escaping () -> Void) {
        // Create popup container
        let popup = SKNode()
        popup.name = "nodePopup"
        popup.zPosition = 2000
        
        // Semi-transparent background overlay
        let overlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        overlay.fillColor = SKColor.black.withAlphaComponent(0.5)
        overlay.strokeColor = .clear
        overlay.zPosition = 1999
        popup.addChild(overlay)
        
        // Calculate vertical position to avoid hand view
        let handViewHeight: CGFloat = 200  // Height of hand view
        let verticalOffset: CGFloat = 50  // Additional offset from hand view
        let popupHeight: CGFloat = 200
        let verticalCenter = size.height/2 - handViewHeight/2 - verticalOffset
        
        // Popup panel
        let panel = SKShapeNode(rectOf: CGSize(width: 300, height: popupHeight), cornerRadius: 15)
        panel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.9)
        panel.strokeColor = .white
        panel.lineWidth = 2
        panel.position = CGPoint(x: size.width/2, y: verticalCenter)
        popup.addChild(panel)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "Copperplate")
        titleLabel.text = title
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width/2, y: verticalCenter + 70)
        popup.addChild(titleLabel)
        
        // Description
        let descLabel = SKLabelNode(fontNamed: "Copperplate")
        descLabel.text = description
        descLabel.fontSize = 18
        descLabel.fontColor = .white
        descLabel.preferredMaxLayoutWidth = 280
        descLabel.numberOfLines = 0
        descLabel.position = CGPoint(x: size.width/2, y: verticalCenter)
        descLabel.verticalAlignmentMode = .center
        popup.addChild(descLabel)
        
        // Continue button
        let buttonBg = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 10)
        buttonBg.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        buttonBg.strokeColor = .white
        buttonBg.position = CGPoint(x: size.width/2, y: verticalCenter - 70)
        buttonBg.name = "popupButton"
        popup.addChild(buttonBg)
        
        let buttonLabel = SKLabelNode(fontNamed: "Copperplate")
        buttonLabel.text = buttonText
        buttonLabel.fontSize = 18
        buttonLabel.fontColor = .white
        buttonLabel.position = buttonBg.position
        buttonLabel.verticalAlignmentMode = .center
        popup.addChild(buttonLabel)
        
        // Add popup with animation
        popup.alpha = 0
        addChild(popup)
        popup.run(SKAction.fadeIn(withDuration: 0.3))
        
        // Store callback for button press
        popup.userData = NSMutableDictionary()
        popup.userData?.setValue(callback, forKey: "callback")
    }
    
    private func dismissPopup() {
        if let popup = childNode(withName: "nodePopup") {
            popup.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    private func showBattlePopup(difficulty: Int, enemyType: String, nodeID: String) {
        let difficultyText = String(repeating: "⭐️", count: difficulty)
        
        showPopup(
            title: "Battle: \(enemyType)",
            description: "Difficulty: \(difficultyText)\n\nPrepare to face a \(enemyType) in combat!",
            buttonText: "Begin Battle"
        ) {
            // Transition to battle scene would go here
            self.dismissExploration()
        }
    }
    
    private func showRefineryPopup(nodeID: String) {
        showPopup(
            title: "Card Refinery",
            description: "Here you can upgrade and modify your cards to create more powerful combinations.",
            buttonText: "Continue"
        ) {
            // Show card selection interface would go here
            self.dismissPopup()
        }
    }
    
    private func showNarrativePopup(character: String, dialogueID: String, nodeID: String) {
        // Get dialogue based on ID (placeholder for now)
        let dialogue = "Greetings, traveler. I am \(character). The balance between Dawn, Dusk, and Night grows ever more precarious. Your mastery of the cards may be our only hope..."
        
        showPopup(
            title: character,
            description: dialogue,
            buttonText: "Continue"
        ) {
            self.dismissPopup()
        }
    }
    
    private func showShopPopup(nodeID: String) {
        showPopup(
            title: "Merchant",
            description: "Welcome to my humble shop! I have rare cards and resources that might aid you on your journey.",
            buttonText: "Browse Wares"
        ) {
            // Show shop interface would go here
            self.dismissPopup()
        }
    }
    
    private func revealMysteryNode(nodeID: String) {
        // Random mystery effect
        let effects = [
            "You found a cache of resources! +10 Essence.",
            "An ancient card reveals itself to you. Added to your collection.",
            "The node seems dormant. Nothing happens.",
            "A strange energy fills you. Your next battle will start with 5 banked power.",
            "The mists part to reveal a hidden path. A new area is visible on your map."
        ]
        
        let randomEffect = effects.randomElement() ?? effects[0]
        
        showPopup(
            title: "Mystery Node",
            description: randomEffect,
            buttonText: "Continue"
        ) {
            self.dismissPopup()
        }
    }
    
    private func showNexusPopup() {
        showPopup(
            title: "Nexus",
            description: "You have returned to the central nexus. From here, all realms are accessible.",
            buttonText: "Continue"
        ) {
            self.dismissPopup()
        }
    }
    
    private func showHelpOverlay() {
        // Create help overlay
        let overlay = SKNode()
        overlay.name = "helpOverlay"
        overlay.zPosition = 2000
        
        // Background
        let bg = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        bg.fillColor = SKColor.black.withAlphaComponent(0.7)
        bg.strokeColor = .clear
        overlay.addChild(bg)
        
        // Content panel
        let panel = SKShapeNode(rectOf: CGSize(width: size.width - 80, height: size.height - 120), cornerRadius: 15)
        panel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.9)
        panel.strokeColor = .white
        panel.lineWidth = 2
        panel.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.addChild(panel)
        
        // Title
        let title = SKLabelNode(fontNamed: "Copperplate")
        title.text = "Exploration Help"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: size.width/2, y: size.height - 80)
        overlay.addChild(title)
        
        // Help content
        let helpText = [
            "Navigation:",
            "• Drag to pan the map",
            "• Pinch to zoom in and out",
            "• Tap a node to view details or travel there",
            "",
            "Exploration Cards:",
            "• Path cards let you move to connected nodes",
            "• Jump cards move you to specific realm nodes",
            "• Reveal cards uncover hidden areas",
            "• Phase cards shift the realm phase",
            "",
            "Realms:",
            "• Dawn: Inner realm, balanced encounters",
            "• Dusk: Middle realm, moderate challenge",
            "• Night: Outer realm, highest risk/reward",
            "",
            "Node Types:",
            "• Battle: Test your deck against opponents",
            "• Card Refinery: Upgrade your cards",
            "• Narrative: Learn the story and lore",
            "• Shop: Purchase new cards and items",
            "• Mystery: Unknown effects until visited",
            "• Nexus: Central hub and travel point"
        ]
        
        // Create scrollable content
        let contentNode = SKNode()
        var yPosition: CGFloat = panel.frame.height/2 - 60
        let lineHeight: CGFloat = 26
        
        for (index, line) in helpText.enumerated() {
            let lineLabel = SKLabelNode(fontNamed: "Copperplate")
            lineLabel.text = line
            lineLabel.fontSize = 18
            lineLabel.fontColor = .white
            lineLabel.horizontalAlignmentMode = .left
            lineLabel.verticalAlignmentMode = .center
            lineLabel.position = CGPoint(x: -panel.frame.width/2 + 40, y: yPosition)
            
            // Make headers bolder
            if line.hasSuffix(":") {
                lineLabel.fontColor = SKColor(red: 0.9, green: 0.9, blue: 0.3, alpha: 1.0)
                lineLabel.fontSize = 20
            }
            
            contentNode.addChild(lineLabel)
            yPosition -= lineHeight
        }
        
        panel.addChild(contentNode)
        
        // Close button
        let closeButton = SKShapeNode(circleOfRadius: 20)
        closeButton.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.8)
        closeButton.strokeColor = .white
        closeButton.lineWidth = 2
        closeButton.position = CGPoint(x: size.width - 60, y: size.height - 60)
        closeButton.name = "closeHelpButton"
        overlay.addChild(closeButton)
        
        let closeLabel = SKLabelNode(fontNamed: "Copperplate")
        closeLabel.text = "×"
        closeLabel.fontSize = 26
        closeLabel.fontColor = .white
        closeLabel.verticalAlignmentMode = .center
        closeLabel.horizontalAlignmentMode = .center
        closeLabel.position = closeButton.position
        overlay.addChild(closeLabel)
        
        // Add to scene with animation
        overlay.alpha = 0
        addChild(overlay)
        overlay.run(SKAction.fadeIn(withDuration: 0.3))
        
        // Add touch handler for close button
        bg.name = "closeHelpButton"
    }
    
    // MARK: - Dismiss Exploration
    
    private func dismissExploration() {
        // Ensure we're on the main thread
        DispatchQueue.main.async {
            // Find the view controller
            if let viewController = self.view?.window?.rootViewController {
                // Check what kind of view controller we have
                if let explorationVC = viewController as? EnhancedExplorationViewController {
                    explorationVC.returnToGame()
                }
                else if let navigationController = viewController as? UINavigationController,
                        let explorationVC = navigationController.topViewController as? EnhancedExplorationViewController {
                    explorationVC.returnToGame()
                }
                else if let tabController = viewController as? UITabBarController,
                        let explorationVC = tabController.selectedViewController as? EnhancedExplorationViewController {
                    explorationVC.returnToGame()
                }
                else if let presentedVC = viewController.presentedViewController as? EnhancedExplorationViewController {
                    presentedVC.returnToGame()
                }
                else {
                    viewController.dismiss(animated: true)
                }
            }
        }
    }
    
    // MARK: - Animation Effects
    
    private func animateCardEffect(
        _ card: ExplorationCard,
        targetNodeID: String
    ) {
        // Create an effect based on the card type
        switch card.cardType {
        case .path:
            animatePathEffect(to: targetNodeID)
            
        case .jump:
            animateJumpEffect(to: targetNodeID)
            
        case .reveal(let radius):
            animateRevealEffect(radius: radius)
            
        case .phase(let newPhase):
            animatePhaseShift(to: newPhase)
            
        case .special:
            animateSpecialEffect(card)
        }
    }
    
    private func createDashedLine(from startPoint: CGPoint, to endPoint: CGPoint, dashLength: CGFloat = 4, gapLength: CGFloat = 4) -> SKNode {
        let container = SKNode()
        
        // Calculate the line properties
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let length = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)
        
        // Calculate number of segments needed
        let dashCount = Int(length / (dashLength + gapLength))
        
        // Create dash segments
        for i in 0..<dashCount {
            let dash = SKShapeNode(rectOf: CGSize(width: dashLength, height: 2))
            dash.fillColor = .white
            dash.strokeColor = .clear
            
            // Position this dash segment along the line
            let startDistance = CGFloat(i) * (dashLength + gapLength)
            let xPos = startPoint.x + cos(angle) * (startDistance + dashLength/2)
            let yPos = startPoint.y + sin(angle) * (startDistance + dashLength/2)
            
            dash.position = CGPoint(x: xPos, y: yPos)
            dash.zRotation = angle
            
            container.addChild(dash)
        }
        
        return container
    }
    
    private func animatePathEffect(to targetNodeID: String) {
        guard let targetNode = nodeSprites[targetNodeID],
              let currentNode = nodeSprites[celestialRealm.currentNodeID] else { return }
        
        // Create a dashed line between current and target nodes
        let dashedLine = createDashedLine(from: currentNode.position, to: targetNode.position)
        dashedLine.alpha = 0
        dashedLine.zPosition = 100
        worldContainer.addChild(dashedLine)
        
        // Animate the line
        dashedLine.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        // Create moving particle along path
        let particle = SKShapeNode(circleOfRadius: 5)
        particle.fillColor = .white
        particle.strokeColor = .clear
        particle.position = currentNode.position
        particle.zPosition = 101
        worldContainer.addChild(particle)
        
        // Move particle along path
        particle.run(SKAction.sequence([
            SKAction.move(to: targetNode.position, duration: 0.8),
            SKAction.removeFromParent()
        ]))
    }
    
    private func animateJumpEffect(to targetNodeID: String) {
        guard let targetNode = nodeSprites[targetNodeID],
              let currentNode = nodeSprites[celestialRealm.currentNodeID] else { return }
        
        // Create a teleport flash effect at current location
        let flash1 = SKShapeNode(circleOfRadius: 30)
        flash1.position = currentNode.position
        flash1.fillColor = .white
        flash1.strokeColor = .clear
        flash1.alpha = 0
        flash1.zPosition = 100
        worldContainer.addChild(flash1)
        
        // Create a teleport flash effect at target location
        let flash2 = SKShapeNode(circleOfRadius: 30)
        flash2.position = targetNode.position
        flash2.fillColor = .white
        flash2.strokeColor = .clear
        flash2.alpha = 0
        flash2.zPosition = 100
        worldContainer.addChild(flash2)
        
        // Animate departure flash
        flash1.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        
        // Animate arrival flash with delay
        flash2.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
    }
    
    private func animateRevealEffect(radius: Int) {
        // Get current node position
        guard let currentNode = nodeSprites[celestialRealm.currentNodeID] else { return }
        
        // Create an expanding circle effect
        let revealCircle = SKShapeNode(circleOfRadius: 10)
        revealCircle.position = currentNode.position
        revealCircle.fillColor = .clear
        revealCircle.strokeColor = .white
        revealCircle.lineWidth = 2
        revealCircle.zPosition = 100
        worldContainer.addChild(revealCircle)
        
        // Animate the circle expanding to the reveal radius
        let targetRadius = CGFloat(radius * 60)
        revealCircle.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: targetRadius / 10, duration: 0.8),
                SKAction.fadeAlpha(to: 0.0, duration: 0.8)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Add sparkle effects to newly revealed nodes
        for (_, node) in nodeSprites {
            // Calculate distance from current node
            let dx = node.position.x - currentNode.position.x
            let dy = node.position.y - currentNode.position.y
            let distance = sqrt(dx*dx + dy*dy)
            
            // If within reveal radius, add sparkle
            if distance <= targetRadius {
                let sparkle = SKShapeNode(circleOfRadius: 3)
                sparkle.fillColor = .white
                sparkle.strokeColor = .clear
                sparkle.alpha = 0.8
                sparkle.position = node.position
                sparkle.zPosition = 101
                
                // Add simple animation
                sparkle.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 1.0),
                    SKAction.removeFromParent()
                ]))
                
                worldContainer.addChild(sparkle)
            }
        }
    }
    
    private func animatePhaseShift(to newPhase: Realm) {
        // Create a full-screen flash with the new phase color
        let flash = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        flash.fillColor = newPhase.color.withAlphaComponent(0.3)
        flash.strokeColor = .clear
        flash.alpha = 0
        flash.zPosition = 900
        
        addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        // Update realm boundary colors
        if let container = childNode(withName: "worldContainer") {
            for child in container.children {
                if let boundary = child as? SKShapeNode,
                   boundary.name?.contains("Boundary") == true {
                    let realmName = boundary.name?.replacingOccurrences(of: "Boundary", with: "")
                    if realmName?.lowercased() == newPhase.rawValue.lowercased() {
                        // Highlight active realm boundary
                        boundary.strokeColor = newPhase.color
                        boundary.glowWidth = 10
                        boundary.run(SKAction.sequence([
                            SKAction.fadeAlpha(to: 0.8, duration: 0.3),
                            SKAction.fadeAlpha(to: 0.5, duration: 0.3)
                        ]))
                    } else {
                        // Dim other realm boundaries
                        if let realm = Realm(rawValue: realmName?.lowercased() ?? "") {
                            boundary.strokeColor = realm.color.withAlphaComponent(0.3)
                            boundary.glowWidth = 0
                        }
                    }
                }
            }
        }
    }
    
    private func animateSpecialEffect(_ card: ExplorationCard) {
        // Handle different special effects
        switch card.cardType {
        case .special(let effect):
            if effect == "teleport" {
                // Teleport effect similar to jump
                animateJumpEffect(to: celestialRealm.currentNodeID)
            } else if effect == "reveal_realm" {
                // Cosmic sight effect that reveals all nodes in current realm
                let revealColor = celestialRealm.currentPhase.color
                
                let flash = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                flash.fillColor = revealColor.withAlphaComponent(0.2)
                flash.strokeColor = .clear
                flash.alpha = 0
                flash.zPosition = 500
                addChild(flash)
                
                flash.run(SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.removeFromParent()
                ]))
                
                // Add sparkles to all nodes in current realm
                for (_, node) in nodeSprites {
                    let sparkle = SKShapeNode(circleOfRadius: 3)
                    sparkle.fillColor = revealColor
                    sparkle.strokeColor = .clear
                    sparkle.alpha = 0.8
                    sparkle.position = node.position
                    sparkle.zPosition = 101
                    
                    sparkle.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 1.0),
                        SKAction.removeFromParent()
                    ]))
                    
                    worldContainer.addChild(sparkle)
                }
            }
        default:
            break
        }
    }
    
    // MARK: - Override Parent Methods
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
    }
}
