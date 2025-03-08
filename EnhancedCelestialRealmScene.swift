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
        setupEnhancedUI()
        
        // Clean up any overlapping UI
        cleanupOverlappingUI()
        
        // Add navigation features
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
    
    override func updateVisualization() {
            super.updateVisualization()
            updateRealmIndicators()
            
            // Also update the phase panel
            if let phasePanel = uiLayer.childNode(withName: "phasePanel") as? SKShapeNode {
                phasePanel.fillColor = celestialRealm.currentPhase.color.withAlphaComponent(0.3)
                phasePanel.strokeColor = celestialRealm.currentPhase.color
            }
            
            if let phaseLabel = uiLayer.childNode(withName: "phaseLabel") as? SKLabelNode {
                phaseLabel.text = "Current Phase: \(celestialRealm.currentPhase.rawValue.capitalized)"
            }
        }
    
    private func setupEnhancedUI() {
        // ---- UI LAYOUT CONFIGURATION ----
        let safeAreaTop: CGFloat = 44
        let safeAreaBottom: CGFloat = 34
        let handHeight: CGFloat = 200  // Height reserved for the hand view
        
        // Remove any old return buttons to prevent duplicates
        if let oldReturnButton = childNode(withName: "returnButton") {
            oldReturnButton.removeFromParent()
        }
        
        // ---- TOP BAR SECTION ----
        // Create a unified top bar for better organization
        let topBarHeight: CGFloat = 50
        
        let topBar = SKShapeNode(rectOf: CGSize(width: size.width, height: topBarHeight))
        topBar.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.8)
        topBar.strokeColor = .clear
        topBar.position = CGPoint(x: size.width/2, y: size.height - (topBarHeight/2 + safeAreaTop))
        topBar.name = "topBar"
        topBar.zPosition = 990
        uiLayer.addChild(topBar)
        
        // ---- PHASE INDICATOR ----
        // Phase indicator placed in center of top bar
        let phaseWidth: CGFloat = 180
        let phaseHeight: CGFloat = 36
        let phasePanel = SKShapeNode(rectOf: CGSize(width: phaseWidth, height: phaseHeight), cornerRadius: phaseHeight/2)
        phasePanel.fillColor = celestialRealm.currentPhase.color.withAlphaComponent(0.3)
        phasePanel.strokeColor = celestialRealm.currentPhase.color
        phasePanel.lineWidth = 2
        phasePanel.position = CGPoint(x: size.width/2, y: topBar.position.y)
        phasePanel.name = "phasePanel"
        phasePanel.zPosition = 991
        uiLayer.addChild(phasePanel)
        
        let phaseLabel = SKLabelNode(fontNamed: "Copperplate")
        phaseLabel.text = "Current Phase: \(celestialRealm.currentPhase.rawValue.capitalized)"
        phaseLabel.fontSize = 16
        phaseLabel.fontColor = .white
        phaseLabel.verticalAlignmentMode = .center
        phaseLabel.horizontalAlignmentMode = .center
        phaseLabel.name = "phaseLabel"
        phaseLabel.position = phasePanel.position
        phaseLabel.zPosition = 992
        uiLayer.addChild(phaseLabel)
        
        // ---- PHASE SHIFT BUTTON ----
        // Phase shift button - moved away from phase label to right side
        let buttonSize = CGSize(width: 120, height: 32)
        let shiftButton = SKShapeNode(rectOf: buttonSize, cornerRadius: buttonSize.height/2)
        shiftButton.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 0.8)
        shiftButton.strokeColor = .white
        shiftButton.lineWidth = 1.5
        
        // Position on right side with sufficient spacing from phase label
        let shiftButtonX = size.width - 80 // Adjusted to provide clear separation
        shiftButton.position = CGPoint(x: shiftButtonX, y: topBar.position.y)
        shiftButton.name = "shiftButton"
        shiftButton.zPosition = 991
        uiLayer.addChild(shiftButton)
        
        let shiftLabel = SKLabelNode(fontNamed: "Copperplate")
        shiftLabel.text = "Shift Phase"
        shiftLabel.fontSize = 14
        shiftLabel.fontColor = .white
        shiftLabel.verticalAlignmentMode = .center
        shiftLabel.position = shiftButton.position
        shiftLabel.zPosition = 992
        uiLayer.addChild(shiftLabel)
        
        // ---- RETURN BUTTON ----
        // Single unified return button with proper positioning
        let returnButton = SKShapeNode(rectOf: CGSize(width: 180, height: 40), cornerRadius: 20)
        returnButton.fillColor = SKColor(red: 0.7, green: 0.3, blue: 0.3, alpha: 0.9)
        returnButton.strokeColor = .white
        returnButton.lineWidth = 2
        
        // Position in top-left corner, safely beneath the notch
        returnButton.position = CGPoint(x: 115, y: size.height - 90)
        returnButton.name = "returnButton"
        returnButton.zPosition = 992
        
        // Return arrow icon
        let arrowNode = SKShapeNode()
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -8, y: 0))
        arrowPath.addLine(to: CGPoint(x: 8, y: 0))
        arrowPath.move(to: CGPoint(x: -4, y: 4))
        arrowPath.addLine(to: CGPoint(x: -8, y: 0))
        arrowPath.addLine(to: CGPoint(x: -4, y: -4))
        arrowNode.path = arrowPath
        arrowNode.strokeColor = .white
        arrowNode.lineWidth = 2
        arrowNode.position = CGPoint(x: -70, y: 0)
        returnButton.addChild(arrowNode)
        
        let buttonLabel = SKLabelNode(fontNamed: "Copperplate")
        buttonLabel.text = "Return to Battle"
        buttonLabel.fontSize = 16
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.position = CGPoint(x: 10, y: 0) // Offset to account for arrow
        returnButton.addChild(buttonLabel)
        
        addChild(returnButton)
        
        // Subtle pulse animation to draw attention
        returnButton.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])))
        
        // ---- REALM INDICATORS ----
        setupRealmIndicatorsPanel()
        
        // ---- BOTTOM CONTROLS SECTION ----
        // Redesign the bottom control bar to sit above the hand view
        let controlBarHeight: CGFloat = 60
        
        // Position control bar above the hand area with comfortable spacing
        let handTop = 110 + handHeight // Approximate top of hand area
        let controlBarY = handTop + controlBarHeight/2 + 15 // Position bar above hand with spacing
        
        let controlBar = SKShapeNode(rectOf: CGSize(width: size.width, height: controlBarHeight))
        controlBar.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.8)
        controlBar.strokeColor = .clear
        controlBar.position = CGPoint(x: size.width/2, y: controlBarY)
        controlBar.name = "controlBar"
        controlBar.zPosition = 990
        uiLayer.addChild(controlBar)
        
        // Zoom controls with improved positioning
        let buttonPadding: CGFloat = 80
        
        // Zoom in button (left)
        let zoomInButton = SKShapeNode(circleOfRadius: 20)
        zoomInButton.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        zoomInButton.strokeColor = .white
        zoomInButton.lineWidth = 2
        zoomInButton.position = CGPoint(x: size.width/2 - buttonPadding, y: controlBar.position.y)
        zoomInButton.name = "zoomInButton"
        zoomInButton.zPosition = 991
        uiLayer.addChild(zoomInButton)
        
        let zoomInLabel = SKLabelNode(fontNamed: "Copperplate")
        zoomInLabel.text = "+"
        zoomInLabel.fontSize = 24
        zoomInLabel.fontColor = .white
        zoomInLabel.verticalAlignmentMode = .center
        zoomInLabel.horizontalAlignmentMode = .center
        zoomInLabel.position = zoomInButton.position
        zoomInLabel.zPosition = 992
        uiLayer.addChild(zoomInLabel)
        
        // Zoom out button (right)
        let zoomOutButton = SKShapeNode(circleOfRadius: 20)
        zoomOutButton.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        zoomOutButton.strokeColor = .white
        zoomOutButton.lineWidth = 2
        zoomOutButton.position = CGPoint(x: size.width/2 + buttonPadding, y: controlBar.position.y)
        zoomOutButton.name = "zoomOutButton"
        zoomOutButton.zPosition = 991
        uiLayer.addChild(zoomOutButton)
        
        let zoomOutLabel = SKLabelNode(fontNamed: "Copperplate")
        zoomOutLabel.text = "−" // en dash for better appearance
        zoomOutLabel.fontSize = 24
        zoomOutLabel.fontColor = .white
        zoomOutLabel.verticalAlignmentMode = .center
        zoomOutLabel.horizontalAlignmentMode = .center
        zoomOutLabel.position = zoomOutButton.position
        zoomOutLabel.zPosition = 992
        uiLayer.addChild(zoomOutLabel)
        
        // Reset view button (center)
        let resetButton = SKShapeNode(rectOf: CGSize(width: 120, height: 36), cornerRadius: 18)
        resetButton.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        resetButton.strokeColor = .white
        resetButton.lineWidth = 1.5
        resetButton.position = CGPoint(x: size.width/2, y: controlBar.position.y)
        resetButton.name = "resetViewButton"
        resetButton.zPosition = 991
        uiLayer.addChild(resetButton)
        
        let resetLabel = SKLabelNode(fontNamed: "Copperplate")
        resetLabel.text = "Reset View"
        resetLabel.fontSize = 14
        resetLabel.fontColor = .white
        resetLabel.verticalAlignmentMode = .center
        resetLabel.horizontalAlignmentMode = .center
        resetLabel.position = resetButton.position
        resetLabel.zPosition = 992
        uiLayer.addChild(resetLabel)
    }
    
    // Enhance existing phase indicator with better positioning and styling
        private func enhancePhaseIndicator() {
            // Remove existing phase indicator
            if let oldIndicator = uiLayer.childNode(withName: "phaseIndicator") {
                oldIndicator.removeFromParent()
            }
            
            // Remove existing shift button
            if let oldShiftButton = uiLayer.childNode(withName: "shiftButton") {
                oldShiftButton.removeFromParent()
            }
            
            // Create new safe area-aware phase indicator
            let safeAreaTop: CGFloat = 44
            let topBarHeight: CGFloat = 50
            
            // Phase indicator redesigned as a pill with realm color
            let phaseWidth: CGFloat = 180
            let phaseHeight: CGFloat = 36
            let phasePanel = SKShapeNode(rectOf: CGSize(width: phaseWidth, height: phaseHeight), cornerRadius: phaseHeight/2)
            phasePanel.fillColor = celestialRealm.currentPhase.color.withAlphaComponent(0.3)
            phasePanel.strokeColor = celestialRealm.currentPhase.color
            phasePanel.lineWidth = 2
            phasePanel.position = CGPoint(x: size.width/2, y: size.height - (topBarHeight/2 + safeAreaTop))
            phasePanel.name = "phasePanel"
            phasePanel.zPosition = 990
            uiLayer.addChild(phasePanel)
            
            // Phase label with improved font and contrast
            let phaseLabel = SKLabelNode(fontNamed: "Copperplate")
            phaseLabel.text = "Current Phase: \(celestialRealm.currentPhase.rawValue.capitalized)"
            phaseLabel.fontSize = 16
            phaseLabel.fontColor = .white
            phaseLabel.verticalAlignmentMode = .center
            phaseLabel.horizontalAlignmentMode = .center
            phaseLabel.name = "phaseLabel"
            phaseLabel.position = phasePanel.position
            phaseLabel.zPosition = 991
            uiLayer.addChild(phaseLabel)
            
            // Create phase shift button (positioned safely)
            let buttonSize = CGSize(width: 120, height: 32)
            let shiftButton = SKShapeNode(rectOf: buttonSize, cornerRadius: buttonSize.height/2)
            shiftButton.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 0.8)
            shiftButton.strokeColor = .white
            shiftButton.lineWidth = 1.5
            
            // Position on right side with safe margin
            shiftButton.position = CGPoint(x: size.width - 80, y: phasePanel.position.y)
            shiftButton.name = "shiftButton"
            shiftButton.zPosition = 990
            uiLayer.addChild(shiftButton)
            
            let shiftLabel = SKLabelNode(fontNamed: "Copperplate")
            shiftLabel.text = "Shift Phase"
            shiftLabel.fontSize = 14
            shiftLabel.fontColor = .white
            shiftLabel.verticalAlignmentMode = .center
            shiftLabel.position = shiftButton.position
            shiftLabel.zPosition = 991
            uiLayer.addChild(shiftLabel)
        }
        
        // Improve the positioning and styling of navigation controls
        private func enhanceNavigationControls() {
            // Remove existing navigation controls
            uiLayer.childNode(withName: "zoomInButton")?.removeFromParent()
            uiLayer.childNode(withName: "zoomOutButton")?.removeFromParent()
            uiLayer.childNode(withName: "resetViewButton")?.removeFromParent()
            
            // Safe area insets
            let safeAreaBottom: CGFloat = 34
            
            // Create a bottom control bar
            let controlBarHeight: CGFloat = 60
            let controlBar = SKShapeNode(rectOf: CGSize(width: size.width, height: controlBarHeight))
            controlBar.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.8)
            controlBar.strokeColor = .clear
            controlBar.position = CGPoint(x: size.width/2, y: controlBarHeight/2 + safeAreaBottom)
            controlBar.name = "controlBar"
            controlBar.zPosition = 990
            uiLayer.addChild(controlBar)
            
            // Zoom controls with improved styling
            let buttonPadding: CGFloat = 80
            
            // Zoom in button (left)
            let zoomInButton = SKShapeNode(circleOfRadius: 20)
            zoomInButton.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
            zoomInButton.strokeColor = .white
            zoomInButton.lineWidth = 2
            zoomInButton.position = CGPoint(x: size.width/2 - buttonPadding, y: controlBar.position.y)
            zoomInButton.name = "zoomInButton"
            zoomInButton.zPosition = 991
            uiLayer.addChild(zoomInButton)
            
            let zoomInLabel = SKLabelNode(fontNamed: "Copperplate")
            zoomInLabel.text = "+"
            zoomInLabel.fontSize = 24
            zoomInLabel.fontColor = .white
            zoomInLabel.verticalAlignmentMode = .center
            zoomInLabel.horizontalAlignmentMode = .center
            zoomInLabel.position = zoomInButton.position
            zoomInLabel.zPosition = 992
            uiLayer.addChild(zoomInLabel)
            
            // Zoom out button (right)
            let zoomOutButton = SKShapeNode(circleOfRadius: 20)
            zoomOutButton.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
            zoomOutButton.strokeColor = .white
            zoomOutButton.lineWidth = 2
            zoomOutButton.position = CGPoint(x: size.width/2 + buttonPadding, y: controlBar.position.y)
            zoomOutButton.name = "zoomOutButton"
            zoomOutButton.zPosition = 991
            uiLayer.addChild(zoomOutButton)
            
            let zoomOutLabel = SKLabelNode(fontNamed: "Copperplate")
            zoomOutLabel.text = "−" // en dash for better appearance
            zoomOutLabel.fontSize = 24
            zoomOutLabel.fontColor = .white
            zoomOutLabel.verticalAlignmentMode = .center
            zoomOutLabel.horizontalAlignmentMode = .center
            zoomOutLabel.position = zoomOutButton.position
            zoomOutLabel.zPosition = 992
            uiLayer.addChild(zoomOutLabel)
            
            // Reset view button (center)
            let resetButton = SKShapeNode(rectOf: CGSize(width: 120, height: 36), cornerRadius: 18)
            resetButton.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
            resetButton.strokeColor = .white
            resetButton.lineWidth = 1.5
            resetButton.position = CGPoint(x: size.width/2, y: controlBar.position.y)
            resetButton.name = "resetViewButton"
            resetButton.zPosition = 991
            uiLayer.addChild(resetButton)
            
            let resetLabel = SKLabelNode(fontNamed: "Copperplate")
            resetLabel.text = "Reset View"
            resetLabel.fontSize = 14
            resetLabel.fontColor = .white
            resetLabel.verticalAlignmentMode = .center
            resetLabel.horizontalAlignmentMode = .center
            resetLabel.position = resetButton.position
            resetLabel.zPosition = 992
            uiLayer.addChild(resetLabel)
        }
    
    // New method to add realm indicators showing current realm colors/status
      private func setupRealmIndicatorsPanel() {
          // Create panel on left side
          let panelWidth: CGFloat = 120
          let panelHeight: CGFloat = 105 // Height for 3 realms
          let panelX: CGFloat = 75
          let panelY: CGFloat = size.height - 120 // Below notch/pill
          
          let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 10)
          panel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.8)
          panel.strokeColor = .white
          panel.lineWidth = 1
          panel.position = CGPoint(x: panelX, y: panelY)
          panel.name = "realmPanel"
          panel.zPosition = 990
          addChild(panel)
          
          // Panel title
          let titleLabel = SKLabelNode(fontNamed: "Copperplate")
          titleLabel.text = "Realms"
          titleLabel.fontSize = 14
          titleLabel.fontColor = .white
          titleLabel.position = CGPoint(x: panelX, y: panelY + panelHeight/2 - 14)
          titleLabel.zPosition = 991
          addChild(titleLabel)
          
          // Add realm indicators
          let realms = Realm.allCases
          let indicatorY = panelY + panelHeight/2 - 35
          let spacing: CGFloat = 25
          
          for (index, realm) in realms.enumerated() {
              // Realm circle
              let circle = SKShapeNode(circleOfRadius: 8)
              circle.fillColor = realm.color
              circle.strokeColor = .white
              circle.lineWidth = 1
              circle.position = CGPoint(x: panelX - 40, y: indicatorY - CGFloat(index) * spacing)
              circle.zPosition = 991
              addChild(circle)
              
              // Realm name
              let nameLabel = SKLabelNode(fontNamed: "Copperplate")
              nameLabel.text = realm.rawValue.capitalized
              nameLabel.fontSize = 14
              nameLabel.fontColor = .white
              nameLabel.horizontalAlignmentMode = .left
              nameLabel.verticalAlignmentMode = .center
              nameLabel.position = CGPoint(x: panelX - 25, y: indicatorY - CGFloat(index) * spacing)
              nameLabel.zPosition = 991
              addChild(nameLabel)
              
              // Active indicator if this is the current realm
              if realm == celestialRealm.currentPhase {
                  let activeIndicator = SKShapeNode(circleOfRadius: 12)
                  activeIndicator.strokeColor = .white
                  activeIndicator.lineWidth = 1
                  activeIndicator.fillColor = .clear
                  activeIndicator.position = circle.position
                  activeIndicator.zPosition = 990
                  activeIndicator.name = "activeRealmIndicator"
                  addChild(activeIndicator)
                  
                  // Pulse animation
                  activeIndicator.run(SKAction.repeatForever(SKAction.sequence([
                      SKAction.fadeAlpha(to: 0.3, duration: 0.8),
                      SKAction.fadeAlpha(to: 1.0, duration: 0.8)
                  ])))
              }
          }
      }
      
    
   private func setupExplorationHand() {
        // Create hand view at the bottom of the screen with appropriate positioning
        handView = ExplorationHandView()
        
        // Position hand view at the bottom with safe area considerations
        let handY: CGFloat = 100 // Keep this value to maintain current layout
        handView.position = CGPoint(x: size.width/2, y: handY)
        handView.delegate = self
        handView.zPosition = 1000
        
        // Add background panel for hand view
        let handBg = SKShapeNode(rectOf: CGSize(width: size.width - 40, height: 200), cornerRadius: 15)
        handBg.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.7)
        handBg.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)
        handBg.lineWidth = 2
        handBg.position = handView.position
        handBg.zPosition = 990
        handBg.name = "handBackground" // Name it for easier reference
        addChild(handBg)
        
        addChild(handView)
        
        // Update with current cards
        updateHandView()
    }
    
    // For updating realm indicator when phase changes
        func updateRealmIndicators() {
            // Remove existing active indicator
            if let activeIndicator = childNode(withName: "activeRealmIndicator") {
                activeIndicator.removeFromParent()
            }
            
            // Add new indicator for current phase
            let realms = Realm.allCases
            let panelY = size.height - 120
            let indicatorY = panelY + 105/2 - 35
            let spacing: CGFloat = 25
            let panelX: CGFloat = 75
            
            for (index, realm) in realms.enumerated() {
                if realm == celestialRealm.currentPhase {
                    // Find circle position
                    let circlePos = CGPoint(x: panelX - 40, y: indicatorY - CGFloat(index) * spacing)
                    
                    // Add active indicator around this realm
                    let activeIndicator = SKShapeNode(circleOfRadius: 12)
                    activeIndicator.strokeColor = .white
                    activeIndicator.lineWidth = 1
                    activeIndicator.fillColor = .clear
                    activeIndicator.position = circlePos
                    activeIndicator.zPosition = 990
                    activeIndicator.name = "activeRealmIndicator"
                    addChild(activeIndicator)
                    
                    // Pulse animation
                    activeIndicator.run(SKAction.repeatForever(SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.3, duration: 0.8),
                        SKAction.fadeAlpha(to: 1.0, duration: 0.8)
                    ])))
                }
            }
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
       
    }
    
    private func setupHelpButton() {
        // Create a help button positioned in top-right corner
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
        
        // Position in top right, away from other controls
        helpButton.position = CGPoint(x: size.width - 30, y: size.height - 30)
        helpButton.name = "helpButton"
        helpButton.zPosition = 1100
        addChild(helpButton)
    }
    
    private func updateHandView() {
        handView.updateWithCards(explorationDeck.hand)
    }
    
    // Add a cleanup method to remove any problematic UI elements that might be overlapping
    private func cleanupOverlappingUI() {
        // Remove any old UI elements that might be causing issues
        childNode(withName: "//infoPanel")?.removeFromParent()
        
        // Remove any duplicate navigation controls
        for name in ["controlBar", "zoomInButton", "zoomOutButton", "resetViewButton"] {
            let nodes = children.filter { $0.name == name }
            if nodes.count > 1 {
                for i in 1..<nodes.count {
                    nodes[i].removeFromParent()
                }
            }
        }
        
        // Check for multiple return buttons
        let returnButtons = children.filter { $0.name?.contains("return") == true || $0.name?.contains("Return") == true }
        if returnButtons.count > 1 {
            for i in 1..<returnButtons.count {
                returnButtons[i].removeFromParent()
            }
        }
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
        if handleTouchesForNodeInteractions(touches, with: event) {
            return
        }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check for popups first
        if let popup = childNode(withName: "nodePopup") {
            // Convert touch location to popup's coordinate system
            let popupLocation = convert(location, to: popup)
            
            if let buttonBg = popup.childNode(withName: "popupButton") {
                // Check if the converted location is inside the button
                if buttonBg.contains(popupLocation) {
                    if let callback = popup.userData?.value(forKey: "callback") as? () -> Void {
                        callback()
                        return
                    }
                }
            }
            
            // Block further touches if popup is visible
            if popup.alpha > 0 {
                return
            }
        }
        
        // Check for UI element touches with proper coordinate conversion
        if let helpButton = childNode(withName: "helpButton"), helpButton.contains(location) {
            showHelpOverlay()
            return
        }
        
        if let returnButton = childNode(withName: "returnButton"), returnButton.contains(location) {
            dismissExploration()
            return
        }
        
        // Check for top bar UI elements
        for name in ["shiftButton", "zoomInButton", "zoomOutButton", "resetViewButton"] {
            if let button = uiLayer.childNode(withName: name),
               button.contains(convert(location, to: uiLayer)) {
                
                switch name {
                case "shiftButton":
                    // Call super's handlePhaseShift to avoid access issues
                    super.handlePhaseShift()
                    return
                case "zoomInButton":
                    handleZoomIn()
                    return
                case "zoomOutButton":
                    handleZoomOut()
                    return
                case "resetViewButton":
                    // Call super's resetView to avoid access issues
                    super.resetView()
                    return
                default:
                    break
                }
            }
        }
        
        // Check for touches on the hand
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
        
        // Otherwise, pass the touch to the parent implementation for map navigation
        super.touchesBegan(touches, with: event)
    }
    
    // Add this method to EnhancedCelestialRealmScene.swift
    override func moveToNode(_ node: WorldNode) {
        super.moveToNode(node)
        
        // After the animation completes, show the interaction screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.handleNodeArrival(at: node.id)
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
    
    func handleNodeArrival(at nodeID: String) {
        // Get the node data
        guard let node = celestialRealm.nodes.first(where: { $0.id == nodeID }) else { return }
        
        // Show the appropriate interaction screen
        showNodeInteractionScreen(for: nodeID)
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
    
    // Add a method to dismiss the exploration mode
    func dismissExploration() {
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
    
    private func animateCardEffect(_ card: ExplorationCard, targetNodeID: String) {
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
        
        // After animation completes, handle node arrival with new screens
        // Use a slight delay to allow animations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.handleNodeArrival(at: targetNodeID)
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
