//
//  GameViewController.swift
//  Penumbral
//
//  Created by Braxton Smallwood on 1/5/25.
//



import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            #endif
        }
    }
    
    func startExplorationMode() {
        print("Starting exploration mode")
        
        // Create and present the exploration view controller
        let explorationVC = ExplorationViewController()
        
        // Ensure proper modal presentation
        explorationVC.modalPresentationStyle = .fullScreen
        explorationVC.modalTransitionStyle = .crossDissolve
        
        present(explorationVC, animated: true) {
            print("Exploration mode presented")
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
