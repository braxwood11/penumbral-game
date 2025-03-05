//
//  NodeInteractionScreen.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/4/25.
//

import SpriteKit

// Base class for all node interaction screens
class NodeInteractionScreen: SKNode {
    // Reference to the node data
    let node: WorldNode
    
    var celestialRealm: CelestialRealm?
    
    // Reference to the parent scene for callbacks
    weak var parentScene: EnhancedCelestialRealmScene?
    
    // Common UI elements
    private var background: SKShapeNode!
    private var headerPanel: SKShapeNode!
    private var titleLabel: SKLabelNode!
    internal var contentArea: SKNode!  // Changed from private to internal
    private var returnButton: SKNode!
    
    // Screen dimensions
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    // Initialize with the node data and screen dimensions
    init(node: WorldNode, size: CGSize, parentScene: EnhancedCelestialRealmScene?) {
        self.node = node
        self.parentScene = parentScene
        self.celestialRealm = parentScene?.celestialRealm
        self.screenWidth = size.width
        self.screenHeight = size.height
        
        super.init()
        
        setupCommonElements()
        setupSpecificContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupCommonElements() {
        // Semi-transparent full-screen background
        background = SKShapeNode(rect: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        background.fillColor = SKColor.black.withAlphaComponent(0.7)
        background.strokeColor = .clear
        background.zPosition = 0
        addChild(background)
        
        // Main content panel
        let contentHeight: CGFloat = screenHeight * 0.7
        let contentPanel = SKShapeNode(rectOf: CGSize(width: screenWidth - 60, height: contentHeight), cornerRadius: 15)
        contentPanel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.9)
        contentPanel.strokeColor = .white
        contentPanel.lineWidth = 2
        contentPanel.position = CGPoint(x: screenWidth/2, y: screenHeight/2)
        contentPanel.zPosition = 10
        addChild(contentPanel)
        
        // Header panel with realm-colored background
        headerPanel = SKShapeNode(rectOf: CGSize(width: screenWidth - 60, height: 50), cornerRadius: 15)
        headerPanel.fillColor = node.realm.color.withAlphaComponent(0.8)
        headerPanel.strokeColor = .white
        headerPanel.lineWidth = 1
        headerPanel.position = CGPoint(x: screenWidth/2, y: screenHeight/2 + contentHeight/2 - 25)
        headerPanel.zPosition = 20
        addChild(headerPanel)
        
        // Title label
        titleLabel = SKLabelNode(fontNamed: "Copperplate")
        titleLabel.text = getTitle()
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = headerPanel.position
        titleLabel.zPosition = 30
        addChild(titleLabel)
        
        // Container for specific content
        contentArea = SKNode()
        contentArea.position = CGPoint(x: screenWidth/2, y: screenHeight/2)
        contentArea.zPosition = 20
        addChild(contentArea)
        
        // Return button
        returnButton = createButton(
            text: "Return to Exploration",
            size: CGSize(width: 200, height: 40),
            position: CGPoint(x: screenWidth/2, y: screenHeight/2 - contentHeight/2 + 40)
        )
        returnButton.name = "returnToExplorationButton"
        returnButton.zPosition = 30
        addChild(returnButton)
        
        // Add animation for appearance
        self.alpha = 0
        self.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    // Override in subclasses to provide specific content
    func setupSpecificContent() {
        // Base implementation does nothing
        // Override in subclasses
    }
    
    // Override to provide a specific title based on node type
    func getTitle() -> String {
        return "Node Interaction"
    }
    
    // MARK: - Helper Methods
    
    func createButton(text: String, size: CGSize, position: CGPoint) -> SKNode {
        let button = SKNode()
        
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.8)
        background.strokeColor = .white
        background.lineWidth = 2
        button.addChild(background)
        
        let label = SKLabelNode(fontNamed: "Copperplate")
        label.text = text
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        button.position = position
        return button
    }
    
    func createInfoText(text: String, fontSize: CGFloat = 18, maxWidth: CGFloat? = nil, position: CGPoint) -> SKNode {
        let textNode = SKLabelNode(fontNamed: "Copperplate")
        textNode.text = text
        textNode.fontSize = fontSize
        textNode.fontColor = .white
        textNode.verticalAlignmentMode = .center
        
        if let maxWidth = maxWidth {
            textNode.preferredMaxLayoutWidth = maxWidth
            textNode.numberOfLines = 0
        }
        
        textNode.position = position
        return textNode
    }
    
    // MARK: - Touch Handling
    
    func handleTouch(at location: CGPoint) -> Bool {
        // Convert location to this node's coordinate space
        let localLocation = convert(location, from: self.scene!)
        
        // Check for return button touch
        if let returnButton = childNode(withName: "returnToExplorationButton") {
            if returnButton.contains(localLocation) {
                dismiss()
                return true
            }
        }
        
        // Check for other button touches - override in subclasses
        return false
    }
    
    // MARK: - Dismissal
    
    func dismiss() {
        self.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.run { [weak self] in
                self?.removeFromParent()
            }
        ]))
    }
}
