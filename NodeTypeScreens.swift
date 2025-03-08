//
//  NodeTypeScreens.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/4/25.
//

import SpriteKit

// MARK: - Battle Node Screen

class BattleNodeScreen: NodeInteractionScreen {
    private let difficulty: Int
    private let enemyType: String
    
    override init(node: WorldNode, size: CGSize, parentScene: EnhancedCelestialRealmScene?) {
        // Extract battle-specific data
        guard case let .battle(difficulty, enemyType) = node.nodeType else {
            fatalError("Invalid node type for BattleNodeScreen")
        }
        self.difficulty = difficulty
        self.enemyType = enemyType
        
        super.init(node: node, size: size, parentScene: parentScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getTitle() -> String {
        return "Battle: \(enemyType)"
    }
    
    override func setupSpecificContent() {
        // Difficulty indicator
        let difficultyText = String(repeating: "⭐️", count: difficulty)
        let difficultyLabel = createInfoText(
            text: "Difficulty: \(difficultyText)",
            fontSize: 20,
            position: CGPoint(x: 0, y: 60)
        )
        contentArea.addChild(difficultyLabel)
        
        // Enemy preview
        let enemyPreview = SKShapeNode(rectOf: CGSize(width: 120, height: 180), cornerRadius: 10)
        enemyPreview.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        enemyPreview.strokeColor = .white
        enemyPreview.position = CGPoint(x: 0, y: -20)
        contentArea.addChild(enemyPreview)
        
        // Enemy icon
        let enemyIcon = SKShapeNode(circleOfRadius: 40)
        enemyIcon.fillColor = node.realm.color
        enemyIcon.strokeColor = .white
        enemyIcon.position = CGPoint(x: 0, y: 20)
        enemyPreview.addChild(enemyIcon)
        
        // Enemy type label
        let typeLabel = SKLabelNode(fontNamed: "Copperplate")
        typeLabel.text = enemyType
        typeLabel.fontSize = 16
        typeLabel.fontColor = .white
        typeLabel.position = CGPoint(x: 0, y: -40)
        enemyPreview.addChild(typeLabel)
        
        // Battle description
        let description = "Prepare to face a \(enemyType) in combat. This adversary will test your mastery of card combinations and timing."
        let descriptionText = createInfoText(
            text: description,
            maxWidth: screenWidth - 140,
            position: CGPoint(x: 0, y: -120)
        )
        contentArea.addChild(descriptionText)
        
        // Begin battle button
        let beginButton = createButton(
            text: "Begin Battle",
            size: CGSize(width: 160, height: 40),
            position: CGPoint(x: 0, y: -180)
        )
        beginButton.name = "beginBattleButton"
        contentArea.addChild(beginButton)
        
        // Add a subtle pulsing effect to the button
        beginButton.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])))
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for begin battle button touch
        if let beginButton = contentArea.childNode(withName: "beginBattleButton") {
            if beginButton.contains(convert(location, to: contentArea)) {
                // Transition to battle would happen here
                // For now, just dismiss and return to the exploration screen
                parentScene?.dismissExploration()
                return true
            }
        }
        
        return false
    }
}

// MARK: - Card Refinery Node Screen

class RefineryNodeScreen: NodeInteractionScreen {
    // Fix the title display
    override func getTitle() -> String {
        return "Card Refinery"
    }
    
    override func setupSpecificContent() {
        // Get content dimensions
        let contentWidth = contentArea.userData?.value(forKey: "contentWidth") as? CGFloat ?? 300
        let contentHeight = contentArea.userData?.value(forKey: "contentHeight") as? CGFloat ?? 400
        let scale = contentArea.userData?.value(forKey: "contentScale") as? CGFloat ?? 1.0
        
        // ---- TOP SECTION: DESCRIPTION ----
        // Position description further down from title to avoid overlap (120px from top)
        let description = "Here you can upgrade and modify your cards to create more powerful combinations."
        let descriptionText = SKLabelNode(fontNamed: "Copperplate")
        descriptionText.text = description
        descriptionText.fontSize = 14 * scale
        descriptionText.fontColor = .white
        descriptionText.preferredMaxLayoutWidth = contentWidth - 80 // Narrower width
        descriptionText.numberOfLines = 0
        descriptionText.verticalAlignmentMode = .center
        descriptionText.horizontalAlignmentMode = .center
        // Position much further down from title to avoid overlap
        descriptionText.position = CGPoint(x: 0, y: contentHeight/2 - 120)
        contentArea.addChild(descriptionText)
        
        // ---- MIDDLE SECTION: CARD SELECTION AREA ----
        // Move card selection area to middle for better balance
        let cardAreaWidth = contentWidth - 100  // Narrower to fit on screen
        let cardAreaHeight = 100 * scale
        let cardSelectionArea = SKShapeNode(rectOf: CGSize(width: cardAreaWidth, height: cardAreaHeight), cornerRadius: 10)
        cardSelectionArea.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.7)
        cardSelectionArea.strokeColor = .white
        cardSelectionArea.lineWidth = 1
        // Position in the middle area with better spacing
        cardSelectionArea.position = CGPoint(x: 0, y: contentHeight/8)
        cardSelectionArea.name = "cardSelectionArea"
        contentArea.addChild(cardSelectionArea)
        
        // Add card slot label above the slots
        let slotLabel = SKLabelNode(fontNamed: "Copperplate")
        slotLabel.text = "Select Card to Refine"
        slotLabel.fontSize = 14 * scale
        slotLabel.fontColor = .white
        slotLabel.position = CGPoint(x: 0, y: cardSelectionArea.position.y + cardAreaHeight/2 + 15)
        contentArea.addChild(slotLabel)
        
        // Add placeholder card slots - properly sized to fit within container
        let slotCount = 4 // Reduced from 5 for better spacing
        
        // Calculate slot size to ensure proper fit
        let slotPadding: CGFloat = 15  // Padding between slots
        let totalSlotWidth = cardAreaWidth - 40  // Leave 20px padding on each side
        let slotWidth = (totalSlotWidth - (slotPadding * CGFloat(slotCount - 1))) / CGFloat(slotCount)
        let slotHeight = cardAreaHeight - 20  // Leave 10px padding top and bottom
        
        // Calculate starting position
        let startX = -(totalSlotWidth / 2) + (slotWidth / 2)
        
        for i in 0..<slotCount {
            // Calculate position with proper spacing
            let x = startX + CGFloat(i) * (slotWidth + slotPadding)
            
            let cardSlot = SKShapeNode(rectOf: CGSize(width: slotWidth, height: slotHeight), cornerRadius: 8)
            cardSlot.fillColor = SKColor.darkGray.withAlphaComponent(0.3)
            cardSlot.strokeColor = .lightGray
            cardSlot.lineWidth = 1
            cardSlot.position = CGPoint(x: x, y: 0)
            cardSlot.name = "cardSlot_\(i)"
            cardSelectionArea.addChild(cardSlot)
            
            // Add + symbol to indicate it's selectable
            let plusSymbol = SKLabelNode(fontNamed: "Helvetica")
            plusSymbol.text = "+"
            plusSymbol.fontSize = 24 * scale
            plusSymbol.fontColor = .lightGray
            plusSymbol.verticalAlignmentMode = .center
            plusSymbol.position = cardSlot.position
            cardSelectionArea.addChild(plusSymbol)
        }
        
        // ---- LOWER SECTION: REFINEMENT OPTIONS ----
        // Calculate proper vertical spacing to avoid overlapping return button
        let returnButtonHeight = 40 * scale
        let returnButtonTop = -contentHeight/2 + returnButtonHeight + 30 // 30px margin
        
        // Section label positioned below card area with more space
        let optionsLabel = SKLabelNode(fontNamed: "Copperplate")
        optionsLabel.text = "Refinement Options"
        optionsLabel.fontSize = 16 * scale
        optionsLabel.fontColor = .white
        // Position halfway between card area and buttons
        optionsLabel.position = CGPoint(x: 0, y: cardSelectionArea.position.y - cardAreaHeight/2 - 30)
        contentArea.addChild(optionsLabel)
        
        // Options buttons - different colors and proper vertical positioning
        let options = ["Enhance Power", "Change Suit", "Add Effect"]
        let buttonColors = [
            SKColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 0.8), // Green
            SKColor(red: 0.2, green: 0.3, blue: 0.7, alpha: 0.8), // Blue
            SKColor(red: 0.7, green: 0.3, blue: 0.2, alpha: 0.8)  // Orange
        ]
        
        // Calculate available height for buttons
        let availableButtonHeight = abs(optionsLabel.position.y - returnButtonTop) - 50 // 50px margin
        let buttonHeight = 36 * scale
        let buttonSpacing = (availableButtonHeight - (buttonHeight * CGFloat(options.count))) / CGFloat(options.count - 1)
        
        for (i, option) in options.enumerated() {
            // Calculate text width to ensure button contains text
            let tempLabel = SKLabelNode(fontNamed: "Copperplate")
            tempLabel.text = option
            tempLabel.fontSize = 16 * scale
            let textWidth = tempLabel.frame.width
            
            // Size button based on text width
            let buttonWidth = max(150 * scale, textWidth + 40)
            
            // Calculate position for even distribution in available space
            let y = optionsLabel.position.y - 30 - (buttonHeight + buttonSpacing) * CGFloat(i)
            
            // Create button background with unique color
            let buttonBg = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
            buttonBg.fillColor = buttonColors[i]
            buttonBg.strokeColor = .white
            buttonBg.lineWidth = 1.5
            buttonBg.position = CGPoint(x: 0, y: y)
            contentArea.addChild(buttonBg)
            
            // Create button label
            let buttonLabel = SKLabelNode(fontNamed: "Copperplate")
            buttonLabel.text = option
            buttonLabel.fontSize = 16 * scale
            buttonLabel.fontColor = .white
            buttonLabel.verticalAlignmentMode = .center
            buttonLabel.position = buttonBg.position
            contentArea.addChild(buttonLabel)
            
            // Add drop shadow for better visibility
            let shadow = SKLabelNode(fontNamed: "Copperplate")
            shadow.text = option
            shadow.fontSize = 16 * scale
            shadow.fontColor = .black
            shadow.alpha = 0.5
            shadow.verticalAlignmentMode = .center
            shadow.position = CGPoint(x: buttonBg.position.x + 1, y: buttonBg.position.y - 1)
            contentArea.addChild(shadow)
            shadow.zPosition = buttonLabel.zPosition - 1
            
            // Add pulse animation to buttons
            buttonBg.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 1.0),
                SKAction.scale(to: 1.0, duration: 1.0)
            ])))
            
            // Add disabled appearance
            buttonBg.alpha = 0.6
            buttonLabel.alpha = 0.7
            shadow.alpha = 0.3
        }
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for card slot touches
        let contentLocation = convert(location, to: contentArea)
        if let cardArea = contentArea.childNode(withName: "cardSelectionArea") {
            let cardAreaLocation = convert(location, to: cardArea)
            
            for i in 0..<4 {
                if let cardSlot = cardArea.childNode(withName: "cardSlot_\(i)") {
                    if cardSlot.contains(cardAreaLocation) {
                        // Flash the card slot to indicate selection
                        let flash = SKAction.sequence([
                            SKAction.colorize(with: .white, colorBlendFactor: 0.5, duration: 0.1),
                            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                        ])
                        cardSlot.run(flash)
                        return true
                    }
                }
            }
        }
        
        return false
    }
}

// MARK: - Narrative Node Screen

class NarrativeNodeScreen: NodeInteractionScreen {
    private let character: String
    private let dialogueID: String
    private var currentDialogueIndex = 0
    private var dialogueTexts: [String] = []
    
    override init(node: WorldNode, size: CGSize, parentScene: EnhancedCelestialRealmScene?) {
        // Extract narrative-specific data
        guard case let .narrative(dialogueID, character) = node.nodeType else {
            fatalError("Invalid node type for NarrativeNodeScreen")
        }
        self.character = character
        self.dialogueID = dialogueID
        
        super.init(node: node, size: size, parentScene: parentScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getTitle() -> String {
        return character
    }
    
    override func setupSpecificContent() {
        // Character portrait
        let portraitFrame = SKShapeNode(circleOfRadius: 50)
        portraitFrame.fillColor = node.realm.color.withAlphaComponent(0.7)
        portraitFrame.strokeColor = .white
        portraitFrame.lineWidth = 2
        portraitFrame.position = CGPoint(x: -120, y: 50)
        contentArea.addChild(portraitFrame)
        
        // Character icon/silhouette
        let characterIcon = SKShapeNode(rectOf: CGSize(width: 40, height: 70))
        characterIcon.fillColor = .white
        characterIcon.strokeColor = .clear
        characterIcon.alpha = 0.5
        characterIcon.position = CGPoint(x: 0, y: -5)
        portraitFrame.addChild(characterIcon)
        
        // Character name
        let nameLabel = SKLabelNode(fontNamed: "Copperplate")
        nameLabel.text = character
        nameLabel.fontSize = 16
        nameLabel.fontColor = .white
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: -120, y: -20)
        contentArea.addChild(nameLabel)
        
        // Dialogue box
        let dialogueBox = SKShapeNode(rectOf: CGSize(width: screenWidth - 200, height: 150), cornerRadius: 10)
        dialogueBox.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.7)
        dialogueBox.strokeColor = .white
        dialogueBox.lineWidth = 1
        dialogueBox.position = CGPoint(x: 30, y: 0)
        contentArea.addChild(dialogueBox)
        
        // Set up dialogue texts based on character and realm
        setupDialogueTexts()
        
        // Initial dialogue text
        let dialogueText = SKLabelNode(fontNamed: "Copperplate")
        dialogueText.text = dialogueTexts[currentDialogueIndex]
        dialogueText.fontSize = 16
        dialogueText.fontColor = .white
        dialogueText.verticalAlignmentMode = .center
        dialogueText.horizontalAlignmentMode = .center
        dialogueText.preferredMaxLayoutWidth = screenWidth - 220
        dialogueText.numberOfLines = 0
        dialogueText.position = CGPoint(x: 30, y: 0)
        dialogueText.name = "dialogueText"
        contentArea.addChild(dialogueText)
        
        // Continue button
        let continueButton = createButton(
            text: "Continue",
            size: CGSize(width: 120, height: 36),
            position: CGPoint(x: 120, y: -100)
        )
        continueButton.name = "continueButton"
        contentArea.addChild(continueButton)
        
        // Dialog progress indicator
        updateDialogueIndicator()
    }
    
    private func setupDialogueTexts() {
        // In a real implementation, these would come from a dialogue database
        // For the prototype, generate placeholder dialogue based on character and realm
        
        switch node.realm {
        case .dawn:
            dialogueTexts = [
                "Greetings, traveler. I am \(character), guardian of the Dawn realm. The balance between the realms grows ever more precarious.",
                "The Dawn cards represent immediate power - a direct approach that can overwhelm enemies before they have time to prepare.",
                "However, one who relies solely on Dawn loses the strategic advantages offered by the other realms. True mastery comes from understanding when to use each.",
                "I sense great potential in you. Continue your journey through the celestial realms, and you may discover the secrets that bind them together."
            ]
            
        case .dusk:
            dialogueTexts = [
                "So, you've found your way to me. I am \(character), watcher of the twilight between realms. Few venture this far from the sanctuary of Dawn.",
                "Dusk cards are about control and denial. They prevent your opponents from executing their strategies while setting up your own victory.",
                "The most devastating combinations often begin with carefully played Dusk cards, locking your opponent's options before they realize the trap.",
                "The path ahead grows darker still. Proceed with caution, for the Night realm tests both skill and resolve. Not all who enter return unchanged."
            ]
            
        case .night:
            dialogueTexts = [
                "You stand at the edge of darkness. I am \(character), keeper of the deepest mysteries. Few have the courage to seek me out.",
                "Night cards are about patient power - banking strength for critical moments. Those who master timing will find themselves unstoppable.",
                "The greatest victories come not from brute force, but from the careful accumulation of power, released at the perfect moment to shatter an opponent's defense.",
                "You have learned much on your journey through the realms. Take this knowledge back to the Dawn, and prepare for the greater challenges that await."
            ]
        }
    }
    
    private func updateDialogueIndicator() {
        // Remove any existing indicators
        contentArea.children.filter { $0.name?.hasPrefix("dialogueIndicator") == true }.forEach { $0.removeFromParent() }
        
        // Create new indicator dots
        let dotRadius: CGFloat = 4
        let dotSpacing: CGFloat = 12
        let totalWidth = dotSpacing * CGFloat(dialogueTexts.count - 1)
        let startX = -totalWidth/2
        
        for i in 0..<dialogueTexts.count {
            let dot = SKShapeNode(circleOfRadius: dotRadius)
            dot.fillColor = i == currentDialogueIndex ? .white : .gray
            dot.strokeColor = .clear
            dot.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: -130)
            dot.name = "dialogueIndicator_\(i)"
            contentArea.addChild(dot)
        }
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for continue button touch
        if let continueButton = contentArea.childNode(withName: "continueButton") {
            if continueButton.contains(convert(location, to: contentArea)) {
                advanceDialogue()
                return true
            }
        }
        
        // Also advance dialogue if tapping on dialogue text
        if let dialogueText = contentArea.childNode(withName: "dialogueText") {
            if dialogueText.contains(convert(location, to: contentArea)) {
                advanceDialogue()
                return true
            }
        }
        
        return false
    }
    
    private func advanceDialogue() {
        // Move to next dialogue or end if at last one
        if currentDialogueIndex < dialogueTexts.count - 1 {
            currentDialogueIndex += 1
            
            // Update dialogue text
            if let dialogueText = contentArea.childNode(withName: "dialogueText") as? SKLabelNode {
                // Fade out current text
                dialogueText.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.run { [weak self] in
                        guard let self = self else { return }
                        dialogueText.text = self.dialogueTexts[self.currentDialogueIndex]
                    },
                    SKAction.fadeIn(withDuration: 0.2)
                ]))
                
                // Update indicator
                updateDialogueIndicator()
                
                // Change continue button text if at last dialogue
                if currentDialogueIndex == dialogueTexts.count - 1 {
                    if let continueButton = contentArea.childNode(withName: "continueButton") {
                        if let buttonLabel = continueButton.children.first(where: { $0 is SKLabelNode }) as? SKLabelNode {
                            buttonLabel.text = "Complete"
                        }
                    }
                }
            }
        } else {
            // At the end of dialogue, dismiss
            dismiss()
        }
    }
}

// MARK: - Shop Node Screen

class ShopNodeScreen: NodeInteractionScreen {
    
    override func getTitle() -> String {
            return "Shop"
        }
    
    override func setupSpecificContent() {
            // Get content dimensions
            let contentWidth = contentArea.userData?.value(forKey: "contentWidth") as? CGFloat ?? 300
            let contentHeight = contentArea.userData?.value(forKey: "contentHeight") as? CGFloat ?? 400
            let scale = contentArea.userData?.value(forKey: "contentScale") as? CGFloat ?? 1.0
            
            // ---- TOP SECTION: GREETING ----
            // Merchant greeting - positioned higher
            let greeting = SKLabelNode(fontNamed: "Copperplate")
            greeting.text = "\"Welcome, traveler! I have rare treasures for your journey.\""
            greeting.fontSize = 14 * scale
            greeting.fontColor = .white
            greeting.preferredMaxLayoutWidth = contentWidth - 80
            greeting.numberOfLines = 0
            greeting.verticalAlignmentMode = .center
            greeting.horizontalAlignmentMode = .center
            greeting.position = CGPoint(x: 0, y: contentHeight/2 - 80)
            contentArea.addChild(greeting)
            
            // Add merchant icon
            let merchantIcon = SKShapeNode(circleOfRadius: 25 * scale)
            merchantIcon.fillColor = Realm.dusk.color.withAlphaComponent(0.7)
            merchantIcon.strokeColor = .white
            merchantIcon.position = CGPoint(x: 0, y: contentHeight/2 - 30)
            contentArea.addChild(merchantIcon)
            
            // Simple merchant face
            let face = SKShapeNode(circleOfRadius: 15 * scale)
            face.fillColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0)
            face.strokeColor = .clear
            face.position = merchantIcon.position
            contentArea.addChild(face)
            
            // ---- MIDDLE SECTION: SHOP ITEMS ----
            // Move "Available Items" label higher and items lower
            let shopLabel = SKLabelNode(fontNamed: "Copperplate")
            shopLabel.text = "Available Items"
            shopLabel.fontSize = 16 * scale
            shopLabel.fontColor = .white
            // Position higher to create more space
            shopLabel.position = CGPoint(x: 0, y: contentHeight/4 + 30)
            contentArea.addChild(shopLabel)
            
            // Shop items in a 2x2 grid with proper spacing
            let shopItems = [
                (name: "Dawn Strategem", type: "Card", cost: 120),
                (name: "Dusk Veil", type: "Card", cost: 150),
                (name: "Night Essence", type: "Resource", cost: 80),
                (name: "Realm Map", type: "Item", cost: 200)
            ]
            
            // Grid layout calculation - moved down from label
            let itemsPerRow = 2
            let rows = 2
            let itemWidth = min(120 * scale, (contentWidth - 100) / CGFloat(itemsPerRow))
            let itemHeight = min(140 * scale, (contentHeight * 0.4) / CGFloat(rows))
            
            let colSpacing = itemWidth * 1.2
            let rowSpacing = itemHeight * 1.2
            
            // Adjust starting Y position (moved lower)
            let startY = contentHeight/8
            
            for (index, item) in shopItems.enumerated() {
                let row = index / itemsPerRow
                let col = index % itemsPerRow
                
                // Calculate position with wider spacing
                let x = (col == 0) ? -colSpacing/2 : colSpacing/2
                let y = startY - CGFloat(row) * rowSpacing
                
                // Randomize item colors slightly for more visual interest
                let hueShift = CGFloat(index) * 0.05
                let typeColor: SKColor
                switch item.type {
                case "Card":
                    typeColor = SKColor(hue: 0.1 + hueShift, saturation: 0.8, brightness: 0.9, alpha: 1.0)
                case "Resource":
                    typeColor = SKColor(hue: 0.6 + hueShift, saturation: 0.7, brightness: 0.8, alpha: 1.0)
                default:
                    typeColor = SKColor(hue: 0.3 + hueShift, saturation: 0.8, brightness: 0.9, alpha: 1.0)
                }
                
                let itemNode = createShopItem(
                    name: item.name,
                    type: item.type,
                    cost: item.cost,
                    position: CGPoint(x: x, y: y),
                    size: CGSize(width: itemWidth, height: itemHeight),
                    typeColor: typeColor
                )
                itemNode.name = "shopItem_\(index)"
                contentArea.addChild(itemNode)
            }
            
            // ---- BOTTOM SECTION: CURRENCY DISPLAY ----
            // Player currency display - moved lower for better spacing
            let currencyFrame = SKShapeNode(rectOf: CGSize(width: 160 * scale, height: 40 * scale), cornerRadius: 10)
            currencyFrame.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.8)
            currencyFrame.strokeColor = SKColor(red: 0.8, green: 0.7, blue: 0.2, alpha: 1.0) // Gold trim
            currencyFrame.lineWidth = 2
            
            // Calculate position to ensure it doesn't overlap with return button
            // Position lower in the screen for better balance
            let returnButtonHeight = 40 * scale
            let returnButtonY = -contentHeight/2 + 40 * scale
            let currencyY = returnButtonY + returnButtonHeight + 30
            currencyFrame.position = CGPoint(x: 0, y: currencyY)
            contentArea.addChild(currencyFrame)
            
            let currencyLabel = SKLabelNode(fontNamed: "Copperplate")
            currencyLabel.text = "Essence: 350"
            currencyLabel.fontSize = 18 * scale
            currencyLabel.fontColor = SKColor(red: 0.9, green: 0.8, blue: 0.3, alpha: 1.0) // Gold text
            currencyLabel.verticalAlignmentMode = .center
            currencyLabel.position = currencyFrame.position
            contentArea.addChild(currencyLabel)
            
            // Add a subtle animation to the currency display
            currencyFrame.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 1.5),
                SKAction.scale(to: 1.0, duration: 1.5)
            ])))
        }
    
    private func createShopItem(name: String, type: String, cost: Int, position: CGPoint, size: CGSize, typeColor: SKColor) -> SKNode {
        let container = SKNode()
        container.position = position
        
        // Scale factor
        let scale = contentArea.userData?.value(forKey: "contentScale") as? CGFloat ?? 1.0
        
        // Item background with gradient effect
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.8)
        background.strokeColor = .white
        background.lineWidth = 1.5
        container.addChild(background)
        
        // Add light gradient overlay for visual interest
        let gradient = SKShapeNode(rectOf: CGSize(width: size.width - 4, height: size.height - 4), cornerRadius: 8)
        gradient.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        gradient.strokeColor = .clear
        gradient.position = CGPoint(x: 0, y: size.height * 0.1)
        background.addChild(gradient)
        
        // Item icon - cleaner design
        let iconSize = min(size.width * 0.6, size.height * 0.4)
        let iconBackground = SKShapeNode(circleOfRadius: iconSize/2)
        iconBackground.fillColor = typeColor.withAlphaComponent(0.7)
        iconBackground.strokeColor = typeColor
        iconBackground.lineWidth = 2
        iconBackground.position = CGPoint(x: 0, y: size.height * 0.2)
        container.addChild(iconBackground)
        
        // Type icon
        let typeIcon = SKLabelNode(fontNamed: "Copperplate")
        typeIcon.text = String(type.prefix(1)) // First letter of type
        typeIcon.fontSize = 18 * scale
        typeIcon.fontColor = .white
        typeIcon.verticalAlignmentMode = .center
        typeIcon.position = iconBackground.position
        container.addChild(typeIcon)
        
        // Item name with proper wrapping
        let nameLabel = SKLabelNode(fontNamed: "Copperplate")
        nameLabel.text = name
        nameLabel.fontSize = 14 * scale
        nameLabel.fontColor = .white
        nameLabel.verticalAlignmentMode = .center
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.preferredMaxLayoutWidth = size.width - 10
        nameLabel.numberOfLines = 2
        nameLabel.position = CGPoint(x: 0, y: -size.height * 0.1)
        container.addChild(nameLabel)
        
        // Cost indicator with currency symbol
        let costPanel = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: size.height * 0.2), cornerRadius: 5)
        costPanel.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 0.9)
        costPanel.strokeColor = SKColor(red: 0.8, green: 0.7, blue: 0.2, alpha: 1.0) // Gold trim
        costPanel.lineWidth = 1
        costPanel.position = CGPoint(x: 0, y: -size.height * 0.35)
        container.addChild(costPanel)
        
        let costLabel = SKLabelNode(fontNamed: "Copperplate")
        costLabel.text = "✧ \(cost)"  // Add currency symbol
        costLabel.fontSize = 14 * scale
        costLabel.fontColor = SKColor(red: 0.9, green: 0.8, blue: 0.3, alpha: 1.0) // Gold text
        costLabel.verticalAlignmentMode = .center
        costLabel.position = costPanel.position
        container.addChild(costLabel)
        
        // Add interactive hover effect
        background.name = "itemBg"
        container.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 1.0...3.0)),
            SKAction.run {
                background.run(SKAction.sequence([
                    SKAction.scale(to: 1.05, duration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3)
                ]))
            }
        ])))
        
        return container
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for shop item touches with improved feedback
        for i in 0..<4 {
            if let itemNode = contentArea.childNode(withName: "shopItem_\(i)") {
                if itemNode.contains(convert(location, to: contentArea)) {
                    // Create a button press effect
                    itemNode.run(SKAction.sequence([
                        SKAction.scale(to: 0.95, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ]))
                    
                    // Show purchase feedback
                    showPurchaseFeedback(atPosition: itemNode.position)
                    return true
                }
            }
        }
        
        return false
    }
    
    private func showPurchaseFeedback(atPosition position: CGPoint) {
        // Create a more visually interesting feedback popup
        let feedbackNode = SKNode()
        feedbackNode.position = position
        feedbackNode.zPosition = 100
        contentArea.addChild(feedbackNode)
        
        // Background with gradient
        let popup = SKShapeNode(rectOf: CGSize(width: 180, height: 40), cornerRadius: 10)
        popup.fillColor = SKColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 0.7)
        popup.strokeColor = .white
        popup.lineWidth = 2
        popup.position = CGPoint(x: 0, y: 50)
        feedbackNode.addChild(popup)
        
        // Success text
        let feedbackText = SKLabelNode(fontNamed: "Copperplate")
        feedbackText.text = "Purchase successful!"
        feedbackText.fontSize = 16
        feedbackText.fontColor = .white
        feedbackText.verticalAlignmentMode = .center
        feedbackText.position = popup.position
        feedbackNode.addChild(feedbackText)
        
        // Add sparkle particles
        for _ in 0..<10 {
            let sparkle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            sparkle.fillColor = .white
            sparkle.strokeColor = .clear
            
            // Random position around the popup
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 15...40)
            let x = popup.position.x + cos(angle) * distance
            let y = popup.position.y + sin(angle) * distance
            sparkle.position = CGPoint(x: x, y: y)
            
            // Add to feedback and animate
            feedbackNode.addChild(sparkle)
            
            // Particle animation
            sparkle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.scale(by: 1.5, duration: 0.5),
                    SKAction.fadeOut(withDuration: 0.5)
                ]),
                SKAction.removeFromParent()
            ]))
        }
        
        // Animate the whole feedback
        feedbackNode.setScale(0)
        feedbackNode.run(SKAction.sequence([
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
}

// MARK: - Mystery Node Screen

class MysteryNodeScreen: NodeInteractionScreen {
    private var revealedEffect: String = ""
    private var isRevealed: Bool = false
    private var orbContainer: SKNode?
    private var promptText: SKNode?
    
    override func getTitle() -> String {
        return "Mystery Node"
    }
    
    override func setupSpecificContent() {
        // Get content dimensions
        let contentWidth = contentArea.userData?.value(forKey: "contentWidth") as? CGFloat ?? 300
        let contentHeight = contentArea.userData?.value(forKey: "contentHeight") as? CGFloat ?? 400
        let scale = contentArea.userData?.value(forKey: "contentScale") as? CGFloat ?? 1.0
        
        // ---- TOP SECTION: DESCRIPTION ----
        // Mystery description positioned well below title
        let description = "You've encountered a mysterious energy pattern. Its purpose is unclear, but it seems to be reacting to your presence."
        let descriptionText = SKLabelNode(fontNamed: "Copperplate")
        descriptionText.text = description
        descriptionText.fontSize = 14 * scale
        descriptionText.fontColor = .white
        descriptionText.preferredMaxLayoutWidth = contentWidth - 80
        descriptionText.numberOfLines = 0
        descriptionText.verticalAlignmentMode = .center
        descriptionText.horizontalAlignmentMode = .center
        descriptionText.position = CGPoint(x: 0, y: contentHeight/2 - 120)
        descriptionText.name = "descriptionText"
        contentArea.addChild(descriptionText)
        
        // ---- MIDDLE SECTION: MYSTERY ORB ----
        // Create container to hold all orb elements for easy removal
        let container = SKNode()
        container.position = CGPoint(x: 0, y: 0)
        container.name = "orbContainer"
        contentArea.addChild(container)
        orbContainer = container
        
        // Create a larger background glow for visual interest
        let backgroundGlow = SKShapeNode(circleOfRadius: 100)
        backgroundGlow.fillColor = node.realm.color.withAlphaComponent(0.1)
        backgroundGlow.strokeColor = .clear
        backgroundGlow.position = CGPoint.zero
        backgroundGlow.alpha = 0.5
        container.addChild(backgroundGlow)
        
        // Outer glow with more dramatic effect
        let outerGlow = SKShapeNode(circleOfRadius: 60)
        outerGlow.fillColor = .clear
        outerGlow.strokeColor = node.realm.color
        outerGlow.lineWidth = 3
        outerGlow.alpha = 0.7
        outerGlow.name = "outerGlow"
        container.addChild(outerGlow)
        
        // Inner glow with richer color
        let innerGlow = SKShapeNode(circleOfRadius: 40)
        innerGlow.fillColor = node.realm.color.withAlphaComponent(0.3)
        innerGlow.strokeColor = .clear
        innerGlow.name = "innerGlow"
        container.addChild(innerGlow)
        
        // Core with more saturation
        let core = SKShapeNode(circleOfRadius: 20)
        core.fillColor = node.realm.color
        core.strokeColor = .white
        core.lineWidth = 1
        core.name = "core"
        container.addChild(core)
        
        // Energy particles orbiting the core
        for i in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = .white
            particle.strokeColor = .clear
            particle.alpha = 0.7
            
            // Position in orbit pattern
            let angle = CGFloat(i) * .pi / 4
            let radius: CGFloat = 30
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            particle.position = CGPoint(x: x, y: y)
            
            // Create orbit path
            let orbit = SKAction.repeatForever(SKAction.sequence([
                SKAction.follow(
                    CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), transform: nil),
                    asOffset: false,
                    orientToPath: false,
                    duration: Double.random(in: 3.0...5.0)
                )
            ]))
            
            particle.run(orbit)
            container.addChild(particle)
        }
        
        // Pulsing animation for the orb components
        outerGlow.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.5),
            SKAction.scale(to: 1.0, duration: 1.5)
        ])))
        
        innerGlow.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ])))
        
        // Add subtle glow to core
        core.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 1.0),
            SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        ])))
        
        // ---- BOTTOM SECTION: INTERACTION PROMPT ----
        // Create a container node first
        promptText = SKNode()
        promptText!.name = "promptTextContainer"
        contentArea.addChild(promptText!)
        
        // Interaction prompt more visible and positioned well below orb
        let promptBackground = SKShapeNode(rectOf: CGSize(width: contentWidth - 100, height: 50), cornerRadius: 10)
        promptBackground.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.7)
        promptBackground.strokeColor = node.realm.color.withAlphaComponent(0.7)
        promptBackground.position = CGPoint(x: 0, y: -contentHeight/3)
        promptBackground.name = "promptBackground"
        promptText!.addChild(promptBackground)
        
        let promptTextLabel = SKLabelNode(fontNamed: "Copperplate")
        promptTextLabel.text = "Touch the orb to discover its secrets"
        promptTextLabel.fontSize = 16 * scale
        promptTextLabel.fontColor = .white
        promptTextLabel.verticalAlignmentMode = .center
        promptTextLabel.position = CGPoint(x: 0, y: -contentHeight/3)
        promptTextLabel.name = "promptTextLabel"
        promptText!.addChild(promptTextLabel)
        
        // Add a subtle rotation to the entire mystery orb
        container.run(SKAction.repeatForever(
            SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 20)
        ))
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for orb touch with improved coordinate handling
        let contentLocation = convert(location, to: contentArea)
        if !isRevealed {
            // Calculate distance from orb center
            let distance = hypot(contentLocation.x, contentLocation.y)
            
            // Check if touch is within the orb's radius (60px)
            if distance < 60 {
                revealMysteryEffect()
                return true
            }
        } else if let button = contentArea.childNode(withName: "//claimButton") {
            // If already revealed, check for claim button
            if button.contains(convert(location, to: button.parent!)) {
                dismiss()
                return true
            }
        }
        
        return false
    }
    
    private func revealMysteryEffect() {
        isRevealed = true
        
        // Define possible effects with more diverse outcomes
        let effects = [
            "You found a cache of resources! +10 Essence and a rare Dawn card fragment.",
            "An ancient card reveals itself to you. Added 'Radiant Dawn' to your collection.",
            "A strange energy fills you. Your next battle will start with 5 banked power.",
            "The mists part to reveal a hidden path. Two new areas are now visible on your map.",
            "A vision of strategy flashes in your mind. You can now see one enemy card per battle.",
            "The orb fractures, revealing an ancient key within. This may unlock something valuable."
        ]
        
        // Randomly select an effect (but don't use the same twice)
        revealedEffect = effects.randomElement() ?? effects[0]
        
        // Remove the prompt text
        promptText?.removeFromParent()
        
        // Animate the revelation
        let orbTransformSequence = SKAction.sequence([
            // Flash effect
            SKAction.run { [weak self] in
                guard let self = self, let container = self.orbContainer else { return }
                
                // Create expanding flash
                let flash = SKShapeNode(circleOfRadius: 10)
                flash.fillColor = .white
                flash.strokeColor = self.node.realm.color
                flash.lineWidth = 3
                flash.position = .zero
                container.addChild(flash)
                
                // Animate flash expanding outward
                flash.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.scale(to: 20, duration: 0.5),
                        SKAction.fadeOut(withDuration: 0.5)
                    ]),
                    SKAction.removeFromParent()
                ]))
            },
            
            // Shrink the orb
            SKAction.group([
                SKAction.scale(to: 0.5, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5)
            ]),
            
            // Remove the orb
            SKAction.run { [weak self] in
                self?.orbContainer?.removeFromParent()
                self?.orbContainer = nil
            }
        ])
        
        // Run the orbTransformation
        orbContainer?.run(orbTransformSequence)
        
        // Wait briefly then show effect text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.showRevealedEffect()
        }
    }
    
    private func showRevealedEffect() {
        guard let contentWidth = contentArea.userData?.value(forKey: "contentWidth") as? CGFloat,
              let contentHeight = contentArea.userData?.value(forKey: "contentHeight") as? CGFloat,
              let scale = contentArea.userData?.value(forKey: "contentScale") as? CGFloat else { return }
        
        // Remove any existing effect display
        contentArea.childNode(withName: "effectDisplay")?.removeFromParent()
        
        // Create effect display container
        let effectDisplay = SKNode()
        effectDisplay.name = "effectDisplay"
        effectDisplay.alpha = 0
        contentArea.addChild(effectDisplay)
        
        // Effect background with glow
        let effectBg = SKShapeNode(rectOf: CGSize(width: contentWidth - 80, height: 100), cornerRadius: 15)
        effectBg.fillColor = node.realm.color.withAlphaComponent(0.2)
        effectBg.strokeColor = node.realm.color
        effectBg.lineWidth = 2
        effectBg.position = CGPoint(x: 0, y: 0)
        effectDisplay.addChild(effectBg)
        
        // Effect text
        let effectText = SKLabelNode(fontNamed: "Copperplate")
        effectText.text = revealedEffect
        effectText.fontSize = 18 * scale
        effectText.fontColor = .white
        effectText.preferredMaxLayoutWidth = contentWidth - 100
        effectText.numberOfLines = 0
        effectText.verticalAlignmentMode = .center
        effectText.horizontalAlignmentMode = .center
        effectText.position = CGPoint(x: 0, y: 0)
        effectDisplay.addChild(effectText)
        
        // Create energy particles around the effect
        for _ in 0..<12 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            particle.fillColor = node.realm.color
            particle.strokeColor = .clear
            particle.alpha = CGFloat.random(in: 0.4...0.8)
            
            // Random position around the effect box
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: effectBg.frame.width * 0.3...effectBg.frame.width * 0.6)
            let x = cos(angle) * distance
            let y = sin(angle) * distance
            particle.position = CGPoint(x: x, y: y)
            
            // Orbit animation
            let orbitAction = SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.follow(
                        CGPath(ellipseIn: CGRect(x: -distance, y: -distance, width: distance*2, height: distance*2),
                               transform: nil),
                        asOffset: false,
                        orientToPath: false,
                        duration: Double.random(in: 3.0...6.0)
                    )
                ])
            )
            
            particle.run(orbitAction)
            effectDisplay.addChild(particle)
        }
        
        // Create claim button
        let claimButton = SKShapeNode(rectOf: CGSize(width: 150 * scale, height: 40 * scale), cornerRadius: 10)
        claimButton.fillColor = SKColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 0.8)
        claimButton.strokeColor = .white
        claimButton.lineWidth = 2
        claimButton.position = CGPoint(x: 0, y: -contentHeight/3)
        claimButton.name = "claimButton"
        effectDisplay.addChild(claimButton)
        
        let claimLabel = SKLabelNode(fontNamed: "Copperplate")
        claimLabel.text = "Claim Reward"
        claimLabel.fontSize = 16 * scale
        claimLabel.fontColor = .white
        claimLabel.verticalAlignmentMode = .center
        claimLabel.position = claimButton.position
        effectDisplay.addChild(claimLabel)
        
        // Add pulse animation to button
        claimButton.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])))
        
        // Fade in the whole display
        effectDisplay.run(SKAction.fadeIn(withDuration: 0.5))
    }
}

// MARK: - Nexus Node Screen

class NexusNodeScreen: NodeInteractionScreen {
    override func getTitle() -> String {
        return "Nexus Hub"
    }
    
    override func setupSpecificContent() {
        // Nexus description
        let description = "You stand at the central Nexus, where all realms converge. From here, you can access any area of the Celestial Realm or prepare for your journey."
        let descriptionText = createInfoText(
            text: description,
            maxWidth: screenWidth - 120,
            position: CGPoint(x: 0, y: 80)
        )
        contentArea.addChild(descriptionText)
        
        // Realm indicators in a circle
        let realmIcons = SKNode()
        realmIcons.position = CGPoint(x: 0, y: 0)
        contentArea.addChild(realmIcons)
        
        let realms = Realm.allCases
        let radius: CGFloat = 80
        
        for (index, realm) in realms.enumerated() {
            let angle = 2 * CGFloat.pi * CGFloat(index) / CGFloat(realms.count)
            let x = radius * cos(angle)
            let y = radius * sin(angle)
            
            // Realm indicator
            let realmNode = SKShapeNode(circleOfRadius: 25)
            realmNode.fillColor = realm.color.withAlphaComponent(0.7)
            realmNode.strokeColor = .white
            realmNode.lineWidth = 2
            realmNode.position = CGPoint(x: x, y: y)
            realmNode.name = "realm_\(realm.rawValue)"
            realmIcons.addChild(realmNode)
            
            // Realm name
            let nameLabel = SKLabelNode(fontNamed: "Copperplate")
            nameLabel.text = realm.rawValue.capitalized
            nameLabel.fontSize = 14
            nameLabel.fontColor = .white
            nameLabel.position = CGPoint(x: x, y: y - 40)
            realmIcons.addChild(nameLabel)
            
            // Add glow to current realm
            if realm == celestialRealm!.currentPhase {
                let glow = SKShapeNode(circleOfRadius: 30)
                glow.fillColor = .clear
                glow.strokeColor = .white
                glow.lineWidth = 2
                glow.position = realmNode.position
                glow.alpha = 0.7
                realmIcons.addChild(glow)
                
                glow.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.8),
                    SKAction.fadeAlpha(to: 0.7, duration: 0.8)
                ])))
            }
        }
        
        // Nexus actions
        let actions = ["View Status", "Prepare Deck", "Return to Battle"]
        let buttonWidth: CGFloat = 150
        let buttonSpacing: CGFloat = 20
        let totalButtonWidth = buttonWidth * CGFloat(actions.count) + buttonSpacing * CGFloat(actions.count - 1)
        let buttonStartX = -totalButtonWidth/2 + buttonWidth/2
        
        for (i, action) in actions.enumerated() {
            let button = createButton(
                text: action,
                size: CGSize(width: buttonWidth, height: 40),
                position: CGPoint(x: buttonStartX + CGFloat(i) * (buttonWidth + buttonSpacing), y: -100)
            )
            button.name = "action_\(action.replacingOccurrences(of: " ", with: ""))"
            contentArea.addChild(button)
        }
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for realm selection
        for realm in Realm.allCases {
            if let realmNode = contentArea.childNode(withName: "//realm_\(realm.rawValue)") {
                if realmNode.contains(convert(location, to: realmNode.parent!)) {
                    // Highlight the selected realm
                    let flash = SKAction.sequence([
                        SKAction.scale(to: 1.2, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ])
                    realmNode.run(flash)
                    
                    // Change to this realm phase
                    while celestialRealm!.currentPhase != realm {
                        celestialRealm!.shiftPhase()
                    }
                    
                    // Update visualization
                    parentScene?.updateVisualization()
                    
                    return true
                }
            }
        }
        
        // Check for action buttons
        let actionNames = ["ViewStatus", "PrepareDeck", "ReturnToBattle"]
        
        for actionName in actionNames {
            if let actionButton = contentArea.childNode(withName: "action_\(actionName)") {
                if actionButton.contains(convert(location, to: contentArea)) {
                    // Flash the button to indicate selection
                    let flash = SKAction.sequence([
                        SKAction.scale(to: 1.1, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ])
                    actionButton.run(flash)
                    
                    // Handle specific actions
                    if actionName == "ReturnToBattle" {
                        parentScene?.dismissExploration()
                    } else {
                        // For other actions, just dismiss this screen for now
                        dismiss()
                    }
                    
                    return true
                }
            }
        }
        
        return false
    }
}
