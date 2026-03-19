//
//  GameScene.swift
//  pg3
//
//  Created by john davis on 11/1/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    
    let shermanHull = SKSpriteNode(imageNamed: "sherman-hull")
    let shermanTurret = SKSpriteNode(imageNamed: "sherman-turret")
    
    var lastUpateTime: TimeInterval = 0
    var dt: TimeInterval = 0

    let shermanMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    var isSherman = true

    
    
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
        //print("size: \(size.width), \(size.height)")
        
        // Add hull
        shermanHull.position = CGPoint(x: size.width/4, y: size.height/4)  // position in view
        shermanHull.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        shermanHull.size = CGSize(width: 411, height: 144)  // This 0.25% of original x and y
        shermanHull.zPosition = 1
        // The hull is added to the view
        addChild(shermanHull)

        // Add turret
        shermanTurret.position = CGPoint(x: 0, y: 0)  // position in view
        shermanTurret.anchorPoint = CGPoint(x: 0.49, y: 0.5) // make center a little offset in image
        shermanTurret.size = CGSize(width: 411, height: 144)  // This 0.25% of original x and y
        shermanTurret.zPosition = 2
        // The turret is added to the hull, so we can move as a unit.
        shermanHull.addChild(shermanTurret)
        
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if lastUpateTime > 0 {
            dt = currentTime - lastUpateTime
        } else {
            dt = 0
        }
        lastUpateTime = currentTime
        //print("\(dt*1000) ms since last upate")
        
        moveSprite(sprite: shermanHull, velocity: CGPoint(x: shermanMovePointsPerSec, y: shermanMovePointsPerSec/4))
        checkBounds()
    }

    func checkBounds() {
        let halfW = shermanHull.size.width / 2
        let halfH = shermanHull.size.height / 2
        if shermanHull.position.x - halfW > size.width ||
           shermanHull.position.y - halfH > size.height {
            // Reset to starting position
            shermanHull.position = CGPoint(x: size.width/4, y: size.height/4)
            // Swap tank
            isSherman = !isSherman
            if isSherman {
                shermanHull.texture = SKTexture(imageNamed: "sherman-hull")
                shermanTurret.texture = SKTexture(imageNamed: "sherman-turret")
            } else {
                shermanHull.texture = SKTexture(imageNamed: "tiger-hull")
                shermanTurret.texture = SKTexture(imageNamed: "tiger-turret")
            }
        }
    }

    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        //print("Amount to move: \(amountToMove)")
        
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x,
                                  y: sprite.position.y + amountToMove.y)
    }
}
