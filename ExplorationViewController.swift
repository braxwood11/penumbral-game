//
//  ExplorationViewController.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import UIKit
import SpriteKit

class ExplorationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ExplorationViewController loaded")
        setupExplorationScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ExplorationViewController will appear")
    }
    
    private func setupExplorationScene() {
        print("Setting up exploration scene")
        
        // Create SKView if not already available
        let skView = view as? SKView ?? SKView(frame: view.bounds)
        if view as? SKView == nil {
            view = skView
        }
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Create the exploration realm model
        let celestialRealm = CelestialRealm(startNodeID: "nexus")
        
        // Create exploration deck with sample cards
        let explorationDeck = ExplorationDeck(cards: createBasicExplorationDeck())
        
        // Create and present the scene
        let scene = EnhancedCelestialRealmScene(
            size: view.bounds.size,
            celestialRealm: celestialRealm,
            explorationDeck: explorationDeck
        )
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        print("Exploration scene presented")
    }
    
    // Call this to return to the main game
    func returnToGame() {
        print("Returning to main game")
        
        // Make sure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("ExplorationViewController - About to dismiss")
            
            // If we're presented modally
            if self.presentingViewController != nil {
                print("Dismissing modally presented VC")
                self.dismiss(animated: true) {
                    print("Dismiss completed")
                }
            }
            // If we're in a navigation controller
            else if let navController = self.navigationController {
                print("Popping from navigation controller")
                navController.popViewController(animated: true)
            }
            // Fallback
            else {
                print("No presenting VC or nav controller, trying parent")
                self.parent?.dismiss(animated: true)
            }
        }
    }
}
