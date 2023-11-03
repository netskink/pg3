//
//  ViewController.swift
//  pg3
//
//  Created by john davis on 11/1/23.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: CGSize(width: 2048, height: 2048))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
        
        
    }
}

