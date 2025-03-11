//
//  StartLoadingScreen.swift
//  Penumbral
//
//  Created on 3/10/25.
//

import SpriteKit

class StartScreen: SKScene {
    // MARK: - Properties
    private let titleFont = "Copperplate"
    private let standardFont = "Copperplate"
    
    // Colors matching existing game style
    private let dawnColor = SKColor(red: 0xF5/255.0, green: 0xF6/255.0, blue: 0xEC/255.0, alpha: 1.0)
    private let duskColor = SKColor(red: 0xAF/255.0, green: 0x81/255.0, blue: 0xB3/255.0, alpha: 1.0)
    private let nightColor = SKColor(red: 0x6A/255.0, green: 0x68/255.0, blue: 0x79/255.0, alpha: 1.0)
    
    private var startButton: SKNode!
    
    // MARK: - Initialization
    override func didMove(to view: SKView) {
        createBackground()
        createTitleLogo()
        createStartButton()
        createDecorations()
        
        // Run animations
        animateStartScreen()
    }
    
    // MARK: - UI Setup
    private func createBackground() {
        // Create a gradient background from dark blue to black
        let background = SKSpriteNode(color: SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0), size: self.size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        
        // Add starfield
        createStarfield()
        
        // Add realm orbs in background
        createRealmOrbs()
    }
    
    private func createStarfield() {
        // Create starfield with 150 stars of varying sizes
        for _ in 0..<150 {
            let starSize = CGFloat.random(in: 1...3)
            let star = SKShapeNode(circleOfRadius: starSize)
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.3...1.0)
            addChild(star)
            
            // Add twinkling animation
            let duration = Double.random(in: 1.0...3.0)
            let fadeAction = SKAction.sequence([
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.3...0.6), duration: duration),
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.7...1.0), duration: duration)
            ])
            star.run(SKAction.repeatForever(fadeAction))
        }
    }
    
    private func createRealmOrbs() {
        // Dawn realm orb (top) - moved down and right to avoid title overlap
        createRealmOrb(position: CGPoint(x: size.width * 0.8, y: size.height * 0.6),
                     color: dawnColor, radius: 40, name: "Dawn")
        
        // Dusk realm orb (middle) - positioned to left
        createRealmOrb(position: CGPoint(x: size.width * 0.25, y: size.height * 0.5),
                     color: duskColor, radius: 30, name: "Dusk")
        
        // Night realm orb (bottom) - moved up to avoid button overlap
        createRealmOrb(position: CGPoint(x: size.width * 0.7, y: size.height * 0.4),
                     color: nightColor, radius: 35, name: "Night")
    }
    
    private func createRealmOrb(position: CGPoint, color: SKColor, radius: CGFloat, name: String) {
        let orb = SKNode()
        orb.position = position
        
        // Main glow
        let glow = SKShapeNode(circleOfRadius: radius)
        glow.fillColor = color.withAlphaComponent(0.3)
        glow.strokeColor = color
        glow.lineWidth = 2
        orb.addChild(glow)
        
        // Inner glow
        let innerGlow = SKShapeNode(circleOfRadius: radius * 0.7)
        innerGlow.fillColor = color.withAlphaComponent(0.5)
        innerGlow.strokeColor = .clear
        orb.addChild(innerGlow)
        
        // Small floating particles
        for _ in 0..<6 {
            let particleSize = CGFloat.random(in: 2...4)
            let particle = SKShapeNode(circleOfRadius: particleSize)
            particle.fillColor = .white
            particle.strokeColor = .clear
            
            // Position in orbit around orb
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: radius * 0.3...radius * 1.3)
            particle.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            
            // Add orbit animation
            let orbitSpeed = Double.random(in: 5...12)
            let orbitRadius = distance
            let orbitPath = UIBezierPath(arcCenter: .zero,
                                         radius: orbitRadius,
                                         startAngle: 0,
                                         endAngle: CGFloat.pi * 2,
                                         clockwise: true)
            
            let followOrbit = SKAction.follow(orbitPath.cgPath, asOffset: false, orientToPath: false, duration: orbitSpeed)
            particle.run(SKAction.repeatForever(followOrbit))
            
            orb.addChild(particle)
        }
        
        // Realm name label
        let nameLabel = SKLabelNode(fontNamed: titleFont)
        nameLabel.text = name
        nameLabel.fontSize = 16
        nameLabel.fontColor = color
        nameLabel.verticalAlignmentMode = .bottom
        nameLabel.position = CGPoint(x: 0, y: -radius - 15)
        nameLabel.alpha = 0.8
        orb.addChild(nameLabel)
        
        // Add a pulsing animation to the orb
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.5),
            SKAction.scale(to: 1.0, duration: 1.5)
        ])
        glow.run(SKAction.repeatForever(pulseAction))
        
        addChild(orb)
    }
    
    private func createTitleLogo() {
        // Create a container for the title elements
        let titleContainer = SKNode()
        titleContainer.position = CGPoint(x: size.width/2, y: size.height * 0.75)
        titleContainer.name = "titleContainer"
        
        // Title background panel with glow
        let titlePanel = SKShapeNode(rectOf: CGSize(width: 340, height: 100), cornerRadius: 15)
        titlePanel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.7)
        titlePanel.strokeColor = duskColor
        titlePanel.lineWidth = 3
        titleContainer.addChild(titlePanel)
        
        // Main title text
        let titleText = SKLabelNode(fontNamed: titleFont)
        titleText.text = "PENUMBRAL"
        titleText.fontSize = 48
        titleText.fontColor = .white
        titleText.verticalAlignmentMode = .center
        titleText.position = CGPoint(x: 0, y: 10)
        titleContainer.addChild(titleText)
        
        // Subtitle text
        let subtitleText = SKLabelNode(fontNamed: standardFont)
        subtitleText.text = "Dawn • Dusk • Night"
        subtitleText.fontSize = 20
        subtitleText.fontColor = duskColor
        subtitleText.verticalAlignmentMode = .center
        subtitleText.position = CGPoint(x: 0, y: -30)
        titleContainer.addChild(subtitleText)
        
        // Add title glow
        let titleGlow = SKShapeNode(rectOf: CGSize(width: 310, height: 110), cornerRadius: 15)
        titleGlow.fillColor = .clear
        titleGlow.strokeColor = duskColor.withAlphaComponent(0.5)
        titleGlow.lineWidth = 8
        titleGlow.glowWidth = 10
        titleGlow.position = titlePanel.position
        titleGlow.zPosition = -1
        titleContainer.addChild(titleGlow)
        
        addChild(titleContainer)
    }
    
    private func createStartButton() {
        // Create a container for the button
        let buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: size.width/2, y: size.height * 0.25)
        buttonContainer.name = "startButton"
        
        // Button background
        let buttonWidth: CGFloat = 240
        let buttonHeight: CGFloat = 60
        let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        button.fillColor = dawnColor.withAlphaComponent(0.3)
        button.strokeColor = dawnColor
        button.lineWidth = 3
        buttonContainer.addChild(button)
        
        // Button text
        let buttonText = SKLabelNode(fontNamed: titleFont)
        buttonText.text = "Begin Journey"
        buttonText.fontSize = 28
        buttonText.fontColor = .white
        buttonText.verticalAlignmentMode = .center
        buttonContainer.addChild(buttonText)
        
        // Button glow effect
        let buttonGlow = SKShapeNode(rectOf: CGSize(width: buttonWidth + 10, height: buttonHeight + 10), cornerRadius: 12)
        buttonGlow.fillColor = .clear
        buttonGlow.strokeColor = dawnColor.withAlphaComponent(0.5)
        buttonGlow.lineWidth = 6
        buttonGlow.glowWidth = 8
        buttonGlow.position = button.position
        buttonGlow.zPosition = -1
        buttonContainer.addChild(buttonGlow)
        
        // Add pulsing animation to the button
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        buttonContainer.run(SKAction.repeatForever(pulseAction))
        
        self.startButton = buttonContainer
        addChild(buttonContainer)
    }
    
    private func createDecorations() {
        // Add card symbols at the bottom - adjusted positioning to be more visible
        let symbolsContainer = SKNode()
        symbolsContainer.position = CGPoint(x: size.width/2, y: size.height * 0.1)
        
        // Increased spacing between card symbols and adjusted alignment
        createCardSymbol(position: CGPoint(x: 80, y: 85), color: dawnColor, symbol: "Dawn")
        createCardSymbol(position: CGPoint(x: 200, y: 85), color: duskColor, symbol: "Dusk")
        createCardSymbol(position: CGPoint(x: 320, y: 85), color: nightColor, symbol: "Night")
        
        // Add floating particle effects
        for _ in 0..<30 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3))
            let colors = [dawnColor, duskColor, nightColor]
            particle.fillColor = colors.randomElement()!.withAlphaComponent(0.7)
            particle.strokeColor = .clear
            
            // Random position
            particle.position = CGPoint(
                x: CGFloat.random(in: -150...150),
                y: CGFloat.random(in: -30...70)
            )
            
            // Floating animation
            let moveDistance = CGFloat.random(in: 10...30)
            let moveDuration = Double.random(in: 2...4)
            
            let floatAction = SKAction.sequence([
                SKAction.moveBy(x: 0, y: moveDistance, duration: moveDuration),
                SKAction.moveBy(x: 0, y: -moveDistance, duration: moveDuration)
            ])
            
            particle.run(SKAction.repeatForever(floatAction))
            symbolsContainer.addChild(particle)
        }
        
        // Add version text
        let versionLabel = SKLabelNode(fontNamed: standardFont)
        versionLabel.text = "v1.0"
        versionLabel.fontSize = 14
        versionLabel.fontColor = .white.withAlphaComponent(0.5)
        versionLabel.horizontalAlignmentMode = .right
        versionLabel.position = CGPoint(x: size.width - 20, y: 20)
        addChild(versionLabel)
        
        addChild(symbolsContainer)
    }
    
    private func createCardSymbol(position: CGPoint, color: SKColor, symbol: String) {
            let cardNode = SKNode()
            cardNode.position = position
            
            // Card background
            let card = SKShapeNode(rectOf: CGSize(width: 60, height: 80), cornerRadius: 8)
            card.fillColor = color.withAlphaComponent(0.3)
            card.strokeColor = color
            card.lineWidth = 2
            cardNode.addChild(card)
            
            // Use existing icon images instead of text
            let iconName = symbol.lowercased() + "-icon" // Creates "dawn-icon", "dusk-icon", or "night-icon"
            let iconSprite = SKSpriteNode(imageNamed: iconName)
        
            // Preserve aspect ratio by only setting width
                let iconWidth: CGFloat = 40
                if let texture = iconSprite.texture {
                    let aspectRatio = texture.size().width / texture.size().height
                    let height = iconWidth / aspectRatio
                    iconSprite.size = CGSize(width: iconWidth, height: height)
                }
            
            iconSprite.position = CGPoint(x: 0, y: 0)
            cardNode.addChild(iconSprite)
            
            // Subtle rotation animation
            let rotateAction = SKAction.sequence([
                SKAction.rotate(byAngle: CGFloat.pi * 0.04, duration: 1.5),
                SKAction.rotate(byAngle: -CGFloat.pi * 0.04, duration: 1.5)
            ])
            cardNode.run(SKAction.repeatForever(rotateAction))
            
            addChild(cardNode)
        }
    
    // MARK: - Animations
    private func animateStartScreen() {
        // Animate title appearing
        if let titleContainer = childNode(withName: "titleContainer") {
            titleContainer.setScale(0.5)
            titleContainer.alpha = 0
            
            titleContainer.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.7),
                    SKAction.scale(to: 1.0, duration: 0.7)
                ])
            ]))
        }
        
        // Animate start button appearing
        startButton.alpha = 0
        startButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if startButton.contains(location) {
            handleStartButtonTap()
        }
    }
    
    private func handleStartButtonTap() {
        // Visual feedback
        startButton.run(SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.1),
            SKAction.scale(to: 1.05, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        // Transition to loading screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let loadingScreen = LoadingScreen(size: self.size)
            loadingScreen.scaleMode = .resizeFill
            
            self.view?.presentScene(loadingScreen, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
}

// MARK: - Loading Screen
class LoadingScreen: SKScene {
    // MARK: - Properties
    private let titleFont = "Copperplate"
    private let standardFont = "Copperplate"
    
    // Colors matching existing game style
    private let dawnColor = SKColor(red: 0xF5/255.0, green: 0xF6/255.0, blue: 0xEC/255.0, alpha: 1.0)
    private let duskColor = SKColor(red: 0xAF/255.0, green: 0x81/255.0, blue: 0xB3/255.0, alpha: 1.0)
    private let nightColor = SKColor(red: 0x6A/255.0, green: 0x68/255.0, blue: 0x79/255.0, alpha: 1.0)
    
    private var progressBar: SKShapeNode!
    private var progressFill: SKShapeNode!
    private var progressLabel: SKLabelNode!
    private var loadingTimer: Timer?
    private var currentProgress: CGFloat = 0.0
    
    // MARK: - Initialization
    override func didMove(to view: SKView) {
        createBackground()
        createLoadingIndicator()
        createLoadingText()
        
        // Start the loading process
        startLoading()
    }
    
    // MARK: - UI Setup
    private func createBackground() {
        // Dark background
        let background = SKSpriteNode(color: SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0), size: self.size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        
        // Subtle starfield
        for _ in 0..<50 {
            let starSize = CGFloat.random(in: 0.5...2)
            let star = SKShapeNode(circleOfRadius: starSize)
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.2...0.6)
            addChild(star)
        }
        
        // Title text
        let titleText = SKLabelNode(fontNamed: titleFont)
        titleText.text = "PENUMBRAL"
        titleText.fontSize = 40
        titleText.fontColor = .white
        titleText.position = CGPoint(x: size.width/2, y: size.height * 0.7)
        addChild(titleText)
    }
    
    private func createLoadingIndicator() {
        // Progress bar container
        let barWidth: CGFloat = size.width * 0.7
        let barHeight: CGFloat = 15
        
        progressBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: barHeight/2)
        progressBar.fillColor = SKColor(white: 0.2, alpha: 0.5)
        progressBar.strokeColor = .white
        progressBar.lineWidth = 1
        progressBar.position = CGPoint(x: size.width/2, y: size.height * 0.4)
        addChild(progressBar)
        
        // Progress fill - starts empty and will be redrawn during updates
        progressFill = SKShapeNode()
        progressFill.fillColor = duskColor
        progressFill.strokeColor = .clear
        progressFill.position = progressBar.position
        progressFill.zPosition = progressBar.zPosition + 1
        addChild(progressFill)
        
        // Progress percentage label
        progressLabel = SKLabelNode(fontNamed: standardFont)
        progressLabel.text = "0%"
        progressLabel.fontSize = 18
        progressLabel.fontColor = .white
        progressLabel.position = CGPoint(x: size.width/2, y: size.height * 0.4 - 30)
        addChild(progressLabel)
    }
    
    private func createLoadingText() {
        // Loading text that changes
        let loadingLabel = SKLabelNode(fontNamed: standardFont)
        loadingLabel.text = "Aligning the celestial realms..."
        loadingLabel.fontSize = 20
        loadingLabel.fontColor = .white
        loadingLabel.position = CGPoint(x: size.width/2, y: size.height * 0.3)
        loadingLabel.name = "loadingLabel"
        addChild(loadingLabel)
        
        // Animated dots
        let dotsLabel = SKLabelNode(fontNamed: standardFont)
        dotsLabel.text = "..."
        dotsLabel.fontSize = 20
        dotsLabel.fontColor = .white
        dotsLabel.position = CGPoint(x: size.width/2 + 140, y: size.height * 0.3)
        addChild(dotsLabel)
        
        // Animate the dots
        let dotsAnimation = SKAction.sequence([
            SKAction.run { dotsLabel.text = "." },
            SKAction.wait(forDuration: 0.3),
            SKAction.run { dotsLabel.text = ".." },
            SKAction.wait(forDuration: 0.3),
            SKAction.run { dotsLabel.text = "..." },
            SKAction.wait(forDuration: 0.3)
        ])
        dotsLabel.run(SKAction.repeatForever(dotsAnimation))
        
        // Cycle through different loading messages
        let loadingMessages = [
            "Aligning the celestial realms",
            "Shuffling the Dawn cards",
            "Gathering Dusk energies",
            "Attuning to Night resonance",
            "Balancing the elements"
        ]
        
        var messageIndex = 0
        let changeMessageAction = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run {
                messageIndex = (messageIndex + 1) % loadingMessages.count
                loadingLabel.text = loadingMessages[messageIndex]
            }
        ])
        
        loadingLabel.run(SKAction.repeatForever(changeMessageAction))
    }
    
    // MARK: - Loading Process
    private func startLoading() {
        // Simulate loading process with a timer
        loadingTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateLoading), userInfo: nil, repeats: true)
    }
    
    @objc private func updateLoading() {
        // Update progress
        let barWidth = progressBar.frame.width
        let barHeight = progressBar.frame.height - 4
        
        // Add random increment to progress (realistic loading simulation)
        let increment = CGFloat.random(in: 0.002...0.015)
        currentProgress += increment
        
        if currentProgress >= 1.0 {
            currentProgress = 1.0
            loadingTimer?.invalidate()
            loadingTimer = nil
            
            // Loading complete, transition to game scene
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.transitionToGame()
            }
        }
        
        // Calculate proper fill dimensions
        let fillWidth = barWidth * currentProgress
        
        // Create new fill path - correcting the positioning to properly align with the progressBar
        let rect = CGRect(
            x: progressBar.position.x - barWidth/2,
            y: progressBar.position.y - barHeight/2,
            width: fillWidth,
            height: barHeight
        )
        
        // Recreate the fill shape with correct position
        progressFill.removeFromParent() // Remove old fill
        progressFill = SKShapeNode(
            rect: rect,
            cornerRadius: barHeight/2
        )
        progressFill.fillColor = SKColor(hue: currentProgress * 0.5, saturation: 0.8, brightness: 0.9, alpha: 1.0)
        progressFill.strokeColor = .clear
        progressFill.zPosition = progressBar.zPosition + 1
        addChild(progressFill)
        
        // Update percentage text
        let percentage = Int(currentProgress * 100)
        progressLabel.text = "\(percentage)%"
    }
    
    private func transitionToGame() {
            // Create a flash effect
            let flash = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            flash.fillColor = .white
            flash.strokeColor = .clear
            flash.alpha = 0
            addChild(flash)
            
            // Flash transition
            flash.run(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.8, duration: 0.2),
                SKAction.fadeAlpha(to: 0, duration: 0.2),
                SKAction.run {
                    // Transition to the Exploration screen instead of GameScene
                    if let viewController = self.view?.window?.rootViewController as? GameViewController {
                        viewController.startExplorationMode()
                    } else {
                        // Fallback to normal game if controller not available
                        let gameScene = GameScene(size: self.size)
                        gameScene.scaleMode = .resizeFill
                        self.view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.3))
                    }
                }
            ]))
        }
    }
