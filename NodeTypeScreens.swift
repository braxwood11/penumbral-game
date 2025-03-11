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
        // Get content dimensions for proper scaling
        let contentWidth = contentArea.userData?.value(forKey: "contentWidth") as? CGFloat ?? 300
        let contentHeight = contentArea.userData?.value(forKey: "contentHeight") as? CGFloat ?? 400
        let scale = contentArea.userData?.value(forKey: "contentScale") as? CGFloat ?? 1.0
        
        // ---- TOP SECTION: CHARACTER PORTRAIT (CENTERED) ----
        // Create a container for the enemy preview (similar to character portrait in NarrativeNode)
        let portraitContainer = SKNode()
        portraitContainer.position = CGPoint(x: 0, y: contentHeight/2 - 130) // Centered at top
        contentArea.addChild(portraitContainer)
        
        // Portrait frame with better styling (similar to NarrativeNode)
        let frameSize: CGFloat = 110 * scale
        let portraitFrame = SKShapeNode(circleOfRadius: frameSize/2)
        portraitFrame.fillColor = node.realm.color.withAlphaComponent(0.3)
        portraitFrame.strokeColor = node.realm.color
        portraitFrame.lineWidth = 3
        portraitFrame.position = CGPoint.zero
        portraitContainer.addChild(portraitFrame)
        
        // Create enemy silhouette based on enemy type
        let silhouette = SKNode()
        
        if enemyType.lowercased().contains("guardian") {
            // Guardian - shield and sword silhouette
            let shield = SKShapeNode()
            let shieldPath = CGMutablePath()
            let shieldWidth = 50.0 * scale
            let shieldHeight = 70.0 * scale
            shieldPath.addRoundedRect(in: CGRect(x: -shieldWidth/2, y: -shieldHeight/2, width: shieldWidth, height: shieldHeight),
                                      cornerWidth: 15, cornerHeight: 15)
            
            // Add sword
            shieldPath.move(to: CGPoint(x: shieldWidth/2 - 5, y: -10))
            shieldPath.addLine(to: CGPoint(x: shieldWidth/2 + 20, y: -shieldHeight/2 - 20))
            shieldPath.addLine(to: CGPoint(x: shieldWidth/2 + 15, y: -shieldHeight/2 - 25))
            shieldPath.addLine(to: CGPoint(x: shieldWidth/2 - 10, y: -15))
            shieldPath.closeSubpath()
            
            shield.path = shieldPath
            shield.fillColor = .black
            shield.strokeColor = node.realm.color
            shield.lineWidth = 2
            silhouette.addChild(shield)
            
        } else if enemyType.lowercased().contains("stalker") {
            // Stalker - hunched figure silhouette
            let head = SKShapeNode(circleOfRadius: 15)
            head.fillColor = .black
            head.strokeColor = node.realm.color
            head.lineWidth = 1.5
            head.position = CGPoint(x: 0, y: 20)
            silhouette.addChild(head)
            
            // Hunched body
            let body = SKShapeNode()
            let bodyPath = CGMutablePath()
            bodyPath.move(to: CGPoint(x: 0, y: 20))
            bodyPath.addQuadCurve(to: CGPoint(x: 0, y: -25), control: CGPoint(x: 25, y: 0))
            
            // Arms
            bodyPath.move(to: CGPoint(x: 0, y: 5))
            bodyPath.addLine(to: CGPoint(x: -25, y: -15))
            bodyPath.move(to: CGPoint(x: 0, y: 5))
            bodyPath.addLine(to: CGPoint(x: 20, y: -20))
            
            // Legs
            bodyPath.move(to: CGPoint(x: 0, y: -25))
            bodyPath.addLine(to: CGPoint(x: -15, y: -50))
            bodyPath.move(to: CGPoint(x: 0, y: -25))
            bodyPath.addLine(to: CGPoint(x: 15, y: -50))
            
            body.path = bodyPath
            body.strokeColor = node.realm.color
            body.lineWidth = 2
            silhouette.addChild(body)
            
        } else {
            // Default warrior
            let head = SKShapeNode(circleOfRadius: 18)
            head.fillColor = .black
            head.strokeColor = node.realm.color
            head.lineWidth = 2
            head.position = CGPoint(x: 0, y: 15)
            silhouette.addChild(head)
            
            // Body
            let body = SKShapeNode()
            let bodyPath = CGMutablePath()
            bodyPath.move(to: CGPoint(x: 0, y: -3))
            bodyPath.addLine(to: CGPoint(x: 0, y: -30))
            
            // Arms
            bodyPath.move(to: CGPoint(x: 0, y: -10))
            bodyPath.addLine(to: CGPoint(x: -30, y: 0))
            bodyPath.move(to: CGPoint(x: 0, y: -10))
            bodyPath.addLine(to: CGPoint(x: 30, y: 0))
            
            // Legs
            bodyPath.move(to: CGPoint(x: 0, y: -30))
            bodyPath.addLine(to: CGPoint(x: -20, y: -60))
            bodyPath.move(to: CGPoint(x: 0, y: -30))
            bodyPath.addLine(to: CGPoint(x: 20, y: -60))
            
            body.path = bodyPath
            body.strokeColor = node.realm.color
            body.lineWidth = 2
            silhouette.addChild(body)
        }
        
        silhouette.position = CGPoint(x: 0, y: 0)
        portraitFrame.addChild(silhouette)
        
        // ---- DIFFICULTY INDICATOR (UNDER PORTRAIT) ----
                // Create nameplate under portrait (similar to NarrativeNode)
                let nameBg = SKShapeNode(rectOf: CGSize(width: frameSize + 60, height: 30), cornerRadius: 8)
                nameBg.fillColor = node.realm.color.withAlphaComponent(0.5)
                nameBg.strokeColor = node.realm.color
                nameBg.lineWidth = 1
                nameBg.position = CGPoint(x: 0, y: -frameSize/2 - 25)
                portraitContainer.addChild(nameBg)
                
                // Create difficulty stars in the nameplate - with better spacing
                // Calculate width needed for "Difficulty:" text
                let difficultyText = "Difficulty:"
                let tempLabel = SKLabelNode(fontNamed: "Copperplate")
                tempLabel.text = difficultyText
                tempLabel.fontSize = 14 * scale
                
                // Get the width of the text for proper positioning
                let textWidth = tempLabel.frame.width
                
                // Position the difficulty label with proper alignment
                let diffLabel = SKLabelNode(fontNamed: "Copperplate")
                diffLabel.text = difficultyText
                diffLabel.fontSize = 14 * scale
                diffLabel.fontColor = .white
                diffLabel.verticalAlignmentMode = .center
                diffLabel.horizontalAlignmentMode = .center
                
                // Calculate position to ensure text is centered and stars don't overlap
                // We'll position this based on how many stars we need to show
                let diffLabelX = -nameBg.frame.width/2 + textWidth/2 + 10  // 10px padding from left edge
                diffLabel.position = CGPoint(x: diffLabelX, y: nameBg.position.y)
                portraitContainer.addChild(diffLabel)
                
                // Add stars with proper spacing
                let starSize: CGFloat = 10 * scale  // Slightly smaller stars
                let starSpacing: CGFloat = 12 * scale  // Tighter spacing
                let starY = nameBg.position.y
                // Position first star after the text with proper padding
                let starStartX = diffLabelX + textWidth/2 + starSize/2 + 8  // 8px padding between text and stars
                
                for i in 0..<difficulty {
                    let star = SKShapeNode(rectOf: CGSize(width: starSize, height: starSize), cornerRadius: 2)
                    star.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
                    star.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
                    star.lineWidth = 1
                    star.position = CGPoint(x: starStartX + starSpacing * CGFloat(i), y: starY)
                    portraitContainer.addChild(star)
                }
        
        // ---- MIDDLE SECTION: BATTLE DETAILS (SIMILAR TO DIALOGUE BOX) ----
        // Battle description box (similar styling to dialogue box in NarrativeNode)
        let descriptionBoxWidth = contentWidth - 60
        let descriptionBoxHeight = 150 * scale
        let descriptionBox = SKShapeNode(rectOf: CGSize(width: descriptionBoxWidth, height: descriptionBoxHeight), cornerRadius: 15)
        descriptionBox.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.7)
        descriptionBox.strokeColor = node.realm.color.withAlphaComponent(0.7)
        descriptionBox.lineWidth = 2
        
        // Position centered below portrait (similar to NarrativeNode dialogue box)
        descriptionBox.position = CGPoint(x: 0, y: -40)
        contentArea.addChild(descriptionBox)
        
        // Battle description with better styling and positioning
        let description: String
        if difficulty <= 2 {
            description = "A \(enemyType) approaches! This foe uses basic tactics and straightforward attacks. Victory should be within reach if you play your cards wisely."
        } else if difficulty <= 3 {
            description = "The \(enemyType) is a formidable adversary! This opponent employs clever maneuvers and powerful combinations. Be prepared for a challenging battle that will test your mastery of Dawn, Dusk, and Night."
        } else {
            description = "Beware the \(enemyType)! This fearsome opponent commands devastating power and deep cunning. Only those who have mastered the subtle interplay of card combinations will prevail in this most demanding of confrontations."
        }
        
        let descriptionText = SKLabelNode(fontNamed: "Copperplate")
        descriptionText.text = description
        descriptionText.fontSize = 16 * scale
        descriptionText.fontColor = .white
        descriptionText.verticalAlignmentMode = .center
        descriptionText.horizontalAlignmentMode = .center
        descriptionText.preferredMaxLayoutWidth = descriptionBoxWidth - 40
        descriptionText.numberOfLines = 0
        descriptionText.position = CGPoint(x: 0, y: 0)
        descriptionBox.addChild(descriptionText)
        
        
        // ---- BOTTOM SECTION: BEGIN BATTLE BUTTON ----
        // Begin battle button with same styling as continue button in NarrativeNode
        let buttonWidth: CGFloat = 180 * scale
        let buttonHeight: CGFloat = 44 * scale
        let continueButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        continueButton.fillColor = node.realm.color.withAlphaComponent(0.6)
        continueButton.strokeColor = .white
        continueButton.lineWidth = 1.5
        
        // Position to have good spacing from bottom of screen (similar to NarrativeNode)
        continueButton.position = CGPoint(x: 0, y: -contentHeight/2 + 100)
        continueButton.name = "beginBattleButton"
        contentArea.addChild(continueButton)
        
        let continueLabel = SKLabelNode(fontNamed: "Copperplate")
        continueLabel.text = "Begin Battle"
        continueLabel.fontSize = 18 * scale
        continueLabel.fontColor = .white
        continueLabel.verticalAlignmentMode = .center
        continueLabel.position = continueButton.position
        contentArea.addChild(continueLabel)
        
        // Add subtle pulsing animation to the button
        continueButton.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])))
        
        // Add subtle animation to enemy portrait (matches character portrait in NarrativeNode)
        portraitContainer.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 1.5),
            SKAction.moveBy(x: 0, y: -3, duration: 1.5)
        ])))
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for battle button press
        if let beginButton = contentArea.childNode(withName: "beginBattleButton") {
            if beginButton.contains(convert(location, to: contentArea)) {
                // Add button press effect
                beginButton.run(SKAction.sequence([
                    SKAction.scale(to: 0.95, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1),
                    SKAction.wait(forDuration: 0.1),
                    SKAction.run { [weak self] in
                        // Transition to battle
                        self?.parentScene?.dismissExploration()
                    }
                ]))
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
    private var characterPortrait: SKNode?
    private var dialogueBox: SKShapeNode?
    private var dialogueLabel: SKLabelNode?
    
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
        // Get content dimensions for proper scaling
        let contentWidth = contentArea.userData?.value(forKey: "contentWidth") as? CGFloat ?? 300
        let contentHeight = contentArea.userData?.value(forKey: "contentHeight") as? CGFloat ?? 400
        let scale = contentArea.userData?.value(forKey: "contentScale") as? CGFloat ?? 1.0
        
        // Setup dialogue texts based on character and realm
        setupDialogueTexts()
        
        // ---- TOP SECTION: CHARACTER PORTRAIT (CENTERED) ----
        // Create a container for the portrait
        let portraitContainer = SKNode()
        portraitContainer.position = CGPoint(x: 0, y: contentHeight/2 - 130) // Centered at top
        contentArea.addChild(portraitContainer)
        
        // Portrait frame with better styling
        let frameSize: CGFloat = 100 * scale
        let portraitFrame = SKShapeNode(circleOfRadius: frameSize/2)
        portraitFrame.fillColor = node.realm.color.withAlphaComponent(0.3)
        portraitFrame.strokeColor = node.realm.color
        portraitFrame.lineWidth = 3
        portraitFrame.position = CGPoint.zero
        portraitContainer.addChild(portraitFrame)
        
        // Create a character silhouette based on the character type
        let character = SKNode()
        
        if self.character.lowercased().contains("oracle") {
            // Oracle character - hooded figure
            let hood = SKShapeNode()
            let hoodPath = CGMutablePath()
            
            // Hood silhouette
            hoodPath.move(to: CGPoint(x: -30, y: -10))
            hoodPath.addQuadCurve(to: CGPoint(x: 30, y: -10), control: CGPoint(x: 0, y: 40))
            hoodPath.addQuadCurve(to: CGPoint(x: -30, y: -10), control: CGPoint(x: 0, y: -30))
            
            hood.path = hoodPath
            hood.fillColor = .black
            hood.strokeColor = node.realm.color
            hood.lineWidth = 2
            character.addChild(hood)
            
            // Face suggestion - just eyes
            let leftEye = SKShapeNode(circleOfRadius: 3)
            leftEye.fillColor = node.realm.color
            leftEye.position = CGPoint(x: -10, y: 0)
            character.addChild(leftEye)
            
            let rightEye = SKShapeNode(circleOfRadius: 3)
            rightEye.fillColor = node.realm.color
            rightEye.position = CGPoint(x: 10, y: 0)
            character.addChild(rightEye)
            
        } else if self.character.lowercased().contains("sage") {
            // Sage character - wise figure with staff
            // Head
            let head = SKShapeNode(circleOfRadius: 15)
            head.fillColor = .black
            head.strokeColor = node.realm.color
            head.lineWidth = 1.5
            head.position = CGPoint(x: 0, y: 20)
            character.addChild(head)
            
            // Body and robes
            let body = SKShapeNode()
            let bodyPath = CGMutablePath()
            bodyPath.move(to: CGPoint(x: -15, y: 5))
            bodyPath.addLine(to: CGPoint(x: 15, y: 5))
            bodyPath.addLine(to: CGPoint(x: 25, y: -40))
            bodyPath.addLine(to: CGPoint(x: -25, y: -40))
            bodyPath.closeSubpath()
            
            body.path = bodyPath
            body.fillColor = .black
            body.strokeColor = node.realm.color
            body.lineWidth = 1.5
            character.addChild(body)
            
            // Staff
            let staff = SKShapeNode()
            let staffPath = CGMutablePath()
            staffPath.move(to: CGPoint(x: -20, y: 10))
            staffPath.addLine(to: CGPoint(x: -20, y: -50))
            
            staff.path = staffPath
            staff.strokeColor = node.realm.color
            staff.lineWidth = 3
            character.addChild(staff)
            
        } else {
            // Default character - generic silhouette
            // Head
            let head = SKShapeNode(circleOfRadius: 18)
            head.fillColor = .black
            head.strokeColor = node.realm.color
            head.lineWidth = 2
            head.position = CGPoint(x: 0, y: 15)
            character.addChild(head)
            
            // Body
            let body = SKShapeNode()
            let bodyPath = CGMutablePath()
            bodyPath.move(to: CGPoint(x: 0, y: -3))
            bodyPath.addLine(to: CGPoint(x: 0, y: -30))
            bodyPath.move(to: CGPoint(x: -20, y: -10))
            bodyPath.addLine(to: CGPoint(x: 20, y: -10))
            
            body.path = bodyPath
            body.strokeColor = node.realm.color
            body.lineWidth = 2
            character.addChild(body)
        }
        
        character.position = CGPoint(x: 0, y: 0)
        portraitFrame.addChild(character)
        self.characterPortrait = portraitContainer
        
        // Character name with decorative elements - centered below portrait
        let nameBg = SKShapeNode(rectOf: CGSize(width: frameSize + 60, height: 30), cornerRadius: 8)
        nameBg.fillColor = node.realm.color.withAlphaComponent(0.5)
        nameBg.strokeColor = node.realm.color
        nameBg.lineWidth = 1
        nameBg.position = CGPoint(x: 0, y: -frameSize/2 - 25)
        portraitContainer.addChild(nameBg)
        
        let nameLabel = SKLabelNode(fontNamed: "Copperplate")
        nameLabel.text = self.character
        nameLabel.fontSize = 16 * scale
        nameLabel.fontColor = .white
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = nameBg.position
        portraitContainer.addChild(nameLabel)
        
        // ---- MIDDLE SECTION: DIALOGUE AREA (CENTERED) ----
        // Dialogue box with improved styling - centered below portrait
        // Make it wider to use more screen space
        let dialogueBoxWidth = contentWidth - 60
        let dialogueBoxHeight = 160 * scale
        let dialogueBox = SKShapeNode(rectOf: CGSize(width: dialogueBoxWidth, height: dialogueBoxHeight), cornerRadius: 15)
        dialogueBox.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.7)
        dialogueBox.strokeColor = node.realm.color.withAlphaComponent(0.7)
        dialogueBox.lineWidth = 2
        
        // Position centered below the character portrait
        dialogueBox.position = CGPoint(x: 0, y: -40)
        contentArea.addChild(dialogueBox)
        self.dialogueBox = dialogueBox
        
        // Dialogue text with better styling and positioning
        let dialogueText = SKLabelNode(fontNamed: "Copperplate")
        dialogueText.text = dialogueTexts[currentDialogueIndex]
        dialogueText.fontSize = 16 * scale
        dialogueText.fontColor = .white
        dialogueText.verticalAlignmentMode = .center
        dialogueText.horizontalAlignmentMode = .center
        dialogueText.preferredMaxLayoutWidth = dialogueBoxWidth - 40
        dialogueText.numberOfLines = 0
        dialogueText.position = CGPoint(x: 0, y: -4)
        dialogueText.name = "dialogueText"
        contentArea.addChild(dialogueText)
        self.dialogueLabel = dialogueText
        
        // ---- BOTTOM SECTION: DIALOGUE CONTROLS ----
        // Continue button with improved styling - centered below dialogue box
        let buttonWidth: CGFloat = 140 * scale
        let buttonHeight: CGFloat = 36 * scale
        let continueButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        continueButton.fillColor = node.realm.color.withAlphaComponent(0.6)
        continueButton.strokeColor = .white
        continueButton.lineWidth = 1.5
        
        // Position to have good spacing from bottom of screen
        continueButton.position = CGPoint(x: 0, y: -contentHeight/2 + 80)
        continueButton.name = "continueButton"
        contentArea.addChild(continueButton)
        
        let continueLabel = SKLabelNode(fontNamed: "Copperplate")
        continueLabel.text = "Continue"
        continueLabel.fontSize = 16 * scale
        continueLabel.fontColor = .white
        continueLabel.verticalAlignmentMode = .center
        continueLabel.position = continueButton.position
        contentArea.addChild(continueLabel)
        
        // Progress bar positioned above the continue button
        let barWidth: CGFloat = dialogueBoxWidth - 60
        let barHeight: CGFloat = 6
        let barBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: barHeight/2)
        barBg.fillColor = SKColor.white.withAlphaComponent(0.3)
        barBg.strokeColor = .clear
        barBg.position = CGPoint(x: 0, y: continueButton.position.y + buttonHeight/2 + 35)
        barBg.name = "dialogueIndicatorBg"
        contentArea.addChild(barBg)
        
        // Progress fill
        let progress = CGFloat(currentDialogueIndex) / CGFloat(dialogueTexts.count - 1)
        let fillWidth = barWidth * progress
        let fillRect = SKShapeNode(rectOf: CGSize(width: fillWidth, height: barHeight - 2), cornerRadius: (barHeight - 2)/2)
        fillRect.fillColor = node.realm.color
        fillRect.strokeColor = .clear
        
        // Position from left edge
        let fillX = barBg.position.x - barWidth/2 + fillWidth/2
        fillRect.position = CGPoint(x: fillX, y: barBg.position.y)
        fillRect.name = "dialogueIndicatorFill"
        contentArea.addChild(fillRect)
        
        // Add page counter text
        let pageCounter = SKLabelNode(fontNamed: "Copperplate")
        pageCounter.text = "\(currentDialogueIndex + 1)/\(dialogueTexts.count)"
        pageCounter.fontSize = 12
        pageCounter.fontColor = .white
        pageCounter.position = CGPoint(x: 0, y: barBg.position.y - 14)
        pageCounter.verticalAlignmentMode = .top
        pageCounter.name = "dialogueIndicatorCounter"
        contentArea.addChild(pageCounter)
        
        // Add subtle animation to character portrait
        characterPortrait?.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 1.5),
            SKAction.moveBy(x: 0, y: -3, duration: 1.5)
        ])))
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
        
        // Create dialog progress bar instead of dots
        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 6
        let barBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: barHeight/2)
        barBg.fillColor = SKColor.white.withAlphaComponent(0.3)
        barBg.strokeColor = .clear
        barBg.position = CGPoint(x: dialogueBox!.position.x, y: dialogueBox!.position.y - dialogueBox!.frame.height/2 + 10)
        barBg.name = "dialogueIndicatorBg"
        contentArea.addChild(barBg)
        
        // Progress fill
        let progress = CGFloat(currentDialogueIndex) / CGFloat(dialogueTexts.count - 1)
        let fillWidth = barWidth * progress
        let fillRect = SKShapeNode(rectOf: CGSize(width: fillWidth, height: barHeight - 2), cornerRadius: (barHeight - 2)/2)
        fillRect.fillColor = node.realm.color
        fillRect.strokeColor = .clear
        
        // Position from left edge
        let fillX = barBg.position.x - barWidth/2 + fillWidth/2
        fillRect.position = CGPoint(x: fillX, y: barBg.position.y)
        fillRect.name = "dialogueIndicatorFill"
        contentArea.addChild(fillRect)
        
        // Add page counter text
        let pageCounter = SKLabelNode(fontNamed: "Copperplate")
        pageCounter.text = "\(currentDialogueIndex + 1)/\(dialogueTexts.count)"
        pageCounter.fontSize = 12
        pageCounter.fontColor = .white
        pageCounter.position = CGPoint(x: barBg.position.x, y: barBg.position.y - 14)
        pageCounter.verticalAlignmentMode = .top
        pageCounter.name = "dialogueIndicatorCounter"
        contentArea.addChild(pageCounter)
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Handle continue button touch
        if let continueButton = contentArea.childNode(withName: "continueButton") {
            if continueButton.contains(convert(location, to: contentArea)) {
                // Add button press animation
                continueButton.run(SKAction.sequence([
                    SKAction.scale(to: 0.95, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1),
                    SKAction.run { [weak self] in
                        self?.advanceDialogue()
                    }
                ]))
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
        
        // Also advance dialogue if tapping on dialogue box
        if let dialogueBox = self.dialogueBox {
            if dialogueBox.contains(convert(location, to: contentArea)) {
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
            
            // Update dialogue text with an animated transition
            if let dialogueLabel = self.dialogueLabel {
                // Fade out current text
                dialogueLabel.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.run { [weak self] in
                        guard let self = self else { return }
                        dialogueLabel.text = self.dialogueTexts[self.currentDialogueIndex]
                    },
                    SKAction.fadeIn(withDuration: 0.2)
                ]))
                
                // Update indicator
                updateDialogueIndicator()
                
                // Change continue button text if at last dialogue
                if currentDialogueIndex == dialogueTexts.count - 1 {
                    let continueButton = contentArea.childNode(withName: "continueButton")
                    if let buttonBackground = continueButton as? SKShapeNode {
                        // Change the color to indicate completion
                        buttonBackground.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 0.6)
                    }
                    
                    if let buttonChildren = continueButton?.children.first(where: { $0 is SKLabelNode }) as? SKLabelNode {
                        buttonChildren.text = "Complete"
                    } else if let buttonLabel = contentArea.children.first(where: {
                        $0 is SKLabelNode &&
                        ($0 as? SKLabelNode)?.text == "Continue"
                    }) as? SKLabelNode {
                        buttonLabel.text = "Complete"
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
        // Get content dimensions for proper scaling
        let contentWidth = contentArea.userData?.value(forKey: "contentWidth") as? CGFloat ?? 300
        let contentHeight = contentArea.userData?.value(forKey: "contentHeight") as? CGFloat ?? 400
        let scale = contentArea.userData?.value(forKey: "contentScale") as? CGFloat ?? 1.0
        
        // ---- TOP SECTION: NEXUS VISUALIZATION ----
        // Create nexus crystal visualization at the top
        let nexusContainer = SKNode()
        nexusContainer.position = CGPoint(x: 0, y: contentHeight/2 - 120)
        contentArea.addChild(nexusContainer)
        
        // Central nexus crystal
        let crystalSize: CGFloat = 50 * scale
        let crystal = SKShapeNode(rectOf: CGSize(width: crystalSize, height: crystalSize * 1.5), cornerRadius: 3)
        crystal.fillColor = SKColor.white.withAlphaComponent(0.5)
        crystal.strokeColor = .white
        crystal.lineWidth = 2
        crystal.position = CGPoint.zero
        crystal.zRotation = CGFloat.pi / 4  // 45-degree rotation for diamond shape
        nexusContainer.addChild(crystal)
        
        // Inner crystal glow
        let innerGlow = SKShapeNode(rectOf: CGSize(width: crystalSize * 0.6, height: crystalSize * 0.9), cornerRadius: 2)
        innerGlow.fillColor = SKColor.white.withAlphaComponent(0.8)
        innerGlow.strokeColor = .clear
        innerGlow.position = CGPoint.zero
        innerGlow.zRotation = CGFloat.pi / 4
        crystal.addChild(innerGlow)
        
        // Add gentle pulsing animation to crystal
        crystal.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.5),
            SKAction.scale(to: 1.0, duration: 1.5)
        ])))
        
        // Add energy beams connecting to realm indicators
        let beamContainer = SKNode()
        beamContainer.position = CGPoint.zero
        nexusContainer.addChild(beamContainer)
        
        // Crystal description
        let crystalLabel = SKLabelNode(fontNamed: "Copperplate")
        crystalLabel.text = "Nexus Crystal"
        crystalLabel.fontSize = 14 * scale
        crystalLabel.fontColor = .white
        crystalLabel.position = CGPoint(x: 0, y: -crystalSize - 5)
        nexusContainer.addChild(crystalLabel)
        
        // ---- MIDDLE SECTION: REALM SELECTOR ----
        // Description text
        let description = "You stand at the central Nexus, where all realms converge. From here, you can travel to any area or shift the phase of the Celestial Realm."
        let descriptionText = SKLabelNode(fontNamed: "Copperplate")
        descriptionText.text = description
        descriptionText.fontSize = 16 * scale
        descriptionText.fontColor = .white
        descriptionText.preferredMaxLayoutWidth = contentWidth - 60
        descriptionText.numberOfLines = 0
        descriptionText.verticalAlignmentMode = .center
        descriptionText.position = CGPoint(x: 0, y: contentHeight/2 - 250)
        contentArea.addChild(descriptionText)
        
        // Create realm selection panel (similar to dialogue box in NarrativeNode)
        let realmPanelWidth = contentWidth - 60
        let realmPanelHeight = 140 * scale
        let realmPanel = SKShapeNode(rectOf: CGSize(width: realmPanelWidth, height: realmPanelHeight), cornerRadius: 15)
        realmPanel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.7)
        realmPanel.strokeColor = .white.withAlphaComponent(0.7)
        realmPanel.lineWidth = 2
        realmPanel.position = CGPoint(x: 0, y: -95)
        contentArea.addChild(realmPanel)
        
        // Add "Current Phase" label to the top of the panel
        let phaseLabel = SKLabelNode(fontNamed: "Copperplate")
        phaseLabel.text = "Current Phase: \(celestialRealm!.currentPhase.rawValue.capitalized)"
        phaseLabel.fontSize = 16 * scale
        phaseLabel.fontColor = celestialRealm!.currentPhase.color
        phaseLabel.position = CGPoint(x: 0, y: realmPanelHeight/2 - 25)
        realmPanel.addChild(phaseLabel)
        
        // Create horizontal realm selector inside the panel
        let realmSelector = SKNode()
        realmSelector.position = CGPoint(x: 0, y: 0)
        realmPanel.addChild(realmSelector)
        
        let realms = Realm.allCases
        let realmButtonWidth: CGFloat = 60 * scale
        let realmButtonHeight: CGFloat = 70 * scale
        let spacing: CGFloat = 15 * scale
        let totalWidth = CGFloat(realms.count) * realmButtonWidth + CGFloat(realms.count - 1) * spacing
        let startX = -totalWidth / 2 + realmButtonWidth / 2
        
        // Create a button for each realm
        for (index, realm) in realms.enumerated() {
            let x = startX + CGFloat(index) * (realmButtonWidth + spacing)
            
            // Button background with realm color
            let button = SKShapeNode(rectOf: CGSize(width: realmButtonWidth, height: realmButtonHeight), cornerRadius: 10)
            button.fillColor = realm.color.withAlphaComponent(0.3)
            button.strokeColor = realm.color
            button.lineWidth = 2
            button.position = CGPoint(x: x, y: -10)
            button.name = "realm_\(realm.rawValue)"
            realmSelector.addChild(button)
            
            // Realm name
            let nameLabel = SKLabelNode(fontNamed: "Copperplate")
            nameLabel.text = realm.rawValue.capitalized
            nameLabel.fontSize = 16 * scale
            nameLabel.fontColor = .white
            nameLabel.verticalAlignmentMode = .center
            nameLabel.position = CGPoint(x: x, y: 10)
            realmSelector.addChild(nameLabel)
            
            // Add symbol or icon
            let realmSymbol = createRealmSymbol(for: realm, size: 18 * scale)
            realmSymbol.position = CGPoint(x: x, y: -25)
            realmSelector.addChild(realmSymbol)
            
            // Add highlight for current realm
            if realm == celestialRealm!.currentPhase {
                let highlight = SKShapeNode(rectOf: CGSize(width: realmButtonWidth + 10, height: realmButtonHeight + 10), cornerRadius: 12)
                highlight.fillColor = .clear
                highlight.strokeColor = .white
                highlight.lineWidth = 2
                highlight.position = button.position
                highlight.alpha = 0.7
                highlight.name = "currentRealmHighlight"
                realmSelector.addChild(highlight)
                
                // Add pulsing animation
                highlight.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.8),
                    SKAction.fadeAlpha(to: 0.7, duration: 0.8)
                ])))
            }
        }
    
        
        // ---- BOTTOM SECTION: ACTION BUTTONS ----
        // Create action buttons at the bottom
        let actions = [
            ("View Map", "viewMap", SKColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 0.8)),
            ("To Battle", "returnToBattle", SKColor(red: 0.7, green: 0.3, blue: 0.3, alpha: 0.8))
        ]
        
        // Calculate layout for evenly spaced buttons
        let buttonWidth: CGFloat = 100 * scale
        let buttonHeight: CGFloat = 40 * scale
        let buttonSpacing: CGFloat = 20 * scale
        let totalButtonWidth = CGFloat(actions.count) * buttonWidth + CGFloat(actions.count - 1) * buttonSpacing
        let buttonStartX = -totalButtonWidth / 2 + buttonWidth / 2
        
        // Position buttons near the bottom of the content area
        let buttonsY = -contentHeight/2 + 80
        
        for (index, action) in actions.enumerated() {
            let x = buttonStartX + CGFloat(index) * (buttonWidth + buttonSpacing)
            
            // Button background
            let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
            button.fillColor = action.2
            button.strokeColor = .white
            button.lineWidth = 1.5
            button.position = CGPoint(x: x, y: buttonsY)
            button.name = "action_\(action.1)"
            contentArea.addChild(button)
            
            // Button label
            let buttonLabel = SKLabelNode(fontNamed: "Copperplate")
            buttonLabel.text = action.0
            buttonLabel.fontSize = 16 * scale
            buttonLabel.fontColor = .white
            buttonLabel.verticalAlignmentMode = .center
            buttonLabel.position = button.position
            contentArea.addChild(buttonLabel)
            
            // Add subtle animation to the "Return to Battle" button
            if action.1 == "returnToBattle" {
                button.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.scale(to: 1.05, duration: 0.8),
                    SKAction.scale(to: 1.0, duration: 0.8)
                ])))
            }
        }
        
        // Add energy particles flowing between nexus and realm buttons
        addEnergyParticles(from: nexusContainer.position, to: realmPanel.position)
    }
    
    private func createRealmSymbol(for realm: Realm, size: CGFloat) -> SKNode {
        let symbolNode = SKNode()
        
        switch realm {
        case .dawn:
            // Sun symbol for Dawn
            let sun = SKShapeNode(circleOfRadius: size/2)
            sun.fillColor = SKColor(white: 1.0, alpha: 0.8)
            sun.strokeColor = .clear
            symbolNode.addChild(sun)
            
            // Add rays
            let rayCount = 8
            for i in 0..<rayCount {
                let ray = SKShapeNode(rectOf: CGSize(width: 2, height: size * 0.7))
                ray.fillColor = SKColor(white: 1.0, alpha: 0.8)
                ray.strokeColor = .clear
                ray.position = CGPoint(
                    x: sin(CGFloat(i) * .pi * 2 / CGFloat(rayCount)) * size * 0.8,
                    y: cos(CGFloat(i) * .pi * 2 / CGFloat(rayCount)) * size * 0.8
                )
                ray.zRotation = CGFloat(i) * .pi * 2 / CGFloat(rayCount)
                symbolNode.addChild(ray)
            }
            
        case .dusk:
            // Half sun/moon for Dusk
            let duskSymbol = SKShapeNode()
            let path = CGMutablePath()
            
            // Create a circle with right half missing
            path.addArc(center: CGPoint.zero,
                      radius: size/2,
                      startAngle: -.pi/2,
                      endAngle: .pi/2,
                      clockwise: false)
            
            // Complete the path with line to center
            path.addLine(to: CGPoint.zero)
            path.closeSubpath()
            
            duskSymbol.path = path
            duskSymbol.fillColor = SKColor(white: 0.9, alpha: 0.8)
            duskSymbol.strokeColor = .clear
            symbolNode.addChild(duskSymbol)
            
        case .night:
            // Moon for Night
            let moonOutline = SKShapeNode(circleOfRadius: size/2)
            moonOutline.fillColor = SKColor(white: 0.1, alpha: 0.5)
            moonOutline.strokeColor = SKColor(white: 0.7, alpha: 0.8)
            moonOutline.lineWidth = 1
            symbolNode.addChild(moonOutline)
            
            // Add stars
            for _ in 0..<3 {
                let star = SKShapeNode(circleOfRadius: size/10)
                star.fillColor = SKColor(white: 0.9, alpha: 0.8)
                star.strokeColor = .clear
                
                // Random position within moon
                let angle = CGFloat.random(in: 0...2*CGFloat.pi)
                let distance = CGFloat.random(in: 0...(size/4))
                star.position = CGPoint(
                    x: cos(angle) * distance,
                    y: sin(angle) * distance
                )
                symbolNode.addChild(star)
            }
        }
        
        return symbolNode
    }
    
    private func addEnergyParticles(from startPoint: CGPoint, to endPoint: CGPoint) {
        // Create a container for particles
        let particleContainer = SKNode()
        particleContainer.position = CGPoint.zero
        contentArea.addChild(particleContainer)
        
        // Add a subtle animation to create flowing energy particles
        let createParticle = SKAction.run {
            // Create a particle
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3))
            particle.fillColor = .white
            particle.strokeColor = .clear
            particle.alpha = CGFloat.random(in: 0.3...0.8)
            
            // Start at the nexus
            particle.position = startPoint
            
            // Calculate a slightly randomized end position
            let randomOffset = CGPoint(
                x: CGFloat.random(in: -30...30),
                y: CGFloat.random(in: -20...20)
            )
            let targetPosition = CGPoint(
                x: endPoint.x + randomOffset.x,
                y: endPoint.y + randomOffset.y
            )
            
            // Add to container
            particleContainer.addChild(particle)
            
            // Animate movement
            let duration = CGFloat.random(in: 1.2...2.0)
            particle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: targetPosition, duration: TimeInterval(duration)),
                    SKAction.fadeOut(withDuration: TimeInterval(duration * 0.8))
                ]),
                SKAction.removeFromParent()
            ]))
        }
        
        // Create particles at intervals
        particleContainer.run(SKAction.repeatForever(SKAction.sequence([
            createParticle,
            SKAction.wait(forDuration: 0.2)
        ])))
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Convert touch location to content area coordinates
        let contentLocation = convert(location, to: contentArea)
        
        // Check for realm selection
        for realm in Realm.allCases {
            let realmButtonName = "realm_\(realm.rawValue)"
            if let realmButton = contentArea.childNode(withName: "//\(realmButtonName)") {
                if realmButton.contains(convert(location, to: realmButton.parent!)) {
                    // Visual feedback
                    realmButton.run(SKAction.sequence([
                        SKAction.scale(to: 0.9, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ]))
                    
                    // Update the game state
                    if realm != celestialRealm!.currentPhase {
                        // Change to this realm phase
                        while celestialRealm!.currentPhase != realm {
                            celestialRealm!.shiftPhase()
                        }
                        
                        // Update visualization
                        parentScene?.updateVisualization()
                        
                        // Flash effect for phase change
                        let flash = SKShapeNode(rect: CGRect(x: -contentArea.frame.width/2,
                                                            y: -contentArea.frame.height/2,
                                                            width: contentArea.frame.width,
                                                            height: contentArea.frame.height))
                        flash.fillColor = realm.color.withAlphaComponent(0.3)
                        flash.strokeColor = .clear
                        flash.alpha = 0
                        contentArea.addChild(flash)
                        
                        // Animate flash
                        flash.run(SKAction.sequence([
                            SKAction.fadeIn(withDuration: 0.2),
                            SKAction.fadeOut(withDuration: 0.4),
                            SKAction.removeFromParent()
                        ]))
                        
                        // Update the phase label
                        if let phaseLabel = contentArea.childNode(withName: "//SKLabelNode")?.childNode(withName: "//SKLabelNode") as? SKLabelNode {
                            phaseLabel.text = "Current Phase: \(celestialRealm!.currentPhase.rawValue.capitalized)"
                            phaseLabel.fontColor = celestialRealm!.currentPhase.color
                        }
                        
                        // Move the highlight to the new current realm
                        contentArea.childNode(withName: "//currentRealmHighlight")?.removeFromParent()
                        
                        let highlight = SKShapeNode(rectOf: CGSize(width: realmButton.frame.width + 10,
                                                                   height: realmButton.frame.height + 10),
                                                    cornerRadius: 12)
                        highlight.fillColor = .clear
                        highlight.strokeColor = .white
                        highlight.lineWidth = 2
                        highlight.position = realmButton.position
                        highlight.alpha = 0.7
                        highlight.name = "currentRealmHighlight"
                        realmButton.parent?.addChild(highlight)
                        
                        // Add pulsing animation
                        highlight.run(SKAction.repeatForever(SKAction.sequence([
                            SKAction.fadeAlpha(to: 0.3, duration: 0.8),
                            SKAction.fadeAlpha(to: 0.7, duration: 0.8)
                        ])))
                    }
                    
                    return true
                }
            }
        }
        
        // Check for action button touches
        let actionButtons = ["viewMap", "returnToBattle"]
        for actionName in actionButtons {
            if let button = contentArea.childNode(withName: "action_\(actionName)") {
                if button.contains(contentLocation) {
                    // Button press effect
                    button.run(SKAction.sequence([
                        SKAction.scale(to: 0.95, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1),
                        SKAction.run { [weak self] in
                            // Handle the action
                            if actionName == "returnToBattle" {
                                self?.parentScene?.dismissExploration()
                            } else if actionName == "viewMap" {
                                // Future map viewing functionality
                                self?.dismiss()
                            }
                        }
                    ]))
                    return true
                }
            }
        }
        
        return false
    }
}
