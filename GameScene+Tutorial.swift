//
//  GameScene+Tutorial.swift
//  Penumbral
//
//  Created by Braxton Smallwood on 3/1/25.
//

import SpriteKit

// MARK: - Tutorial Extension
extension GameScene {
    // Add a tutorial manager property
    private struct TutorialKeys {
        static var managerKey = "tutorialManager"
    }
    
    // Use the objc_getAssociatedObject/objc_setAssociatedObject
    var tutorialManager: TutorialManager? {
        get {
            return objc_getAssociatedObject(self, &TutorialKeys.managerKey) as? TutorialManager
        }
        set {
            objc_setAssociatedObject(self, &TutorialKeys.managerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Function to set up the tutorial
    func setupTutorial() {
        // Only show tutorial if it hasn't been completed
        let tutorialCompleted = UserDefaults.standard.bool(forKey: "tutorialCompleted")
        
        tutorialManager = TutorialManager(gameScene: self)
        
        if !tutorialCompleted {
            addTutorialButton()
        } else {
            // Only add restart button in debug builds
            #if DEBUG
            addRestartTutorialButton()
            #endif
        }
    }
    
    private func addTutorialButton() {
        // Position it directly under the score table
        let buttonSize: CGFloat = 30
        let tutorialButton = SKShapeNode(circleOfRadius: buttonSize/2)
        tutorialButton.fillColor = CardNode.getFontColor(for: .dawn) // Using Dawn color for better visibility
        tutorialButton.strokeColor = .white
        tutorialButton.lineWidth = 2
        
        // Calculate position to be centered horizontally and below the score table
        // The score table is positioned at (size.width/2, size.height - 163) with calculation
        tutorialButton.position = CGPoint(x: size.width/2, y: size.height - 200)
        tutorialButton.name = "tutorialButton"
        
        // Create a more noticeable label
        let tutorialLabel = SKLabelNode(fontNamed: "Copperplate")
        tutorialLabel.text = "Tutorial"
        tutorialLabel.fontSize = 18
        tutorialLabel.fontColor = .white
        tutorialLabel.verticalAlignmentMode = .center
        tutorialLabel.horizontalAlignmentMode = .center
        tutorialLabel.position = tutorialButton.position
        
        // Create a more visible background for the button
        let bg = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 8)
        bg.fillColor = CardNode.getFontColor(for: .dawn)
        bg.strokeColor = .white
        bg.lineWidth = 2
        bg.position = tutorialButton.position
        
        // Add elements to scene
        addChild(bg)
        addChild(tutorialLabel)
        
        // Animate the button to draw attention
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        bg.run(SKAction.repeatForever(pulseAction))
    }

    private func addRestartTutorialButton() {
        let buttonSize: CGFloat = 30
        let restartButton = SKShapeNode(circleOfRadius: buttonSize/2)
        restartButton.fillColor = CardNode.getFontColor(for: .night)
        restartButton.strokeColor = .white
        restartButton.position = CGPoint(x: size.width - 40, y: size.height - 40)
        restartButton.name = "restartTutorialButton"
        restartButton.alpha = 0.7
        
        let restartLabel = SKLabelNode(fontNamed: "Copperplate")
        restartLabel.text = "T"
        restartLabel.fontSize = 18
        restartLabel.fontColor = .white
        restartLabel.verticalAlignmentMode = .center
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.position = restartButton.position
        
        addChild(restartButton)
        addChild(restartLabel)
    }
    
    func startTutorial() {
        tutorialManager?.startTutorial()
        childNode(withName: "tutorialButton")?.run(SKAction.fadeOut(withDuration: 0.3))
    }
    
    // Handle tutorial touches - add this at the START of your existing touchesBegan
    func handleTutorialTouch(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let touch = touches.first else { return false }
        let location = touch.location(in: self)
        
        // Check if tutorial button was tapped
        if let tutorialButton = childNode(withName: "tutorialButton"),
           tutorialButton.contains(location) {
            startTutorial()
            return true
        }
        
        // Check if restart tutorial button was tapped
        if let restartButton = childNode(withName: "restartTutorialButton"),
           restartButton.contains(location) {
            UserDefaults.standard.set(false, forKey: "tutorialCompleted")
            startTutorial()
            return true
        }
        
        // Let the tutorial manager handle taps if active
        if let tutorialManager = tutorialManager,
           tutorialManager.isActive,
           tutorialManager.handleTap(at: location) {
            return true
        }
        
        return false
    }
    
    
    // Call these methods at appropriate points in the game flow
    
    // Call after handling first card selection
    func notifyTutorialFirstCardSelected() {
        tutorialManager?.handleAction(.selectFirstCard)
    }
    
    // Call after handling second card selection
    func notifyTutorialSecondCardSelected() {
        tutorialManager?.handleAction(.selectSecondCard)
    }
    
    // Call after next round button press
    func notifyTutorialNextRound() {
        tutorialManager?.handleAction(.tapNextRound)
    }
    
    // Call after using banked power
    func notifyTutorialBankUsed() {
        tutorialManager?.handleAction(.useBankedPower)
    }
    
    // Call after help button press
    func notifyTutorialHelpUsed() {
        tutorialManager?.handleAction(.tapHelp)
    }
}

// MARK: - Import
import ObjectiveC
