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
        
        // Add return button
        setupReturnButton()
        
        // Add zoom controls
        setupZoomControls()

        // Apply initial zoom - start with the world a bit more zoomed in
            if let container = childNode(withName: "worldContainer") {
                // Scale the world container to make everything bigger at start
                // This value should be adjusted based on testing
                container.setScale(1.3) // Start 30% larger than default
            }

    }
    
    private func setupExplorationHand() {
        // Create hand view at the bottom of the screen
        handView = ExplorationHandView()
        handView.position = CGPoint(x: size.width/2, y: 100)
        handView.delegate = self
        handView.zPosition = 1000
        addChild(handView)
        
        // Update with current cards
        updateHandView()
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
        // Position much lower on screen (was 30px from top)
        returnButton.position = CGPoint(x: size.width - 90, y: size.height - 80)
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

    private func setupZoomControls() {
        // Position zoom controls lower on the screen
        
        // Add zoom in button - moved down 50px
        let zoomInButton = SKShapeNode(circleOfRadius: 20)
        zoomInButton.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        zoomInButton.strokeColor = .white
        zoomInButton.lineWidth = 2
        zoomInButton.position = CGPoint(x: 40, y: size.height - 90) // Changed from 40 to 90
        zoomInButton.name = "zoomInButton"
        zoomInButton.zPosition = 1100
        
        let zoomInLabel = SKLabelNode(fontNamed: "Copperplate")
        zoomInLabel.text = "+"
        zoomInLabel.fontSize = 24
        zoomInLabel.fontColor = .white
        zoomInLabel.verticalAlignmentMode = .center
        zoomInLabel.horizontalAlignmentMode = .center
        zoomInLabel.position = zoomInButton.position
        zoomInLabel.zPosition = 1100
        
        // Add zoom out button - moved down 50px
        let zoomOutButton = SKShapeNode(circleOfRadius: 20)
        zoomOutButton.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        zoomOutButton.strokeColor = .white
        zoomOutButton.lineWidth = 2
        zoomOutButton.position = CGPoint(x: 40, y: size.height - 140) // Changed from 90 to 140
        zoomOutButton.name = "zoomOutButton"
        zoomOutButton.zPosition = 1100
        
        let zoomOutLabel = SKLabelNode(fontNamed: "Copperplate")
        zoomOutLabel.text = "−"
        zoomOutLabel.fontSize = 24
        zoomOutLabel.fontColor = .white
        zoomOutLabel.verticalAlignmentMode = .center
        zoomOutLabel.horizontalAlignmentMode = .center
        zoomOutLabel.position = zoomOutButton.position
        zoomOutLabel.zPosition = 1100
        
        addChild(zoomInButton)
        addChild(zoomInLabel)
        addChild(zoomOutButton)
        addChild(zoomOutLabel)
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
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if return button was tapped
        if let returnButton = childNode(withName: "returnButton"), returnButton.contains(location) {
            dismissExploration()
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
            for (nodeID, sprite) in nodeSprites {
                if sprite.contains(location) && targetableNodes.contains(nodeID) {
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
    
    // MARK: - Zoom Handling
    
    private func handleZoomIn() {
        // Scale up all node layers by 10%
        let scaleAction = SKAction.scale(by: 1.1, duration: 0.3)
        
        backgroundLayer.run(scaleAction)
        dawnLayer.run(scaleAction)
        duskLayer.run(scaleAction)
        nightLayer.run(scaleAction)
        connectionLayer.run(scaleAction)
    }
    
    private func handleZoomOut() {
        // Scale down all node layers by 10%
        let scaleAction = SKAction.scale(by: 0.9, duration: 0.3)
        
        backgroundLayer.run(scaleAction)
        dawnLayer.run(scaleAction)
        duskLayer.run(scaleAction)
        nightLayer.run(scaleAction)
        connectionLayer.run(scaleAction)
    }
    
    // MARK: - Targeting Visualization
    
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
        
        // Popup panel
        let panel = SKShapeNode(rectOf: CGSize(width: 300, height: 200), cornerRadius: 15)
        panel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.9)
        panel.strokeColor = .white
        panel.lineWidth = 2
        panel.position = CGPoint(x: size.width/2, y: size.height/2)
        popup.addChild(panel)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "Copperplate")
        titleLabel.text = title
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 70)
        popup.addChild(titleLabel)
        
        // Description
        let descLabel = SKLabelNode(fontNamed: "Copperplate")
        descLabel.text = description
        descLabel.fontSize = 18
        descLabel.fontColor = .white
        descLabel.preferredMaxLayoutWidth = 280
        descLabel.numberOfLines = 0
        descLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        descLabel.verticalAlignmentMode = .center
        popup.addChild(descLabel)
        
        // Continue button
        let buttonBg = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 10)
        buttonBg.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        buttonBg.strokeColor = .white
        buttonBg.position = CGPoint(x: size.width/2, y: size.height/2 - 70)
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
    
    // MARK: - Dismiss Exploration
    
    private func dismissExploration() {
        // Add print statements to debug the flow
        print("Starting dismissExploration...")
        
        // Ensure we're on the main thread
        DispatchQueue.main.async {
            print("In main thread callback...")
            
            // Find the view controller
            if let viewController = self.view?.window?.rootViewController {
                print("Found root view controller: \(type(of: viewController))")
                
                // Check what kind of view controller we have
                if let explorationVC = viewController as? ExplorationViewController {
                    print("Found ExplorationViewController, calling returnToGame")
                    explorationVC.returnToGame()
                }
                else if let navigationController = viewController as? UINavigationController,
                        let explorationVC = navigationController.topViewController as? ExplorationViewController {
                    print("Found ExplorationViewController in NavigationController, calling returnToGame")
                    explorationVC.returnToGame()
                }
                else if let tabController = viewController as? UITabBarController,
                        let explorationVC = tabController.selectedViewController as? ExplorationViewController {
                    print("Found ExplorationViewController in TabController, calling returnToGame")
                    explorationVC.returnToGame()
                }
                else if let presentedVC = viewController.presentedViewController as? ExplorationViewController {
                    print("Found ExplorationViewController as presented, calling returnToGame")
                    presentedVC.returnToGame()
                }
                else {
                    print("Could not find ExplorationViewController, trying to dismiss directly")
                    viewController.dismiss(animated: true)
                }
            } else {
                print("Could not find view controller")
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
        addChild(dashedLine)
        
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
        addChild(particle)
        
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
        addChild(flash1)
        
        // Create a teleport flash effect at target location
        let flash2 = SKShapeNode(circleOfRadius: 30)
        flash2.position = targetNode.position
        flash2.fillColor = .white
        flash2.strokeColor = .clear
        flash2.alpha = 0
        addChild(flash2)
        
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
        revealCircle.zPosition = 500
        addChild(revealCircle)
        
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
                let sparkle = SKEmitterNode()
                sparkle.particleTexture = SKTexture(imageNamed: "spark")
                sparkle.particleBirthRate = 20
                sparkle.numParticlesToEmit = 20
                sparkle.particleLifetime = 1.0
                sparkle.particleScale = 0.3
                sparkle.particleScaleRange = 0.2
                sparkle.particleColor = .white
                sparkle.particleColorBlendFactor = 1.0
                sparkle.particleSpeed = 10
                sparkle.particleSpeedRange = 5
                sparkle.emissionAngle = 0
                sparkle.emissionAngleRange = .pi * 2
                sparkle.particleAlpha = 0.8
                sparkle.particleAlphaRange = 0.2
                sparkle.particleRotation = 0
                sparkle.particleRotationRange = .pi * 2
                
                // If texture not available, use a simple shape
                if sparkle.particleTexture == nil {
                    let particle = SKShapeNode(circleOfRadius: 3)
                    particle.fillColor = .white
                    particle.strokeColor = .clear
                    particle.alpha = 0.8
                    node.addChild(particle)
                    
                    particle.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 1.0),
                        SKAction.removeFromParent()
                    ]))
                } else {
                    node.addChild(sparkle)
                    sparkle.run(SKAction.sequence([
                        SKAction.wait(forDuration: 1.0),
                        SKAction.removeFromParent()
                    ]))
                }
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
                    node.addChild(sparkle)
                    
                    sparkle.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 1.0),
                        SKAction.removeFromParent()
                    ]))
                }
            }
        default:
            break
        }
    }
}
