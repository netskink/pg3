//
//  GameScene.swift
//  pg3
//
//  Created by john davis on 11/1/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    
    override func didMove(to view: SKView) {
        // background
        let background = SKSpriteNode(imageNamed: "map3")
        background.position = CGPoint(x: size.width/2, y: size.height/2)  // position in view
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default make anchor, the center of image
        background.zPosition = -1
        addChild(background)
        // size is for the view, we set it as 2048,2048
        // The image is 2000,2000
        // Also notice the black bars on side
        print("size: \(size.width), \(size.height)")
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}
