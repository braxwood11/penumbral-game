//
//  GameScene.swift
//  Penumbral
//
//  Created by Braxton Smallwood on 1/5/25.
//

import GameplayKit
import SpriteKit


class CardNode: SKSpriteNode {
    
    private var originalPosition: CGPoint?
    private var originalRotation: CGFloat?
    private var originalZPosition: CGFloat?
    
    let card: Card
    private var highlighted = false
    private var hitArea: SKShapeNode?
    private(set) var isSelected = false
    
    override func contains(_ point: CGPoint) -> Bool {
        // Convert point to local coordinates
        let localPoint = convert(point, from: parent!)
        
        if isSelected {
            // When selected, use simple rectangular bounds for the whole card
            return abs(localPoint.x) < size.width/2 && abs(localPoint.y) < size.height/2
        } else {
            // When in hand, use the adjusted hit detection we developed earlier
            let adjustedPoint = CGPoint(
                x: localPoint.x + size.width * 0.4,  // Our previous offset for fanned cards
                y: localPoint.y
            )
            
            // Use a simple rectangular hit box
            let hitBox = CGSize(width: size.width, height: size.height)
            return abs(adjustedPoint.x) < hitBox.width/2 && abs(adjustedPoint.y) < hitBox.height/2
        }
    }
    
    init(card: Card) {
        self.card = card
        super.init(texture: nil, color: .clear, size: CGSize(width: 80, height: 115))
        setupCardDesign()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func getBackgroundColor(for suit: Suit) -> SKColor {
        switch suit {
        case .dawn:
            return SKColor(red: 0xF5/255.0, green: 0xF6/255.0, blue: 0xEC/255.0, alpha: 1.0)  // F5F6EC
        case .night:
            return SKColor(red: 0x6A/255.0, green: 0x68/255.0, blue: 0x79/255.0, alpha: 1.0)  // 6A6879
        case .dusk:
            return SKColor(red: 0xAF/255.0, green: 0x81/255.0, blue: 0xB3/255.0, alpha: 1.0)  // AF81B3
        }
    }
    
    static func getFontColor(for suit: Suit) -> SKColor {
        switch suit {
        case .dawn:
            return SKColor(red: 0x94/255.0, green: 0x52/255.0, blue: 0x00/255.0, alpha: 1.0)  // 945200
        case .night:
            return SKColor(red: 0xD3/255.0, green: 0xC0/255.0, blue: 0x75/255.0, alpha: 1.0)  // D3C075
        case .dusk:
            return SKColor(red: 0x3E/255.0, green: 0x48/255.0, blue: 0x93/255.0, alpha: 1.0)  // 3E4893
        }
    }
    
    private func setupCardDesign() {
        // Rounded background
        let background = SKShapeNode(rectOf: size, cornerRadius: 8)
        background.fillColor = CardNode.getBackgroundColor(for: card.suit)
        background.strokeColor = .clear
        addChild(background)
        
        // Center Suit Image
        let suitImage = SKSpriteNode(imageNamed: "\(card.suit.rawValue.lowercased())-icon")
        let maxDimension: CGFloat = 45  // Base size
        if let texture = suitImage.texture {
            let aspectRatio = texture.size().width / texture.size().height
            let scaleFactor: CGFloat = card.suit == .night ? 0.8 : 1.0  // Scale night icon to 80% of others
            
            if aspectRatio > 1 {
                // Image is wider than tall
                suitImage.size = CGSize(
                    width: maxDimension * scaleFactor,
                    height: (maxDimension / aspectRatio) * scaleFactor
                )
            } else {
                // Image is taller than wide
                suitImage.size = CGSize(
                    width: (maxDimension * aspectRatio) * scaleFactor,
                    height: maxDimension * scaleFactor
                )
            }
        }
        suitImage.position = CGPoint(x: 0, y: 0)
        addChild(suitImage)
        
        let fontColor = CardNode.getFontColor(for: card.suit)
        
        // Top Value and Suit Name (vertical)
        let xOffset: CGFloat = card.value >= 10 ? 14 : 10
        if card.value >= 10 {
            // For double digits, create two separate labels
            let firstDigit = SKLabelNode(fontNamed: "Copperplate")
            firstDigit.text = "\(card.value / 10)"  // First digit
            firstDigit.fontSize = 26
            firstDigit.fontColor = fontColor
            firstDigit.position = CGPoint(x: -size.width/2 + xOffset - 4, y: size.height/2 - 20)
            addChild(firstDigit)
            
            let secondDigit = SKLabelNode(fontNamed: "Copperplate")
            secondDigit.text = "\(card.value % 10)"  // Second digit
            secondDigit.fontSize = 26
            secondDigit.fontColor = fontColor
            secondDigit.position = CGPoint(x: -size.width/2 + xOffset + 8, y: size.height/2 - 20)
            addChild(secondDigit)
        } else {
            let topValue = SKLabelNode(fontNamed: "Copperplate")
            topValue.text = "\(card.value)"
            topValue.fontSize = 26
            topValue.fontColor = fontColor
            topValue.position = CGPoint(x: -size.width/2 + xOffset, y: size.height/2 - 20)
            addChild(topValue)
        }

        let topName = card.suit.rawValue
        let letterSpacing: CGFloat = 10
        let firstLetterOffset: CGFloat = 34

        for (index, letter) in topName.enumerated() {
            let letterLabel = SKLabelNode(fontNamed: "Copperplate")
            letterLabel.text = String(letter)
            letterLabel.fontSize = 10
            letterLabel.fontColor = fontColor
            letterLabel.position = CGPoint(x: -size.width/2 + 10,
                                         y: size.height/2 - firstLetterOffset - CGFloat(index) * letterSpacing)
            addChild(letterLabel)
        }
        // Bottom Value and Suit Name (vertical, upside down)
        let bottomXOffset: CGFloat = card.value >= 10 ? 14 : 10
        if card.value >= 10 {
            // For double digits, create two separate labels
            let firstDigit = SKLabelNode(fontNamed: "Copperplate")
            firstDigit.text = "\(card.value / 10)"  // First digit
            firstDigit.fontSize = 26
            firstDigit.fontColor = fontColor
            firstDigit.position = CGPoint(x: size.width/2 - bottomXOffset - 8, y: -size.height/2 + 20)
            firstDigit.zRotation = .pi
            addChild(firstDigit)
            
            let secondDigit = SKLabelNode(fontNamed: "Copperplate")
            secondDigit.text = "\(card.value % 10)"  // Second digit
            secondDigit.fontSize = 26
            secondDigit.fontColor = fontColor
            secondDigit.position = CGPoint(x: size.width/2 - bottomXOffset + 4, y: -size.height/2 + 20)
            secondDigit.zRotation = .pi
            addChild(secondDigit)
        } else {
            let bottomValue = SKLabelNode(fontNamed: "Copperplate")
            bottomValue.text = "\(card.value)"
            bottomValue.fontSize = 26
            bottomValue.fontColor = fontColor
            bottomValue.position = CGPoint(x: size.width/2 - bottomXOffset, y: -size.height/2 + 20)
            bottomValue.zRotation = .pi
            addChild(bottomValue)
        }

        let reversedName = String(topName.reversed())
        for (index, letter) in reversedName.enumerated() {
            let letterLabel = SKLabelNode(fontNamed: "Copperplate")
            letterLabel.text = String(letter)
            letterLabel.fontSize = 10
            letterLabel.fontColor = fontColor
            letterLabel.position = CGPoint(x: size.width/2 - 10,
                                         y: -size.height/2 + firstLetterOffset + CGFloat(topName.count - 1 - index) * letterSpacing)
            letterLabel.zRotation = .pi
            addChild(letterLabel)
        }
        
    }
    
    func select() {
        isSelected = true
            
            // Store original values
            originalPosition = position
            originalRotation = zRotation
            originalZPosition = zPosition
            
            // Pop out and up
            let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.2)
            let scale = SKAction.scale(to: 1.2, duration: 0.2)
            zRotation = 0  // Reset rotation when selected
            run(SKAction.group([moveUp, scale]))

        // Add glow effect
        let glow = SKShapeNode(rectOf: size, cornerRadius: 8)
        glow.strokeColor = .white
        glow.lineWidth = 3
        glow.name = "selectionGlow"
        glow.alpha = 0
        addChild(glow)
        
        // Animate glow
        glow.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            ]))
        ]))
        
        // Bring selected card to front
        zPosition = 100
    }
    
    func deselect() {
        isSelected = false
        
        // Get the parent GameScene
        guard let gameScene = scene as? GameScene else { return }
        
        // Clear any effect preview
            gameScene.clearEffectPreview()
        
        // Return to original z-position
        if let origZ = originalZPosition {
            zPosition = origZ
        }
        
        // Let the GameScene handle repositioning
        gameScene.updateHand()
        
        run(SKAction.scale(to: 1.0, duration: 0.2))
        
        // Remove glow effect
        childNode(withName: "selectionGlow")?.removeFromParent()
    }
    
    func highlight() {
        highlighted = true
        run(SKAction.scale(to: 1.2, duration: 0.2))
    }
    
    func unhighlight() {
        highlighted = false
        run(SKAction.scale(to: 1.0, duration: 0.2))
    }
}

class ScoreTableNode: SKNode {
    // Constants for styling
    private let cellWidth: CGFloat = 45  // Reduced further for better fit
    private let cellHeight: CGFloat = 30  // Slightly reduced
    private let headerHeight: CGFloat = 20  // Reduced for better spacing
    private let nameColumnWidth: CGFloat = 55  // Reduced for better proportions
    private let tablePadding: CGFloat = 8  // Slightly reduced padding
    private let tableHeight: CGFloat = 70
    
    // Colors
    private let winnerColor = SKColor(red: 0x2E/255.0, green: 0x7D/255.0, blue: 0x32/255.0, alpha: 1.0)  // Soft green
    private let loserColor = SKColor(red: 0xC6/255.0, green: 0x28/255.0, blue: 0x28/255.0, alpha: 1.0)   // Muted red
    private let headerColor = SKColor(red: 0x42/255.0, green: 0x42/255.0, blue: 0x42/255.0, alpha: 1.0)  // Dark gray
    private let bgColor = SKColor(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0, alpha: 1.0)      // Light gray
    private let activeColumnColor = SKColor(red: 0xE3/255.0, green: 0xF2/255.0, blue: 0xFD/255.0, alpha: 1.0) // Light blue
    
    private var cells: [[SKLabelNode]] = []
    private var currentRound = 1
    private var activePlayerIndicator: SKNode?
    
    override init() {
        super.init()
        setupTable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTable() {
        // Create table background
        let tableWidth = nameColumnWidth + (cellWidth * 6) + (tablePadding * 2) // Name + Hand + 5 rounds
        let tableHeight = (cellHeight * 2) + (tablePadding * 2)
        let background = SKShapeNode(rectOf: CGSize(width: tableWidth, height: tableHeight))
        background.fillColor = bgColor
        background.strokeColor = SKColor.gray.withAlphaComponent(0.3)
        background.lineWidth = 1
        background.position = CGPoint(x: tableWidth/2, y: tableHeight/2)
        addChild(background)
        
        // Add headers
        let headers = ["", "", "Rd 1", "Rd 2", "Rd 3", "Rd 4", "Rd 5"]
        for (index, header) in headers.enumerated() {
            let width = index == 0 ? nameColumnWidth : cellWidth
            let x = index == 0 ? tablePadding + width/2 : tablePadding + nameColumnWidth + (CGFloat(index-1) * cellWidth) + width/2
            
            let headerCell = createCell(width: width, height: headerHeight, text: header)
            headerCell.position = CGPoint(x: x, y: tableHeight + 5)  // Positioned above the box
            headerCell.fontColor = headerColor
            headerCell.fontSize = 14
            addChild(headerCell)
        }
        
        // Create player rows
        let players = ["You", "Enemy"]

        // Create background for the name column (full height)
        let nameColumnBackground = SKShapeNode(rectOf: CGSize(width: nameColumnWidth, height: cellHeight * 2.5), cornerRadius: 4)
        nameColumnBackground.fillColor = SKColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)  // Darker gray
        nameColumnBackground.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)  // Border
        nameColumnBackground.lineWidth = 1
        nameColumnBackground.position = CGPoint(x: tablePadding + nameColumnWidth/2,
                                            y: tableHeight - cellHeight - tablePadding)
        nameColumnBackground.zPosition = 1
        addChild(nameColumnBackground)

        // Create background for the hand column (full height)
        let handColumnBackground = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellHeight * 2.5), cornerRadius: 4)
        handColumnBackground.fillColor = SKColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 1.0)  // Light blue
        handColumnBackground.strokeColor = SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0)  // Darker blue border
        handColumnBackground.lineWidth = 1
        handColumnBackground.position = CGPoint(x: tablePadding + nameColumnWidth + cellWidth/2,
                                            y: tableHeight - cellHeight - tablePadding)
        handColumnBackground.zPosition = 1
        addChild(handColumnBackground)

        for (rowIndex, player) in players.enumerated() {
            var rowCells: [SKLabelNode] = []

            // Create player name cell
            let nameCell = createCell(width: nameColumnWidth, height: cellHeight, text: player)
            nameCell.position = CGPoint(x: tablePadding + nameColumnWidth/2,
                                     y: tableHeight - (cellHeight * CGFloat(rowIndex + 1)) + tablePadding)
            nameCell.zPosition = 2
            addChild(nameCell)
            rowCells.append(nameCell)
            
            // Score cells (Hand + 5 rounds)
            for colIndex in 0..<6 {
                let x = tablePadding + nameColumnWidth + (CGFloat(colIndex) * cellWidth) + cellWidth/2
                let y = tableHeight - (cellHeight * CGFloat(rowIndex + 1)) + tablePadding
                let cell = createCell(width: cellWidth, height: cellHeight, text: "—")
                cell.position = CGPoint(x: x, y: y)
                cell.zPosition = 2
                addChild(cell)
                rowCells.append(cell)
            }
            
            cells.append(rowCells)
        }
        
        // Add column separators
        for i in 0...6 {
            let x = tablePadding + nameColumnWidth + (CGFloat(i) * cellWidth)
            let line = SKShapeNode(path: CGPath(rect: CGRect(x: -0.5, y: 0, width: 1, height: tableHeight), transform: nil))
            line.strokeColor = SKColor.gray.withAlphaComponent(0.3)
            line.position = CGPoint(x: x, y: 0)
            addChild(line)
        }
        
        // Add active player indicator
        activePlayerIndicator = createActivePlayerIndicator()
        addChild(activePlayerIndicator!)
        updateActivePlayer(isPlayerTurn: true)
    }
    
    private func createCell(width: CGFloat, height: CGFloat, text: String) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Copperplate")
        label.text = text
        label.fontSize = 15
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        return label
    }
    
    private func createActivePlayerIndicator() -> SKNode {
        let indicator = SKShapeNode(rectOf: CGSize(width: 8, height: 8), cornerRadius: 1)
        indicator.fillColor = .systemBlue
        indicator.strokeColor = .clear
        indicator.position = CGPoint(x: 5, y: cells[0][0].position.y)
        return indicator
    }
    
    // Add these methods to ScoreTableNode

    private func animateScoreChange(row: Int, col: Int, newValue: Int, oldValue: Int) {
        if let label = cells[row][col] as? SKLabelNode {
            // Create temporary overlay for animation
                    let tempLabel = SKLabelNode(fontNamed: "Copperplate")
                    tempLabel.fontSize = label.fontSize
                    tempLabel.fontColor = label.fontColor
                    tempLabel.position = label.position
                    tempLabel.verticalAlignmentMode = .center
                    tempLabel.alpha = 0
                    tempLabel.setScale(1.2)
                    tempLabel.text = "\(newValue)"
                    addChild(tempLabel)
                    
                    // Animate old score fading out and scaling down
                    label.run(SKAction.group([
                        SKAction.scale(to: 0.8, duration: 0.2),
                        SKAction.fadeOut(withDuration: 0.2)
                    ]))
                    
                    // Animate new score fading in and scaling to normal
                    tempLabel.run(SKAction.sequence([
                        SKAction.group([
                            SKAction.fadeIn(withDuration: 0.2),
                            SKAction.scale(to: 1.0, duration: 0.2)
                        ]),
                        SKAction.run { [weak self] in
                            label.text = "\(newValue)"  // Make sure we update the actual text
                            label.alpha = 1.0
                            label.setScale(1.0)
                            tempLabel.removeFromParent()
                        }
                    ]))
                }
            }

    private func animateRoundComplete(round: Int, playerScore: Int, enemyScore: Int, playerWon: Bool, enemyWon: Bool) {
        let col = round + 1
        
        // Animate player score
        let playerLabel = cells[0][col] as? SKLabelNode
        let playerColor = playerWon ? winnerColor : loserColor
        
        // Create flash effect for player
        let playerFlash = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellHeight))
        playerFlash.fillColor = playerColor.withAlphaComponent(0.3)
        playerFlash.strokeColor = .clear
        playerFlash.position = playerLabel?.position ?? .zero
        playerFlash.alpha = 0
        addChild(playerFlash)
        
        // Animate player score change
        if let label = playerLabel {
            label.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.group([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.scale(to: 0.8, duration: 0.2)
                ])
            ]))
            
            // Final score with animation
            let finalLabel = SKLabelNode(fontNamed: "Copperplate")
            finalLabel.text = "\(playerScore)"
            finalLabel.fontSize = label.fontSize
            finalLabel.position = label.position
            finalLabel.verticalAlignmentMode = .center
            finalLabel.alpha = 0
            finalLabel.fontColor = playerColor
            addChild(finalLabel)
            
            finalLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.2)
                ]),
                SKAction.run {
                    label.text = "\(playerScore)"
                    label.fontColor = playerColor
                    label.alpha = 1.0
                    label.setScale(1.0)
                    finalLabel.removeFromParent()
                }
            ]))
        }
        
        // Flash effect animation
        playerFlash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        // Similar animation for enemy score
        let enemyLabel = cells[1][col] as? SKLabelNode
        let enemyColor = enemyWon ? winnerColor : loserColor
        
        // Create flash effect for enemy
        let enemyFlash = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellHeight))
        enemyFlash.fillColor = enemyColor.withAlphaComponent(0.3)
        enemyFlash.strokeColor = .clear
        enemyFlash.position = enemyLabel?.position ?? .zero
        enemyFlash.alpha = 0
        addChild(enemyFlash)
        
        if let label = enemyLabel {
            label.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.group([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.scale(to: 0.8, duration: 0.2)
                ])
            ]))
            
            let finalLabel = SKLabelNode(fontNamed: "Copperplate")
            finalLabel.text = "\(enemyScore)"
            finalLabel.fontSize = label.fontSize
            finalLabel.position = label.position
            finalLabel.verticalAlignmentMode = .center
            finalLabel.alpha = 0
            finalLabel.fontColor = enemyColor
            addChild(finalLabel)
            
            finalLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.2)
                ]),
                SKAction.run {
                    label.text = "\(enemyScore)"
                    label.fontColor = enemyColor
                    label.alpha = 1.0
                    label.setScale(1.0)
                    finalLabel.removeFromParent()
                }
            ]))
        }
        
        enemyFlash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    func updateScore(gameState: GameScoreState, animate: Bool = true) {
        // Always update the hand scores immediately
           let playerHandPoints = gameState.playerHandPoints
           let enemyHandPoints = gameState.enemyHandPoints
           
           // Update current hand scores cells
           updateCell(row: 0, col: 1, text: "\(playerHandPoints)")
           updateCell(row: 1, col: 1, text: "\(enemyHandPoints)")
           
           // If animation is requested, animate the changes
           if animate {
               animateHandScoreChange(isPlayer: true)
               animateHandScoreChange(isPlayer: false)
           }
           
           // Update rounds - iterate through all completed and current rounds
           for round in 0...gameState.currentRound {
               let roundScore = gameState.roundScores[round]
               let roundColumn = round + 2  // +2 because first two columns are player names and current hand
               
               // Update the round scores
               if round < gameState.currentRound {
                   // Completed rounds should show final scores
                   updateCell(row: 0, col: roundColumn, text: "\(roundScore.playerHandsWon)",
                             color: roundScore.playerHandsWon >= 3 ? winnerColor : loserColor)
                   updateCell(row: 1, col: roundColumn, text: "\(roundScore.enemyHandsWon)",
                             color: roundScore.enemyHandsWon >= 3 ? winnerColor : loserColor)
               } else {
                   // Current round shows ongoing scores
                   updateCell(row: 0, col: roundColumn, text: "\(roundScore.playerHandsWon)")
                   updateCell(row: 1, col: roundColumn, text: "\(roundScore.enemyHandsWon)")
               }
           }
           
           // Clear future rounds
           for round in (gameState.currentRound + 1)...4 {
               let roundColumn = round + 2
               updateCell(row: 0, col: roundColumn, text: "—")
               updateCell(row: 1, col: roundColumn, text: "—")
           }
       }
    
    func getHandScorePosition(isPlayer: Bool) -> CGPoint {
        // Convert the hand score cell position to scene coordinates
        let row = isPlayer ? 0 : 1
        let col = 1  // Hand score column
        if let cell = cells[row][col] as? SKLabelNode {
            return cell.convert(CGPoint.zero, to: cell.scene!)
        }
        return .zero
    }
    
    func updateActiveRound(_ round: Int) {
        // Remove existing round highlight
        children.filter { $0.name == "roundHighlight" }.forEach { $0.removeFromParent() }
        
        // Add highlight for current round - positioned above the column
        let roundColumn = round + 2  // +2 because first two columns are name and hand
        let x = tablePadding + nameColumnWidth + (CGFloat(roundColumn-1) * cellWidth) + cellWidth/2
        let y = tableHeight + 5  // Same position as header text
        
        let roundHighlight = SKShapeNode(rectOf: CGSize(width: cellWidth, height: headerHeight + 5), cornerRadius: 4)
        roundHighlight.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 0.4)  // Golden yellow
        roundHighlight.strokeColor = SKColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0)  // Orange
        roundHighlight.lineWidth = 2
        roundHighlight.position = CGPoint(x: x, y: y)
        roundHighlight.zPosition = -0.5
        roundHighlight.name = "roundHighlight"
        addChild(roundHighlight)
    }
    
    func animateHandScoreChange(isPlayer: Bool) {
        let row = isPlayer ? 0 : 1
        let col = 1  // Hand score column
        if let cell = cells[row][col] as? SKLabelNode {
            cell.run(SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 1.2, duration: 0.2),
                    SKAction.fadeAlpha(to: 0.5, duration: 0.1)
                ]),
                SKAction.group([
                    SKAction.scale(to: 1.0, duration: 0.2),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                ])
            ]))
        }
    }
    
    private func updateCell(row: Int, col: Int, text: String, color: SKColor = .black) {
        cells[row][col].text = text
        cells[row][col].fontColor = color
    }
    
    func updateActivePlayer(isPlayerTurn: Bool) {
        let newY = isPlayerTurn ? cellHeight * 1.8 : cellHeight * 0.3
        let moveAction = SKAction.moveBy(x: 0, y: newY - activePlayerIndicator!.position.y, duration: 0.2)
        activePlayerIndicator?.run(moveAction)
    }
}

extension GameScoreState {
    struct RoundScore {
        let playerScore: Int  // Number of hands won in this round
        let enemyScore: Int   // Number of hands won in this round
        var playerWon: Bool { playerScore >= 3 }  // Best of 5, need 3 to win
        var enemyWon: Bool { enemyScore >= 3 }
    }
    
    func getRoundScore(round: Int) -> RoundScore? {
        // Return the scores for each round (showing how many hands each player won)
        // We'll need to track these scores per round in the GameScoreState
        if round > 0 && round <= 5 {  // We have 5 possible rounds
            // This will require adding properties to GameScoreState to track scores per round
            return RoundScore(
                playerScore: roundScores[round - 1].playerHandsWon,
                enemyScore: roundScores[round - 1].enemyHandsWon
            )
        }
        return nil
    }
}

class GameScene: SKScene {
    private var gameState = GameState()
    private var playerHandNodes: [CardNode] = []
    private var playerScoreLabel: SKLabelNode!
    private var playerHandScoreLabel: SKLabelNode!
    private var enemyHandScoreLabel: SKLabelNode!
    private var enemyScoreLabel: SKLabelNode!
    private var statusLabel: SKLabelNode!
    private var faceUpArea: SKNode!
    private var playerFaceUpNode: CardNode?
    private var enemyFaceUpNode: CardNode?
    private var waitingForSecondCard = false
    private var flowIndicator: SKShapeNode?
    private var playerSecondCardNode: SKNode?
    private var nextRoundButton: SKNode?
    private var playerFirstCardNode: CardNode?
    private var enemyFirstCardNode: CardNode?
    private var enemySecondCardNode: CardNode?
    private var playerRoundScoreLabel: SKLabelNode!
    private var enemyRoundScoreLabel: SKLabelNode!
    private var playerMatchScoreLabel: SKLabelNode!
    private var enemyMatchScoreLabel: SKLabelNode!
    private var playerBankedPowerLabel: SKLabelNode!
    private var enemyBankedPowerLabel: SKLabelNode!
    private var scoreTable: ScoreTableNode!
    private var playerFirstPosition: CGPoint {
        return CGPoint(x: size.width/4 - 20, y: size.height/2)  // Moved left
    }

    private var playerSecondPosition: CGPoint {
        return CGPoint(x: size.width/4 + 60, y: size.height/2)  // 80 pixels right of first
    }

    private var enemyFirstPosition: CGPoint {
        return CGPoint(x: 3 * size.width/4 - 20, y: size.height/2)  // Moved left
    }

    private var enemySecondPosition: CGPoint {
        return CGPoint(x: 3 * size.width/4 + 60, y: size.height/2)  // 80 pixels right of first
    }
    
    override func didMove(to view: SKView) {
        setupUI()
        updateUI()
    }
    
    private func setupUI() {
        backgroundColor = SKColor(red: 0xE6/255.0, green: 0xDD/255.0, blue: 0xCF/255.0, alpha: 1.0)  // #E6DDCF
        
        // Create and position score table
        scoreTable = ScoreTableNode()
        // Calculate position to center the table
        let tableWidth = (55 + (45 * 6) + 16) // nameColumnWidth + (cellWidth * 6) + (padding * 2)
        let xPosition = (Int(size.width) - tableWidth) / 2
        scoreTable.position = CGPoint(x: xPosition, y: Int(size.height) - 163) // Moved down slightly
        addChild(scoreTable)
        
        // Banked power labels
        playerBankedPowerLabel = SKLabelNode(fontNamed: "Copperplate")
        playerBankedPowerLabel.position = CGPoint(x: 20, y: size.height - 180)
        playerBankedPowerLabel.fontSize = 17
        playerBankedPowerLabel.fontColor = SKColor(red: 0x4B/255.0, green: 0x00/255.0, blue: 0x82/255.0, alpha: 1.0)
        playerBankedPowerLabel.horizontalAlignmentMode = .left
        addChild(playerBankedPowerLabel)
        playerBankedPowerLabel.setScale(1.0)
        
        enemyBankedPowerLabel = SKLabelNode(fontNamed: "Copperplate")
        enemyBankedPowerLabel.position = CGPoint(x: size.width - 20, y: size.height - 180)
        enemyBankedPowerLabel.fontSize = 17
        enemyBankedPowerLabel.fontColor = SKColor(red: 0x4B/255.0, green: 0x00/255.0, blue: 0x82/255.0, alpha: 1.0)
        enemyBankedPowerLabel.horizontalAlignmentMode = .right
        addChild(enemyBankedPowerLabel)
        enemyBankedPowerLabel.setScale(1.0)
        
        // Setup Next Round button
        let nextRoundBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        nextRoundBackground.fillColor = .systemBlue
        nextRoundBackground.strokeColor = .white
        nextRoundBackground.lineWidth = 2
        
        let nextRoundLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        nextRoundLabel.text = "Next Hand"
        nextRoundLabel.fontSize = 24
        nextRoundLabel.fontColor = .white
        nextRoundLabel.verticalAlignmentMode = .center
        
        let nextRoundNode = SKNode()
        nextRoundNode.addChild(nextRoundBackground)
        nextRoundNode.addChild(nextRoundLabel)
        nextRoundNode.position = CGPoint(x: size.width/2, y: 200)
        nextRoundNode.alpha = 0
        nextRoundNode.name = "nextRoundButton"
        
        nextRoundButton = nextRoundNode
        addChild(nextRoundNode)
        
        // Use Power button setup
        let usePowerBackground = SKShapeNode(rectOf: CGSize(width: 180, height: 40), cornerRadius: 10)
        usePowerBackground.fillColor = CardNode.getFontColor(for: .night)
        usePowerBackground.strokeColor = .white
        usePowerBackground.lineWidth = 2

        let usePowerLabel = SKLabelNode(fontNamed: "Copperplate")
        usePowerLabel.text = "Use Banked Power"
        usePowerLabel.fontSize = 18
        usePowerLabel.fontColor = .white
        usePowerLabel.verticalAlignmentMode = .center

        let usePowerNode = SKNode()
        usePowerNode.addChild(usePowerBackground)
        usePowerNode.addChild(usePowerLabel)
        usePowerNode.position = CGPoint(x: size.width/2, y: 60)
        usePowerNode.alpha = 1
        usePowerNode.name = "usePowerButton"
        addChild(usePowerNode)
        
        // Status label
        statusLabel = SKLabelNode(fontNamed: "Copperplate")
        statusLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        statusLabel.fontSize = 18
        statusLabel.fontColor = SKColor(red: 0x33/255.0, green: 0x22/255.0, blue: 0x11/255.0, alpha: 1.0)
        addChild(statusLabel)
        
        // Face-up area
        faceUpArea = SKNode()
        faceUpArea.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(faceUpArea)
        
        setupHelpButton()
    }
    
    private func updateUI(animate: Bool = false) {
        // Update score table without animation by default
        scoreTable.updateScore(gameState: gameState.scoreState, animate: animate)
        
        // Update the highlighted round
        scoreTable.updateActiveRound(gameState.scoreState.currentRound)
        
        // Update banked power display
        if let playerBanked = gameState.player.bankedPower, playerBanked > 0 {
            playerBankedPowerLabel.text = "Banked: \(playerBanked)"
            playerBankedPowerLabel.alpha = 1
        } else {
            playerBankedPowerLabel.text = "Banked: 0"
            playerBankedPowerLabel.alpha = 0.5
        }
        
        if let enemyBanked = gameState.enemy.bankedPower, enemyBanked > 0 {
            enemyBankedPowerLabel.text = "Banked: \(enemyBanked)"
            enemyBankedPowerLabel.alpha = 1
        } else {
            enemyBankedPowerLabel.text = "Banked: 0"
            enemyBankedPowerLabel.alpha = 0.5
        }
        
        updateUsePowerButton()
        updateHand()
    }
    
    private func setupScoreUI() {
            let topMargin: CGFloat = 120
            let labelSpacing: CGFloat = 25
            let sideMargin: CGFloat = 20
            
            // Match score (top level)
            playerMatchScoreLabel = createScoreLabel(
                position: CGPoint(x: sideMargin, y: size.height - topMargin),
                alignment: .left
            )
            enemyMatchScoreLabel = createScoreLabel(
                position: CGPoint(x: size.width - sideMargin, y: size.height - topMargin),
                alignment: .right
            )
            
            // Round score (middle level)
            playerRoundScoreLabel = createScoreLabel(
                position: CGPoint(x: sideMargin, y: size.height - (topMargin + labelSpacing)),
                alignment: .left,
                fontSize: 16
            )
            enemyRoundScoreLabel = createScoreLabel(
                position: CGPoint(x: size.width - sideMargin, y: size.height - (topMargin + labelSpacing)),
                alignment: .right,
                fontSize: 16
            )
            
            // Hand score (current level)
            playerHandScoreLabel = createScoreLabel(
                position: CGPoint(x: sideMargin, y: size.height - (topMargin + labelSpacing * 2)),
                alignment: .left,
                fontSize: 16
            )
            enemyHandScoreLabel = createScoreLabel(
                position: CGPoint(x: size.width - sideMargin, y: size.height - (topMargin + labelSpacing * 2)),
                alignment: .right,
                fontSize: 16
            )
            
            // Banked power (bottom level)
            playerBankedPowerLabel = createScoreLabel(
                position: CGPoint(x: sideMargin, y: size.height - (topMargin + labelSpacing * 3)),
                alignment: .left,
                fontSize: 18,
                color: SKColor(red: 0x4B/255.0, green: 0x00/255.0, blue: 0x82/255.0, alpha: 1.0)
            )
            enemyBankedPowerLabel = createScoreLabel(
                position: CGPoint(x: size.width - sideMargin, y: size.height - (topMargin + labelSpacing * 3)),
                alignment: .right,
                fontSize: 18,
                color: SKColor(red: 0x4B/255.0, green: 0x00/255.0, blue: 0x82/255.0, alpha: 1.0)
            )
        }
    
    private func createScoreLabel(
            position: CGPoint,
            alignment: SKLabelHorizontalAlignmentMode,
            fontSize: CGFloat = 20,
            color: SKColor = SKColor(red: 0x33/255.0, green: 0x22/255.0, blue: 0x11/255.0, alpha: 1.0)
        ) -> SKLabelNode {
            let label = SKLabelNode(fontNamed: "Copperplate")
            label.position = position
            label.fontSize = fontSize
            label.fontColor = color
            label.horizontalAlignmentMode = alignment
            addChild(label)
            return label
        }
    
    private func updateScores() {
        // Always animate when explicitly updating scores
        scoreTable.updateScore(gameState: gameState.scoreState, animate: true)
    }

    private func updateScoreWithAnimation() {
        scoreTable.updateScore(gameState: gameState.scoreState, animate: true)
    }
    
    // Add function to show/hide Use Power button
    private func updateUsePowerButton() {
        if let button = childNode(withName: "usePowerButton") {
            let bankedPower = gameState.player.bankedPower ?? 0
            let isLocked = gameState.player.isBankedPowerLocked
            
            // Get button components
            let background = button.children.first as? SKShapeNode
            let label = button.children.first(where: { $0 is SKLabelNode }) as? SKLabelNode
            
            // Update button alpha and colors based on state
            if bankedPower == 0 {
                // No banked power - dim everything
                button.alpha = 0.3
                background?.strokeColor = .gray
                label?.fontColor = .gray
                button.childNode(withName: "lockIcon")?.removeFromParent()
            } else if isLocked {
                // Has power but locked - dim and show lock
                button.alpha = 0.3
                background?.strokeColor = .gray
                label?.fontColor = .gray
                
                // Add lock icon if not present
                if button.childNode(withName: "lockIcon") == nil {
                    let lockIcon = SKSpriteNode(imageNamed: "lock-icon")
                    lockIcon.name = "lockIcon"
                    lockIcon.setScale(0.5)
                    lockIcon.position = CGPoint.zero
                    button.addChild(lockIcon)
                }
            } else {
                // Has power and not locked - full visibility
                button.alpha = 1.0
                background?.strokeColor = .white
                label?.fontColor = .white
                button.childNode(withName: "lockIcon")?.removeFromParent()
            }
        }
    }
    
    func updateHand() {
        playerHandNodes.forEach { $0.removeFromParent() }
        playerHandNodes.removeAll()
        
        let cardWidth: CGFloat = 80
        let cardHeight: CGFloat = 115
        
        // Sort the hand by suit and then by value (descending)
        let sortedHand = gameState.player.hand.sorted { card1, card2 in
            if card1.suit != card2.suit {
                return card1.suit < card2.suit  // Sort by suit first, using our Comparable
            }
            return card1.value > card2.value  // Within suit, higher values left
        }
        
        // Fan configuration
        let radius: CGFloat = 340  // Keep this the same
        let fanAngle: CGFloat = .pi / 4  // Keep this the same
        let baseY: CGFloat = -180  // Keep this the same
        let baseX: CGFloat = size.width / 2  // This is fine
        
        let cardCount = CGFloat(sortedHand.count)
        guard cardCount > 0 else { return }
        
        // In updateHand, change how we calculate the angle and positioning:
        let startAngle = .pi/2 + fanAngle/2  // Modified this line
        let angleStep = fanAngle / max(cardCount - 1, 1)

        // Left side cards should be first in the array after sorting
        for (index, card) in sortedHand.enumerated() {  // Removed .reversed()
            let cardNode = CardNode(card: card)
            
            // Calculate position on arc from left to right
            let angle = startAngle - angleStep * CGFloat(index)  // Changed from + to -
            let x = baseX + radius * cos(angle)
            let y = baseY + radius * sin(angle)
            
            // Adjust rotation to face upward
            let rotation = angle - .pi/2
            
            cardNode.position = CGPoint(x: x, y: y)
            cardNode.zRotation = rotation
            cardNode.zPosition = CGFloat(index)  // Lower indices (left cards) should be on top
            
            playerHandNodes.append(cardNode)
            addChild(cardNode)
            
            // Add hover effect node
            let hoverNode = SKNode()
            hoverNode.name = "hoverEffect"
            
            // Create larger hit area for hover
            let hoverArea = SKShapeNode(rectOf: CGSize(width: cardWidth + 10, height: cardHeight + 40))
            hoverArea.fillColor = .clear
            hoverArea.strokeColor = .clear
            hoverNode.addChild(hoverArea)
            
            cardNode.addChild(hoverNode)
        }
    }
    
    private func showFaceUpCards() {
        guard let playerCard = gameState.playerFaceUpCard,
              let enemyCard = gameState.enemyFaceUpCard else { return }
        
        let centerY = size.height/2
        
        // Create player card node
        let playerCardNode = CardNode(card: playerCard)
        playerCardNode.position = CGPoint(x: size.width/4 - 50, y: centerY)
        addChild(playerCardNode)
        playerFirstCardNode = playerCardNode
        
        // Create enemy card node
        let enemyCardNode = CardNode(card: enemyCard)
        enemyCardNode.position = CGPoint(x: 3 * size.width/4 - 50, y: centerY)
        addChild(enemyCardNode)
        enemyFirstCardNode = enemyCardNode
        
        // Animate cards
        playerCardNode.alpha = 0
        enemyCardNode.alpha = 0
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        playerCardNode.run(fadeIn)
        enemyCardNode.run(fadeIn) {
            // Update status text after cards are shown
            self.statusLabel.text = "Select your second card"
        }
        
        waitingForSecondCard = true
        updateUsePowerButton()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Handle help button
            if let helpButton = childNode(withName: "helpButton"),
               helpButton.contains(location) {
                showReferenceOverlay()
                return
            }
            
            // Handle close button in reference overlay
            if let overlay = childNode(withName: "referenceOverlay"),
               let closeButton = overlay.childNode(withName: "closeReference"),
               closeButton.contains(location) {
                hideReferenceOverlay()
                return
            }
        
        // Handle Next Round button
        if let button = nextRoundButton, button.alpha > 0, button.contains(location) {
            handleNextRound()
            return
        }
        
        // Handle New Game button
            if let newGameButton = childNode(withName: "newGameButton"),
               newGameButton.alpha > 0,
               newGameButton.contains(location) {
                startNewGame()
                return
            }
        
        // Handle Use Power button
        if let powerButton = childNode(withName: "usePowerButton"),
           powerButton.alpha > 0,
           powerButton.contains(location) {
            useBankedPower()
            return
        }
        
        if !waitingForSecondCard {
            // First card selection phase
            handleFirstCardTouch(at: location)
        } else {
            // Second card selection phase
            handleSecondCardTouch(at: location)
        }
    }
    
    private func showReferenceOverlay() {
        if let existingOverlay = childNode(withName: "referenceOverlay") {
            existingOverlay.run(SKAction.fadeIn(withDuration: 0.3))
        } else {
            let overlay = createReferenceOverlay()
            addChild(overlay)
            overlay.run(SKAction.fadeIn(withDuration: 0.3))
        }
    }

    private func hideReferenceOverlay() {
        if let overlay = childNode(withName: "referenceOverlay") {
            overlay.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    private func handleFirstCardTouch(at location: CGPoint) {
            // Check if we're deselecting a card
            if let selectedCard = playerHandNodes.first(where: { $0.isSelected }) {
                if selectedCard.contains(location) {
                    // Confirm selection
                    handleFirstCardSelection(selectedCard)
                } else {
                    // Deselect if tapping elsewhere
                    selectedCard.deselect()
                }
            } else {
                // Select a new card
                for cardNode in playerHandNodes {
                    if cardNode.contains(location) {
                        cardNode.select()
                        // Update status text
                        statusLabel.text = "Tap again to confirm selection"
                        break
                    }
                }
            }
        }
        
        private func handleSecondCardTouch(at location: CGPoint) {
            // Check if we're deselecting a card
            if let selectedCard = playerHandNodes.first(where: { $0.isSelected }) {
                if selectedCard.contains(location) {
                    // Confirm selection
                    handleSecondCardSelection(selectedCard)
                } else {
                    // Deselect if tapping elsewhere
                    selectedCard.deselect()
                }
            } else {
                // Select a new card
                for cardNode in playerHandNodes {
                    if cardNode.contains(location) {
                        cardNode.select()
                        // Show what this card would do
                        if let firstCard = gameState.playerFaceUpCard {
                            let combination = CardCombination(firstCard: firstCard, secondCard: cardNode.card)
                            showEffectPreview(for: combination)
                        }
                        statusLabel.text = "Tap again to confirm selection"
                        break
                    }
                }
            }
        }
    
    // Add function to handle using banked power
    private func useBankedPower() {
            guard let bankedPower = gameState.player.bankedPower, bankedPower > 0 else { return }
            
            gameState.scoreState.useBankedPower(amount: bankedPower, isPlayer: true)
            
            // Create animation from banked label to score table
            let startPosition = playerBankedPowerLabel.convert(CGPoint.zero, to: self)
            let endPosition = scoreTable.getHandScorePosition(isPlayer: true)
        
        // Use same animation system as our scoring effects
        let effectNode = SKNode()
        effectNode.position = startPosition
        addChild(effectNode)
        
        let container = SKNode()
        
        // Create glow effect matching our banking theme
        let glow = SKShapeNode(circleOfRadius: 30)
        let bankColor = SKColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0) // Match our banking blue
        glow.fillColor = bankColor.withAlphaComponent(0.2)
        glow.strokeColor = bankColor
        glow.lineWidth = 2
        glow.alpha = 0
        container.addChild(glow)
        
        // Create label
        let label = SKLabelNode(fontNamed: "Copperplate")
        label.text = "+\(bankedPower)"
        label.fontSize = 28
        label.fontColor = bankColor
        label.verticalAlignmentMode = .center
        container.addChild(label)
        
        container.alpha = 0
        container.setScale(0.5)
        effectNode.addChild(container)
        
        // Animation sequence
        container.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.3),
                SKAction.sequence([
                    SKAction.scale(by: 1.2, duration: 0.1),
                    SKAction.scale(by: 1/1.2, duration: 0.1)
                ])
            ]),
            SKAction.wait(forDuration: 0.5),
            SKAction.group([
                SKAction.move(to: endPosition, duration: 0.5),
                SKAction.scale(to: 0.5, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.3)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Animate the score table instead of the old label
        scoreTable.animateHandScoreChange(isPlayer: true)
        
        scoreTable.updateScore(gameState: gameState.scoreState, animate: true)
            
            gameState.player.bankedPower = nil
            updateUI(animate: false)
            updateUsePowerButton()
        }
    
    
    private func animateRoundWinner() {
        let playerScore = gameState.scoreState.playerHandPoints
        let enemyScore = gameState.scoreState.enemyHandPoints
            
        // Handle draw condition first
        if playerScore == enemyScore {
            return
        }

        let winner = playerScore > enemyScore ? "Player" : "Enemy"
        
        // Update scores with animation
        updateScoreWithAnimation()
        
        // Check if this hand win completes a round
        if gameState.scoreState.isRoundComplete {
            // Show round victory celebration
            let roundWinner = gameState.scoreState.playerHandsWon >= 3 ? "Player" : "Enemy"
            
            // Create round victory node
            let victoryNode = SKNode()
            victoryNode.zPosition = 1000
            
            // Add overlay
            let overlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            overlay.fillColor = .black
            overlay.strokeColor = .clear
            overlay.alpha = 0
            victoryNode.addChild(overlay)
            
            // Add victory text
            let roundVictoryLabel = SKLabelNode(fontNamed: "Copperplate")
            roundVictoryLabel.text = "\(roundWinner) Wins Hand!"
            roundVictoryLabel.fontSize = 42
            roundVictoryLabel.fontColor = roundWinner == "Player" ?
                SKColor(red: 0x1E/255.0, green: 0x66/255.0, blue: 0x1E/255.0, alpha: 1.0) :
                SKColor(red: 0x8B/255.0, green: 0x0/255.0, blue: 0x0/255.0, alpha: 1.0)
            roundVictoryLabel.position = CGPoint(x: size.width/2, y: size.height/2)
            roundVictoryLabel.alpha = 0
            victoryNode.addChild(roundVictoryLabel)
            
            // Add shine effect
            let shine = SKShapeNode(circleOfRadius: 120)
            shine.fillColor = roundWinner == "Player" ?
                SKColor(red: 0x1E/255.0, green: 0x66/255.0, blue: 0x1E/255.0, alpha: 0.3) :
                SKColor(red: 0x8B/255.0, green: 0x0/255.0, blue: 0x0/255.0, alpha: 0.3)
            shine.strokeColor = .clear
            shine.position = roundVictoryLabel.position
            shine.alpha = 0
            victoryNode.addChild(shine)
            
            // Add to scene
            addChild(victoryNode)
            
            // Create celebration particles
            let particleCount = 40
            for _ in 0..<particleCount {
                let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...8))
                particle.fillColor = roundWinner == "Player" ?
                    SKColor(hue: 0.3, saturation: CGFloat.random(in: 0.5...1.0), brightness: 1.0, alpha: 1.0) :
                    SKColor(hue: 0.0, saturation: CGFloat.random(in: 0.5...1.0), brightness: 1.0, alpha: 1.0)
                particle.strokeColor = .clear
                particle.position = roundVictoryLabel.position
                particle.alpha = 0
                victoryNode.addChild(particle)
                
                let angle = CGFloat.random(in: 0...2 * .pi)
                let distance = CGFloat.random(in: 100...250)
                let destination = CGPoint(
                    x: particle.position.x + cos(angle) * distance,
                    y: particle.position.y + sin(angle) * distance
                )
                
                particle.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.2),
                        SKAction.move(to: destination, duration: 1.0),
                        SKAction.scale(by: 0.1, duration: 1.0)
                    ]),
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.removeFromParent()
                ]))
            }
            
            // Animate victory elements
            overlay.run(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.3),
                SKAction.wait(forDuration: 2.0),
                SKAction.fadeOut(withDuration: 0.3)
            ]))
            
            shine.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.wait(forDuration: 2.0),
                SKAction.fadeOut(withDuration: 0.3)
            ]))
            
            roundVictoryLabel.run(SKAction.sequence([
                SKAction.scale(to: 0.5, duration: 0.0),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.3),
                    SKAction.scale(to: 1.2, duration: 0.3)
                ]),
                SKAction.scale(to: 1.0, duration: 0.2),
                SKAction.wait(forDuration: 1.5),
                SKAction.fadeOut(withDuration: 0.3)
            ]))
            
            // Remove victory node after animations
            victoryNode.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.6),
                SKAction.removeFromParent()
            ]))
            
            // Show Next Round button after round victory celebration
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { [weak self] in
                self?.nextRoundButton?.run(SKAction.fadeIn(withDuration: 0.3))
            }
        } else {
            // Regular hand victory
            let handVictoryLabel = SKLabelNode(fontNamed: "Copperplate")
            handVictoryLabel.text = "\(winner) Wins Hand!"
            handVictoryLabel.fontSize = 32
            handVictoryLabel.fontColor = winner == "Player" ?
                SKColor(red: 0x1E/255.0, green: 0x66/255.0, blue: 0x1E/255.0, alpha: 1.0) :
                SKColor(red: 0x8B/255.0, green: 0x0/255.0, blue: 0x0/255.0, alpha: 1.0)
            handVictoryLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 150)
            handVictoryLabel.alpha = 0
            addChild(handVictoryLabel)
            
            // Create particle effects for hand victory
            let particleCount = 20
            for _ in 0..<particleCount {
                let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
                particle.fillColor = SKColor(
                    red: CGFloat.random(in: 0.7...1.0),
                    green: CGFloat.random(in: 0.7...1.0),
                    blue: CGFloat.random(in: 0.2...0.3),
                    alpha: 1.0
                )
                particle.strokeColor = .clear
                particle.position = handVictoryLabel.position
                particle.alpha = 0
                addChild(particle)
                
                let angle = CGFloat.random(in: 0...2 * .pi)
                let distance = CGFloat.random(in: 50...150)
                let destination = CGPoint(
                    x: particle.position.x + cos(angle) * distance,
                    y: particle.position.y + sin(angle) * distance
                )
                
                particle.run(SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.2),
                    SKAction.move(to: destination, duration: 0.5),
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.removeFromParent()
                ]))
            }
            
            // Show hand victory text
            handVictoryLabel.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.wait(forDuration: 1.0),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
            
            // Show Next Round button after hand victory
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
                self?.nextRoundButton?.run(SKAction.fadeIn(withDuration: 0.3))
            }
        }
    }
    
    // Add a new method to handle round victory celebration
    private func showRoundVictory(winner: String) {
        // Create node with high z-position to ensure visibility
        let victoryNode = SKNode()
        victoryNode.zPosition = 1000

        // Create semi-transparent overlay for the whole screen
        let overlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        overlay.fillColor = .black
        overlay.strokeColor = .clear
        overlay.alpha = 0
        victoryNode.addChild(overlay)

        // Victory text with dramatic styling
        let victoryLabel = SKLabelNode(fontNamed: "Copperplate")
        victoryLabel.text = "\(winner) Wins Round!"
        victoryLabel.fontSize = 48
        victoryLabel.fontColor = winner == "Player" ?
            SKColor(red: 0x1E/255.0, green: 0x66/255.0, blue: 0x1E/255.0, alpha: 1.0) :  // Green for player
            SKColor(red: 0x8B/255.0, green: 0x0/255.0, blue: 0x0/255.0, alpha: 1.0)      // Red for enemy
        victoryLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        victoryLabel.alpha = 0
        
        // Add shine effect behind text
        let shine = SKShapeNode(circleOfRadius: 150)
        shine.fillColor = winner == "Player" ?
            SKColor(red: 0x1E/255.0, green: 0x66/255.0, blue: 0x1E/255.0, alpha: 0.3) :
            SKColor(red: 0x8B/255.0, green: 0x0/255.0, blue: 0x0/255.0, alpha: 0.3)
        shine.strokeColor = .clear
        shine.position = victoryLabel.position
        shine.alpha = 0
        
        // Add victory elements
        victoryNode.addChild(shine)
        victoryNode.addChild(victoryLabel)
        addChild(victoryNode)

        // Create celebration particles
        let particleCount = 50
        for _ in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...12))
            particle.fillColor = winner == "Player" ?
                SKColor(hue: 0.3, saturation: CGFloat.random(in: 0.5...1.0), brightness: 1.0, alpha: 1.0) :  // Green hues
                SKColor(hue: 0.0, saturation: CGFloat.random(in: 0.5...1.0), brightness: 1.0, alpha: 1.0)    // Red hues
            particle.strokeColor = .clear
            particle.position = CGPoint(x: size.width/2, y: size.height/2)
            particle.alpha = 0
            victoryNode.addChild(particle)
            
            // Random explosion trajectory
            let angle = CGFloat.random(in: 0...2 * .pi)
            let distance = CGFloat.random(in: 100...300)
            let destination = CGPoint(
                x: size.width/2 + cos(angle) * distance,
                y: size.height/2 + sin(angle) * distance
            )
            
            // Animate each particle
            particle.run(SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 0...0.3)),  // Stagger the particles
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.2),
                    SKAction.move(to: destination, duration: 1.2),
                    SKAction.scale(by: 0.1, duration: 1.2)
                ]),
                SKAction.fadeOut(withDuration: 0.3)
            ]))
        }

        // Animate the overlay
        overlay.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.3),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.3)
        ]))

        // Animate the shine effect
        shine.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.group([
                SKAction.scale(by: 1.5, duration: 2.0),
                SKAction.rotate(byAngle: .pi/2, duration: 2.0)
            ]),
            SKAction.fadeOut(withDuration: 0.3)
        ]))

        // Animate the victory text
        victoryLabel.run(SKAction.sequence([
            SKAction.scale(to: 0.5, duration: 0.0),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.scale(to: 1.2, duration: 0.3)
            ]),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.3)
        ]))

        // Remove the victory node after animations complete
        victoryNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.6),
            SKAction.removeFromParent()
        ]))

        // Show next round button after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { [weak self] in
            self?.nextRoundButton?.run(SKAction.fadeIn(withDuration: 0.3))
        }
    }

    
    private func handleNextRound() {
        // Check for game completion first
        if gameState.scoreState.isMatchComplete {
            let winner = gameState.scoreState.playerRoundsWon > gameState.scoreState.enemyRoundsWon ? "Player" : "Enemy"
            showVictoryScreen(winner: winner)
            return
        }
        
        if gameState.scoreState.isRoundComplete {
            let winner = gameState.scoreState.playerHandsWon >= 3 ? "Player" : "Enemy"
            showRoundVictory(winner: winner)
            // Continue with round advancement after celebration
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                guard let self = self else { return }
                self.gameState.scoreState.finishRound()
                self.continueNextRound()
            }
        } else {
            // Starting a new hand in the same round
            gameState.playerFaceUpCard = nil
            gameState.enemyFaceUpCard = nil
            clearFaceUpCards()
            
            playerFirstCardNode?.removeFromParent()
            enemyFirstCardNode?.removeFromParent()
            playerFirstCardNode = nil
            enemyFirstCardNode = nil
            
            // Reset power button state
            if let button = childNode(withName: "usePowerButton"),
               let background = button.children.first as? SKShapeNode,
               let label = button.children.first(where: { $0 is SKLabelNode }) as? SKLabelNode {
                button.childNode(withName: "lockIcon")?.removeFromParent()
                
                let bankedPower = gameState.player.bankedPower ?? 0
                let isLocked = gameState.player.isBankedPowerLocked
                
                if bankedPower > 0 && !isLocked {
                    background.strokeColor = .white
                    label.fontColor = .white
                    button.alpha = 1.0
                } else {
                    background.strokeColor = .gray
                    label.fontColor = .gray
                    button.alpha = 0.3
                }
            }
            
            // Clear locked states
            gameState.player.isBankedPowerLocked = false
            gameState.enemy.isBankedPowerLocked = false
            
            // Hide the next round button
            nextRoundButton?.run(SKAction.fadeOut(withDuration: 0.3))
            
            // Reset state
            waitingForSecondCard = false
            
            // Reset points for new hand
            gameState.scoreState.resetHandPoints()
            
            // Draw new cards if needed
            while gameState.player.hand.count < 10 && !gameState.player.deck.isEmpty {
                gameState.player.drawCard()
            }
            while gameState.enemy.hand.count < 10 && !gameState.enemy.deck.isEmpty {
                gameState.enemy.drawCard()
            }
            
            // Handle AI banked power usage
            if let enemyBanked = gameState.enemy.bankedPower,
               enemyBanked > 0,
               gameState.enemyAI.shouldUseBankedPower(gameState: gameState) {
                animateEnemyBankedPower(amount: enemyBanked)
                gameState.scoreState.useBankedPower(amount: enemyBanked, isPlayer: false)
                gameState.enemy.bankedPower = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.statusLabel.text = "Select your first card"
                }
            } else {
                statusLabel.text = "Select your first card"
            }
            
            // Update UI
            updateUI()
            updateUsePowerButton()
        }
    }

    // New helper method to handle the rest of the round cleanup
    private func continueNextRound() {
        // Check for game completion
        if gameState.scoreState.isMatchComplete {
            let winner = gameState.scoreState.playerRoundsWon > gameState.scoreState.enemyRoundsWon ? "Player" : "Enemy"
            showVictoryScreen(winner: winner)
            return
        }
        
        // Clear game state
        gameState.playerFaceUpCard = nil
        gameState.enemyFaceUpCard = nil
        
        // Clear all visual elements
        clearFaceUpCards()
        
        // Additional cleanup for any remaining nodes
        playerFirstCardNode?.removeFromParent()
        enemyFirstCardNode?.removeFromParent()
        playerFirstCardNode = nil
        enemyFirstCardNode = nil
        
        // Reset state
        waitingForSecondCard = false
        
        // Draw new cards to maintain hand size
        while gameState.player.hand.count < 10 && !gameState.player.deck.isEmpty {
            gameState.player.drawCard()
        }
        while gameState.enemy.hand.count < 10 && !gameState.enemy.deck.isEmpty {
            gameState.enemy.drawCard()
        }
        
        // Update UI
        updateUI()
        updateUsePowerButton()
        statusLabel.text = "Select your first card"
    }
    
    private func showVictoryScreen(winner: String) {
        // Update score display first
        updateUI()
        
        // Create victory node with high z-position
        let victoryNode = SKNode()
        victoryNode.zPosition = 1000  // Ensure it's above all other nodes
        
        // Background overlay
        let overlay = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2,
                                              width: size.width, height: size.height))
        overlay.fillColor = .black
        overlay.strokeColor = .clear
        overlay.alpha = 0.7
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        victoryNode.addChild(overlay)
        
        // Victory text with same high z-position
        let victoryLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        victoryLabel.text = "\(winner) Wins!"
        victoryLabel.fontSize = 48
        victoryLabel.fontColor = .white
        victoryLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        victoryLabel.zPosition = 1000
        
        // Create new game button with same high z-position
        let newGameBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        newGameBackground.fillColor = .systemGreen
        newGameBackground.strokeColor = .white
        newGameBackground.lineWidth = 2
        newGameBackground.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        
        let newGameLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        newGameLabel.text = "New Game"
        newGameLabel.fontSize = 24
        newGameLabel.fontColor = .white
        newGameLabel.verticalAlignmentMode = .center
        newGameLabel.position = newGameBackground.position
        
        let newGameButton = SKNode()
        newGameButton.addChild(newGameBackground)
        newGameButton.addChild(newGameLabel)
        newGameButton.name = "newGameButton"
        newGameButton.zPosition = 1000
        
        // Add victory elements with animation
        addChild(victoryNode)
        addChild(victoryLabel)
        addChild(newGameButton)
        
        // Before showing victory screen, fade out existing game elements
        playerHandNodes.forEach { node in
            node.run(SKAction.fadeOut(withDuration: 0.3))
        }
        
        [playerFirstCardNode, enemyFirstCardNode, playerSecondCardNode, enemySecondCardNode].forEach { node in
            node?.run(SKAction.fadeOut(withDuration: 0.3))
        }
        
        [playerMatchScoreLabel, enemyMatchScoreLabel, playerRoundScoreLabel, enemyRoundScoreLabel,
         playerBankedPowerLabel, enemyBankedPowerLabel].forEach { label in
            label?.run(SKAction.fadeOut(withDuration: 0.3))
        }
        
        // Animate victory elements
        victoryNode.alpha = 0
        victoryLabel.alpha = 0
        newGameButton.alpha = 0
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        victoryNode.run(fadeIn)
        victoryLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            fadeIn,
            SKAction.scale(by: 1.2, duration: 0.2),
            SKAction.scale(by: 1/1.2, duration: 0.2)
        ]))
        newGameButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            fadeIn
        ]))
    }

    // Add new function to handle new game
    private func startNewGame() {
        // Remove all existing nodes
        self.removeAllChildren()
        
        // Create new game state
        gameState = GameState()
        
        // Reset UI
        setupUI()
        updateUI()
        updateUsePowerButton()
        
        // Reset status
        statusLabel.text = "Select your first card"
    }
    
    private func handleFirstCardSelection(_ cardNode: CardNode) {
        cardNode.deselect()
        clearEffectPreview()
        statusLabel.text = ""
        
        // Store current scores before processing
        let currentPlayerScore = gameState.scoreState.playerHandPoints
        let currentEnemyScore = gameState.scoreState.enemyHandPoints
        
        // Process player's first card
        gameState.processFirstCards(playerCard: cardNode.card)
        
        // Remove cards from hands
        if let index = gameState.player.hand.firstIndex(where: { $0.id == cardNode.card.id }) {
            gameState.player.hand.remove(at: index)
        }
        if let index = gameState.enemy.hand.firstIndex(where: { $0.id == gameState.enemyFaceUpCard!.id }) {
            gameState.enemy.hand.remove(at: index)
        }
        
        // Show both face-up cards with animation first
        showFaceUpCards()
        
        // Update scores after cards are shown, with proper delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            // Only animate if scores actually changed
            if self.gameState.scoreState.playerHandPoints != currentPlayerScore {
                self.scoreTable.animateHandScoreChange(isPlayer: true)
            }
            if self.gameState.scoreState.enemyHandPoints != currentEnemyScore {
                self.scoreTable.animateHandScoreChange(isPlayer: false)
            }
            self.updateUI(animate: true)
        }
        
        updateUsePowerButton()
    }

    // Add new method to handle enemy banked power animation
    private func animateEnemyBankedPower(amount: Int) {
        // Create animation from enemy's banked label to score table
        let startPosition = enemyBankedPowerLabel.convert(CGPoint.zero, to: self)
        let endPosition = scoreTable.getHandScorePosition(isPlayer: false)  // Use score table position
        
        let effectNode = SKNode()
        effectNode.position = startPosition
        addChild(effectNode)
        
        let container = SKNode()
        
        // Create glow effect matching our banking theme
        let glow = SKShapeNode(circleOfRadius: 30)
        let bankColor = SKColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0)
        glow.fillColor = bankColor.withAlphaComponent(0.2)
        glow.strokeColor = bankColor
        glow.lineWidth = 2
        glow.alpha = 0
        container.addChild(glow)
        
        // Create label
        let label = SKLabelNode(fontNamed: "Copperplate")
        label.text = "Enemy uses \(amount)"
        label.fontSize = 24
        label.fontColor = bankColor
        label.verticalAlignmentMode = .center
        container.addChild(label)
        
        container.alpha = 0
        container.setScale(0.5)
        effectNode.addChild(container)
        
        // Animation sequence
        container.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.3),
                SKAction.sequence([
                    SKAction.scale(by: 1.2, duration: 0.1),
                    SKAction.scale(by: 1/1.2, duration: 0.1)
                ])
            ]),
            SKAction.wait(forDuration: 0.5),
            SKAction.group([
                SKAction.move(to: endPosition, duration: 0.5),
                SKAction.scale(to: 0.5, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.3)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Animate the score table instead of the old label
        scoreTable.animateHandScoreChange(isPlayer: false)
        
        // Update the actual score
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { [weak self] in
            self?.updateScoreWithAnimation()
        }
    }
    
        
    private func handleSecondCardSelection(_ cardNode: CardNode) {
        cardNode.deselect()
        clearEffectPreview()
        statusLabel.text = ""
        
        // Process both second cards
        gameState.processSecondCards(playerCard: cardNode.card)
        
        // Remove cards from hands
        if let index = gameState.player.hand.firstIndex(where: { $0.id == cardNode.card.id }) {
            gameState.player.hand.remove(at: index)
        }
        if let index = gameState.enemy.hand.firstIndex(where: { $0.id == gameState.enemySecondCard!.id }) {
            gameState.enemy.hand.remove(at: index)
        }
        
        // Create and show player's second card
        let playerSecondNode = CardNode(card: cardNode.card)
        playerSecondNode.position = CGPoint(x: -50, y: 100)
        addChild(playerSecondNode)
        playerSecondNode.run(SKAction.move(to: playerSecondPosition, duration: 0.3))
        playerSecondCardNode = playerSecondNode

        // Create and show enemy's second card
        let enemySecondNode = CardNode(card: gameState.enemySecondCard!)
        enemySecondNode.position = CGPoint(x: size.width + 50, y: size.height/2)
        addChild(enemySecondNode)
        enemySecondNode.run(SKAction.move(to: enemySecondPosition, duration: 0.3))
        enemySecondCardNode = enemySecondNode
        
        // Update initial UI without animation
        updateUI(animate: false)
        
        // Show animations in sequence
            let playerCombo = CardCombination(firstCard: gameState.playerFaceUpCard!, secondCard: cardNode.card)
            
            // First show player's combination effect and update score
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.showCombinationEffect(playerCombo, at: CGPoint(x: self.size.width/4 + 20, y: self.size.height/2 - 50))
            }
            
            // Then show enemy's combination effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                let enemyCombo = CardCombination(
                    firstCard: self.gameState.enemyFaceUpCard!,
                    secondCard: self.gameState.enemySecondCard!
                )
                self.showCombinationEffect(enemyCombo, at: CGPoint(x: 3 * self.size.width/4 + 20, y: self.size.height/2 - 50))
                
                // Show final hand score for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    
                    // Update and show final round score
                    if self.gameState.scoreState.playerHandPoints > self.gameState.scoreState.enemyHandPoints ||
                       self.gameState.scoreState.enemyHandPoints > self.gameState.scoreState.playerHandPoints {
                        self.animateRoundWinner()
                        
                        // Give more time for the round winner animation to complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            self.updateUI(animate: true)
                            self.showNextRoundButton()
                        }
                    } else {
                        // No winner (draw), just update UI and show next round button
                        self.updateUI(animate: true)
                        self.showNextRoundButton()
                    }
                }
            }
            
            updateUsePowerButton()
        }
    
    private func showEffectAnimation(_ text: String, color: SKColor) {
            let effectLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            effectLabel.text = text
            effectLabel.fontSize = 32
            effectLabel.fontColor = color
            effectLabel.position = CGPoint(x: size.width/2, y: size.height/2)
            effectLabel.alpha = 0
            addChild(effectLabel)
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let wait = SKAction.wait(forDuration: 1.0)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            
            effectLabel.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
        }
    
    private func showEffectPreview(for combination: CardCombination) {
        // Clear any existing preview
        childNode(withName: "effectPreview")?.removeFromParent()
        
        // Set color based on combination type - moving this to a constant value per suit combination
        let color: SKColor = switch (combination.firstCard.suit, combination.secondCard.suit) {
        case (.dawn, .dawn):
            SKColor(red: 0x94/255.0, green: 0x52/255.0, blue: 0x00/255.0, alpha: 1.0)  // Fixed dawn color
        case (.night, .night):
            SKColor(red: 0xD3/255.0, green: 0xC0/255.0, blue: 0x75/255.0, alpha: 1.0)  // Fixed night color
        case (.dusk, .dusk):
            SKColor(red: 0x3E/255.0, green: 0x48/255.0, blue: 0x93/255.0, alpha: 1.0)  // Fixed dusk color
        default:
            .white   // Default for mixed combinations
        }
        
        // Create shadow label first
        let shadowLabel = SKLabelNode(fontNamed: "Copperplate")
        shadowLabel.text = combination.getDescription()
        shadowLabel.fontSize = 24
        shadowLabel.fontColor = .black
        shadowLabel.alpha = 0.5
        shadowLabel.position = CGPoint(x: 1, y: -1)  // Small offset for shadow
        
        // Create main label
        let label = SKLabelNode(fontNamed: "Copperplate")
        label.text = combination.getDescription()
        label.fontSize = 24
        label.fontColor = color
        
        // Create container node
        let preview = SKNode()
        preview.name = "effectPreview"
        preview.addChild(shadowLabel)
        preview.addChild(label)
        
        // Position above the cards
        preview.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        preview.alpha = 0
        addChild(preview)
        
        // Animate in with a subtle bounce
        preview.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.05, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }
    
    func clearEffectPreview() {
            childNode(withName: "effectPreview")?.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
    
    // Enhanced version of handleEnemySecondCard
    private func handleEnemySecondCard() {
        guard let enemyFirstCard = gameState.enemyFaceUpCard else { return }
        
        // Check if enemy should use banked power
        if gameState.enemyAI.shouldUseBankedPower(gameState: gameState) {
            useEnemyBankedPower()
            return
        }
        
        // Get AI's decision
        let secondCard = gameState.enemyAI.selectSecondCard(
            hand: gameState.enemy.hand,
            firstCard: enemyFirstCard,
            gameState: gameState
        )
        
        let combination = CardCombination(firstCard: enemyFirstCard, secondCard: secondCard)
        
        // Process combination
        gameState.processCardCombination(
            player: gameState.enemy,
            opponent: gameState.player,
            combination: combination
        )
        
        // Show the card and effects
        playEnemySecondCard(secondCard, combination: combination)
    }

    // Helper to find next card in cycle
    private func findNextInCycleCard(_ cards: [Card], after card: Card) -> Card? {
        let nextSuit: Suit = switch card.suit {
            case .dawn: .night
            case .night: .dusk
            case .dusk: .dawn
        }
        return cards.first { $0.suit == nextSuit }
    }

    // Play enemy's second card with visual feedback
    private func playEnemySecondCard(_ card: Card, combination: CardCombination) {
        let cardNode = CardNode(card: card)
        cardNode.position = CGPoint(x: size.width + 50, y: size.height/2)
        addChild(cardNode)
        
        // Animate card coming in
        let moveAction = SKAction.move(to: CGPoint(x: 3 * size.width/4 + 50, y: size.height/2), duration: 0.3)
        
        cardNode.run(moveAction) { [weak self] in
            self?.showCombinationEffect(combination, at: cardNode.position)
        }
        
        enemySecondCardNode = cardNode
        updateUI()
        
        // Show next round button
        showNextRoundButton()
    }
    
    private func showNextRoundButton() {
        // First move the cards up to make room
        updateLayout()
        
        // After cards have moved, show the button
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.nextRoundButton?.run(SKAction.fadeIn(withDuration: 0.3))
        }
        
        // Disable further card interactions
        waitingForSecondCard = false
        
        // Update UI
        statusLabel.text = "Choose next hand when ready"
        updateUsePowerButton()
    }
    
    private func playPlayerSecondCard(_ card: Card, combination: CardCombination) {
        // Create new card node
        let cardNode = CardNode(card: card)
        cardNode.position = CGPoint(x: -50, y: 100)
        addChild(cardNode)
        
        // Animate card coming in
        let moveAction = SKAction.move(to: CGPoint(x: size.width/4 + 50, y: size.height/2), duration: 0.3)
        
        let color: SKColor = switch (combination.firstCard.suit, combination.secondCard.suit) {
        case (.dawn, .dawn): .yellow
        case (.night, .night): .blue
        case (.dusk, .dusk): .purple
        default: .white
        }
        
        // Create a glow effect
        let glowNode = SKShapeNode(circleOfRadius: 40)
        glowNode.fillColor = .clear
        glowNode.strokeColor = color
        glowNode.lineWidth = 2
        glowNode.alpha = 0
        cardNode.addChild(glowNode)
        
        cardNode.run(moveAction) {
            glowNode.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.5),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                ]))
            ]))
        }
        
        playerSecondCardNode = cardNode
    }
    
    private func updateLayout() {
        // Move hand cards down when next round button is visible
        let handY: CGFloat = nextRoundButton?.alpha == 0 ? 100 : 100  // Changed to position below button
        
        // If the next round button is visible, move the cards in a flatter arc
        let useFlatterArc = nextRoundButton?.alpha != 0
        
        for (index, cardNode) in playerHandNodes.enumerated() {
            let cardSpacing: CGFloat = useFlatterArc ? 100 : 90  // Wider spacing when flatter
            let startX = size.width/2 - (CGFloat(playerHandNodes.count - 1) * cardSpacing/2)
            let targetPosition = CGPoint(x: startX + CGFloat(index) * cardSpacing, y: handY)
            
            // Adjust rotation to be flatter when next round button is visible
            if useFlatterArc {
                cardNode.zRotation = 0  // Cards stay upright
            }
            
            cardNode.run(SKAction.group([
                SKAction.move(to: targetPosition, duration: 0.3),
                useFlatterArc ? SKAction.rotate(toAngle: 0, duration: 0.3) : .init()
            ]))
        }
    }


    private func endTurn() {
        // Clear the board
        waitingForSecondCard = false
        gameState.playerFaceUpCard = nil
        gameState.enemyFaceUpCard = nil
        
        // Draw new cards if needed
        if gameState.player.hand.isEmpty {
            for _ in 0..<3 {
                gameState.player.drawCard()
                gameState.enemy.drawCard()
            }
        }
        
        // Update UI
        updateUI()
        statusLabel.text = "Select your first card"
    }
        
    private func clearFaceUpCards() {
        // Clear all card nodes
        [playerFaceUpNode, enemyFaceUpNode, playerSecondCardNode, enemySecondCardNode].forEach { node in
            node?.removeFromParent()
        }
        
        flowIndicator?.removeFromParent()
        
        // Clear all references
        playerFaceUpNode = nil
        enemyFaceUpNode = nil
        playerSecondCardNode = nil
        enemySecondCardNode = nil
        flowIndicator = nil
        
        // Clear effect labels from remaining cards
        playerHandNodes.forEach { cardNode in
            cardNode.children.forEach { child in
                if child is SKLabelNode {
                    child.removeFromParent()
                }
            }
        }
    }
    
    private func useEnemyBankedPower() {
        guard let bankedPower = gameState.enemy.bankedPower, bankedPower > 0 else { return }
            
            gameState.scoreState.useBankedPower(amount: bankedPower, isPlayer: false)
        
        // Create visual effect for enemy using power
        let effectNode = SKNode()
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = "Enemy uses \(bankedPower) Banked Power!"
        label.fontSize = 24
        label.fontColor = .red
        
        let background = SKShapeNode(rectOf: CGSize(width: label.frame.width + 40, height: 40),
                                    cornerRadius: 10)
        background.fillColor = .black.withAlphaComponent(0.7)
        background.strokeColor = .red
        background.lineWidth = 2
        background.position = label.position
        
        effectNode.addChild(background)
        effectNode.addChild(label)
        effectNode.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        effectNode.alpha = 0
        addChild(effectNode)
        
        // Animate effect
        effectNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        // Clear banked power and update UI
        gameState.enemy.bankedPower = nil
        updateUI()
        
        // Show next round button after using power
        showNextRoundButton()
        
        // Update status
        statusLabel.text = "Choose next hand when ready"
    }
    
    private func evaluateGameSituation() -> (criticalForEnemy: Bool, shouldPlayAggressive: Bool) {
        let playerWins = gameState.scoreState.playerRoundsWon
        let enemyWins = gameState.scoreState.enemyRoundsWon
        
        // Critical if player is one win away from victory
        let isCritical = playerWins == 2
        
        // Play aggressive if:
        // 1. Enemy is behind in wins
        // 2. Enemy is losing current round significantly
        let isSignificantlyBehind = gameState.scoreState.enemyHandPoints + 5 < gameState.scoreState.playerHandPoints
        let shouldBeAggressive = enemyWins < playerWins || isSignificantlyBehind
        
        return (isCritical, shouldBeAggressive)
    }
    
    private func showCardCombinationPreview(_ firstCard: Card, secondCard: Card) {
          // Clear any existing preview
          childNode(withName: "combinationPreview")?.removeFromParent()
          
          let combination = CardCombination(firstCard: firstCard, secondCard: secondCard)
          let description = combination.getDescription()
          
          let preview = SKNode()
          preview.name = "combinationPreview"
          
          // Create background
          let background = SKShapeNode(rectOf: CGSize(width: 300, height: 60), cornerRadius: 10)
          background.fillColor = .black.withAlphaComponent(0.8)
          
          // Set color based on combination type
          let strokeColor: SKColor
          switch (firstCard.suit, secondCard.suit) {
          case (.dawn, .dawn):
              strokeColor = .yellow  // Aggressive
          case (.night, .night):
              strokeColor = .blue    // Banking
          case (.dusk, .dusk):
              strokeColor = .purple  // Control
          default:
              strokeColor = .white   // Mixed
          }
          
          background.strokeColor = strokeColor
          background.lineWidth = 2
          preview.addChild(background)
          
          // Add description text
          let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
          label.text = description
          label.fontSize = 16
          label.fontColor = .white
          label.numberOfLines = 2
          label.verticalAlignmentMode = .center
          preview.addChild(label)
          
          // Position the preview
          preview.position = CGPoint(x: size.width/2, y: size.height/2 - 150)
          preview.alpha = 0
          addChild(preview)
          
          // Animate in
          preview.run(SKAction.fadeIn(withDuration: 0.2))
      }
    
    private func animateScore(text: String,
                             color: SKColor,
                             startPosition: CGPoint,
                             targetPosition: CGPoint?,
                             scale: CGFloat = 1.0,
                             delay: TimeInterval = 0) {
        let container = SKNode()
        container.position = startPosition
        
        // Create glow effect
        let glow = SKShapeNode(circleOfRadius: 30)
        glow.fillColor = color.withAlphaComponent(0.2)
        glow.strokeColor = color
        glow.lineWidth = 2
        glow.alpha = 0
        container.addChild(glow)
        
        // Create main label
        let label = SKLabelNode(fontNamed: "Copperplate")
        label.text = text
        label.fontSize = 28
        label.fontColor = color
        label.verticalAlignmentMode = .center
        container.addChild(label)
        
        container.alpha = 0
        container.setScale(0.5)
        addChild(container)
        
        // Animation sequence
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: scale, duration: 0.3)
        let bounce = SKAction.sequence([
            SKAction.scale(by: 1.2, duration: 0.1),
            SKAction.scale(by: 1/1.2, duration: 0.1)
        ])
        
        let finalAction: SKAction
        if let targetPos = targetPosition {
            finalAction = SKAction.group([
                SKAction.move(to: targetPos, duration: 0.5),
                SKAction.scale(to: 0.5, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.3)
            ])
        } else {
            finalAction = SKAction.group([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 0.5, duration: 0.3)
            ])
        }
        
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.group([fadeIn, scaleUp, bounce]),
            SKAction.wait(forDuration: 1.0),
            finalAction,
            SKAction.removeFromParent()
        ]))
    }
      
    private func showCombinationEffect(_ combination: CardCombination, at position: CGPoint) {
        let immediatePoints = combination.calculateImmediatePoints()
        let bankedPoints = combination.calculateBankedPoints()
        let cancelledPoints = combination.calculateCancelledPoints()
        
        let isPlayerSide = position.x < size.width/2
        let scorePosition = isPlayerSide ?
            scoreTable.getHandScorePosition(isPlayer: true) :
            scoreTable.getHandScorePosition(isPlayer: false)
        
        // Calculate a higher base position above the card
        let baseStartPosition = CGPoint(x: position.x, y: position.y + 140)  // Moved up further
        
        var currentDelay: TimeInterval = 0
        let delayIncrement: TimeInterval = 0.5
        
        // Show immediate points
        if immediatePoints > 0 {
            let color = SKColor(red: 0.8, green: 0.6, blue: 0.0, alpha: 1.0)
            animateScore(text: "+\(immediatePoints)",
                        color: color,
                        startPosition: baseStartPosition,  // Using same base position for all
                        targetPosition: scorePosition,
                        scale: 1.2,
                        delay: currentDelay)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + currentDelay + 1.0) { [weak self] in
                self?.updateScoreWithAnimation()
            }
            currentDelay += delayIncrement
        }

        // Show banked points
        if bankedPoints > 0 {
            let bankPosition = isPlayerSide ?
                playerBankedPowerLabel.convert(CGPoint.zero, to: self) :
                enemyBankedPowerLabel.convert(CGPoint.zero, to: self)
            
            let color = SKColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0)
            animateScore(text: "Bank \(bankedPoints)",
                        color: color,
                        startPosition: baseStartPosition,  // Same position as immediate points
                        targetPosition: bankPosition,
                        delay: currentDelay)
            currentDelay += delayIncrement
        }

        // Show cancelled points
        if cancelledPoints > 0 {
            let color = SKColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
            animateScore(text: "-\(cancelledPoints)",
                        color: color,
                        startPosition: baseStartPosition,  // Same position as others
                        targetPosition: nil,
                        delay: currentDelay)
            currentDelay += delayIncrement
        }
        
        // Update final score after all animations
        DispatchQueue.main.asyncAfter(deadline: .now() + currentDelay + 0.5) { [weak self] in
            self?.updateUI(animate: true)
        }
    }
    
    private func createWrappedText(text: String, fontName: String, fontSize: CGFloat, fontColor: SKColor, position: CGPoint, maxWidth: CGFloat, lineSpacing: CGFloat = 20) -> SKNode {
        let container = SKNode()
        container.position = position
        
        let words = text.components(separatedBy: " ")
        var currentLine = ""
        var currentY: CGFloat = 0
        
        // Create a temporary label to measure text width
        let measureLabel = SKLabelNode(fontNamed: fontName)
        measureLabel.fontSize = fontSize
        
        for word in words {
            let testLine = currentLine.isEmpty ? word : "\(currentLine) \(word)"
            measureLabel.text = testLine
            
            if measureLabel.frame.width <= maxWidth {
                currentLine = testLine
            } else {
                // Create label for completed line
                let lineLabel = SKLabelNode(fontNamed: fontName)
                lineLabel.text = currentLine
                lineLabel.fontSize = fontSize
                lineLabel.fontColor = fontColor
                lineLabel.horizontalAlignmentMode = .left
                lineLabel.verticalAlignmentMode = .top
                lineLabel.position = CGPoint(x: 0, y: currentY)
                container.addChild(lineLabel)
                
                currentY -= lineSpacing
                currentLine = word
            }
        }
        
        // Add the last line
        if !currentLine.isEmpty {
            let lineLabel = SKLabelNode(fontNamed: fontName)
            lineLabel.text = currentLine
            lineLabel.fontSize = fontSize
            lineLabel.fontColor = fontColor
            lineLabel.horizontalAlignmentMode = .left
            lineLabel.verticalAlignmentMode = .top
            lineLabel.position = CGPoint(x: 0, y: currentY)
            container.addChild(lineLabel)
        }
        
        return container
    }

    private func createReferenceOverlay() -> SKNode {
        let overlay = SKNode()
        overlay.name = "referenceOverlay"
        overlay.zPosition = 1000

        let background = SKShapeNode(rectOf: CGSize(width: size.width - 40, height: size.height - 100), cornerRadius: 10)
        background.fillColor = SKColor(red: 0xE6/255.0, green: 0xDD/255.0, blue: 0xCF/255.0, alpha: 1.0)
        background.strokeColor = SKColor(red: 0x8B/255.0, green: 0x4B/255.0, blue: 0x00/255.0, alpha: 1.0)
        background.lineWidth = 3
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.addChild(background)
        
        // Title setup remains the same...
        let titleContainer = SKShapeNode(rectOf: CGSize(width: size.width - 80, height: 40), cornerRadius: 8)
        titleContainer.fillColor = SKColor(red: 0x8B/255.0, green: 0x4B/255.0, blue: 0x00/255.0, alpha: 1.0)
        titleContainer.strokeColor = .clear
        titleContainer.position = CGPoint(x: size.width/2, y: size.height - 80)
        overlay.addChild(titleContainer)
        
        let title = SKLabelNode(fontNamed: "Copperplate")
        title.text = "Card Combinations"
        title.fontSize = 24
        title.fontColor = .white
        title.verticalAlignmentMode = .center
        title.position = titleContainer.position
        overlay.addChild(title)
        
        // Close button setup remains the same...
        let closeButton = SKShapeNode(circleOfRadius: 15)
        closeButton.fillColor = SKColor(red: 0x8B/255.0, green: 0x00/255.0, blue: 0x00/255.0, alpha: 1.0)
        closeButton.strokeColor = .white
        closeButton.position = CGPoint(x: size.width - 40, y: size.height - 70)
        closeButton.name = "closeReference"
        
        let closeX = SKLabelNode(fontNamed: "Copperplate")
        closeX.text = "×"
        closeX.fontSize = 20
        closeX.fontColor = .white
        closeX.verticalAlignmentMode = .center
        closeX.horizontalAlignmentMode = .center
        closeX.position = closeButton.position
        
        overlay.addChild(closeButton)
        overlay.addChild(closeX)
        
        let combinations = [
            ("Dawn + Dawn", "Sum both cards then double the value as points", CardNode.getFontColor(for: .dawn)),
            ("Night + Night", "Sum both cards and double the value as bank", CardNode.getFontColor(for: .night)),
            ("Dusk + Dusk", "Sum of both cards as points AND cancelled banked points", CardNode.getFontColor(for: .dusk)),
            ("Any cross suit combo", "First card normal, second card doubled", SKColor(red: 0x4B/255.0, green: 0x4B/255.0, blue: 0x4B/255.0, alpha: 1.0))
        ]
        
        let startY = size.height - 140
        let spacing: CGFloat = 95  // Slightly increased spacing
        let maxWidth: CGFloat = size.width - 120  // Slightly reduced width for better margins
        
        for (index, combo) in combinations.enumerated() {
            let container = SKNode()
            container.position = CGPoint(x: 40, y: startY - CGFloat(index) * spacing)
            
            // Background for each combination
            let background = SKShapeNode(rectOf: CGSize(width: size.width - 100, height: 85), cornerRadius: 8)
            background.fillColor = .white.withAlphaComponent(0.1)
            background.strokeColor = combo.2.withAlphaComponent(0.3)
            background.lineWidth = 2
            background.position = CGPoint(x: (size.width - 100)/2, y: -20)
            container.addChild(background)
            
            // Title
            let title = SKLabelNode(fontNamed: "Copperplate")
            title.text = combo.0
            title.fontSize = 20
            title.fontColor = combo.2
            title.horizontalAlignmentMode = .left
            container.addChild(title)
            
            // Description with proper wrapping
            let descriptionText = createWrappedText(
                text: combo.1,
                fontName: "Copperplate",
                fontSize: 16,
                fontColor: SKColor(red: 0x33/255.0, green: 0x22/255.0, blue: 0x11/255.0, alpha: 1.0),
                position: CGPoint(x: 0, y: -25),
                maxWidth: maxWidth
            )
            container.addChild(descriptionText)
            
            overlay.addChild(container)
        }
        
        overlay.alpha = 0
        return overlay
    }

    private func setupHelpButton() {
        let buttonSize: CGFloat = 30
        let helpButton = SKShapeNode(circleOfRadius: buttonSize/2)
        helpButton.fillColor = CardNode.getFontColor(for: .dawn)  // Use Dawn color theme
        helpButton.strokeColor = .white
        helpButton.position = CGPoint(x: 40, y: size.height - 40)
        helpButton.name = "helpButton"
        
        let questionMark = SKLabelNode(fontNamed: "Copperplate")
        questionMark.text = "?"
        questionMark.fontSize = 24
        questionMark.fontColor = .white
        questionMark.verticalAlignmentMode = .center
        questionMark.horizontalAlignmentMode = .center
        questionMark.position = helpButton.position
        
        addChild(helpButton)
        addChild(questionMark)
    }
}
