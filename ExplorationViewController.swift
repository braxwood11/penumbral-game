//
//  ExplorationViewController.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import UIKit
import SpriteKit

class EnhancedExplorationViewController: UIViewController {
    
    private var explorationScene: EnhancedCelestialRealmScene?
    private var loadingIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingIndicator()
        setupExplorationScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start loading animation
        loadingIndicator?.startAnimating()
    }
    
    private func setupLoadingIndicator() {
        // Create a loading indicator
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        
        // Add background
        let background = UIView(frame: view.bounds)
        background.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        background.tag = 100 // For easy identification
        view.insertSubview(background, belowSubview: indicator)
        
        // Add loading text
        let label = UILabel()
        label.text = "Entering the Celestial Realm..."
        label.textColor = .white
        label.font = UIFont(name: "Copperplate", size: 18)
        label.sizeToFit()
        label.center = CGPoint(x: view.center.x, y: view.center.y + 40)
        label.tag = 101 // For easy identification
        view.addSubview(label)
        
        loadingIndicator = indicator
    }
    
    private func setupExplorationScene() {
        // Create SKView if not already available
        let skView = view as? SKView ?? SKView(frame: view.bounds)
        if view as? SKView == nil {
            view = skView
        }
        
        // Configure view properties
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        // Show loading indicator during setup
        loadingIndicator?.startAnimating()
        
        // Create the exploration realm model asynchronously
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Create celestial realm model with proper starting node
            let celestialRealm = CelestialRealm(startNodeID: "nexus")
            
            // Create exploration deck with sample cards
            let explorationDeck = ExplorationDeck(cards: createBasicExplorationDeck())
            
            // Return to main thread to update UI
            DispatchQueue.main.async {
                guard let self = self, let skView = self.view as? SKView else { return }
                
                // Create and present the scene
                let scene = EnhancedCelestialRealmScene(
                    size: self.view.bounds.size,
                    celestialRealm: celestialRealm,
                    explorationDeck: explorationDeck
                )
                scene.scaleMode = .resizeFill
                
                // Store reference
                self.explorationScene = scene
                
                // Present scene with transition
                let transition = SKTransition.crossFade(withDuration: 1.0)
                skView.presentScene(scene, transition: transition)
                
                // Hide loading elements
                self.loadingIndicator?.stopAnimating()
                if let bg = self.view.viewWithTag(100) {
                    UIView.animate(withDuration: 0.5, animations: {
                        bg.alpha = 0
                    }, completion: { _ in
                        bg.removeFromSuperview()
                    })
                }
                if let label = self.view.viewWithTag(101) {
                    UIView.animate(withDuration: 0.5, animations: {
                        label.alpha = 0
                    }, completion: { _ in
                        label.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    // Call this to return to the main game
    func returnToGame() {
        // First show a return animation
        showReturnTransition { [weak self] in
            // Make sure we're on the main thread
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // If we're presented modally
                if self.presentingViewController != nil {
                    self.dismiss(animated: true)
                }
                // If we're in a navigation controller
                else if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
                // Fallback
                else {
                    self.parent?.dismiss(animated: true)
                }
            }
        }
    }
    
    private func showReturnTransition(completion: @escaping () -> Void) {
        if let skView = view as? SKView, let scene = skView.scene {
            // Create a fade transition
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            
            // Create text to display during transition
            let transitionNode = SKNode()
            transitionNode.zPosition = 9999
            
            let overlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: scene.size.width, height: scene.size.height))
            overlay.fillColor = .black
            overlay.strokeColor = .clear
            overlay.alpha = 0
            transitionNode.addChild(overlay)
            
            let label = SKLabelNode(fontNamed: "Copperplate")
            label.text = "Returning to Battle..."
            label.fontSize = 24
            label.fontColor = .white
            label.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
            label.alpha = 0
            transitionNode.addChild(label)
            
            scene.addChild(transitionNode)
            
            // Animate transition
            overlay.run(SKAction.fadeAlpha(to: 0.8, duration: 0.5))
            label.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.fadeIn(withDuration: 0.3)
            ]))
            
            // Fade out scene
            scene.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                fadeOut,
                SKAction.run {
                    completion()
                }
            ]))
        } else {
            // Fallback if no SKView
            completion()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
