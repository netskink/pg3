//
//  GameScene.swift
//  pg3
//
//  Created by john davis on 11/1/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    let tankHull = SKSpriteNode(imageNamed: "sherman-hull")
    let tankTurret = SKSpriteNode(imageNamed: "sherman-turret")

    var lastUpateTime: TimeInterval = 0
    var dt: TimeInterval = 0

    let movePointsPerSec: CGFloat = 480.0
    var tankVelocity = CGPoint.zero
    var isSherman = true
    var tankOnScreen = false

    enum CompassPoint: CaseIterable {
        case N, S, E, W, NE, NW, SE, SW
    }

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "map3")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.zPosition = -1
        addChild(background)

        tankHull.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tankHull.size = CGSize(width: 411, height: 144)
        tankHull.zPosition = 1
        addChild(tankHull)

        tankTurret.position = CGPoint(x: 0, y: 0)
        tankTurret.anchorPoint = CGPoint(x: 0.49, y: 0.5)
        tankTurret.size = CGSize(width: 411, height: 144)
        tankTurret.zPosition = 2
        tankHull.addChild(tankTurret)

        spawnNextTank()
    }

    // Returns the off-screen position for a compass point
    func compassPosition(_ point: CompassPoint) -> CGPoint {
        let hw = tankHull.size.width / 2
        let hh = tankHull.size.height / 2
        switch point {
        case .N:  return CGPoint(x: size.width/2,        y: size.height + hh)
        case .S:  return CGPoint(x: size.width/2,        y: -hh)
        case .E:  return CGPoint(x: size.width + hw,     y: size.height/2)
        case .W:  return CGPoint(x: -hw,                 y: size.height/2)
        case .NE: return CGPoint(x: size.width + hw,     y: size.height + hh)
        case .NW: return CGPoint(x: -hw,                 y: size.height + hh)
        case .SE: return CGPoint(x: size.width + hw,     y: -hh)
        case .SW: return CGPoint(x: -hw,                 y: -hh)
        }
    }

    func spawnNextTank() {
        let all = CompassPoint.allCases
        let entry = all.randomElement()!
        var exit = all.randomElement()!
        while exit == entry { exit = all.randomElement()! }

        let startPos = compassPosition(entry)
        let endPos   = compassPosition(exit)

        // Normalize direction vector and scale by speed
        let dx = endPos.x - startPos.x
        let dy = endPos.y - startPos.y
        let length = sqrt(dx*dx + dy*dy)
        tankVelocity = CGPoint(x: dx/length * movePointsPerSec,
                               y: dy/length * movePointsPerSec)

        tankHull.position = startPos
        tankOnScreen = false

        // Alternate between sherman and tiger
        isSherman = !isSherman
        if isSherman {
            tankHull.texture    = SKTexture(imageNamed: "sherman-hull")
            tankTurret.texture  = SKTexture(imageNamed: "sherman-turret")
        } else {
            tankHull.texture    = SKTexture(imageNamed: "tiger-hull")
            tankTurret.texture  = SKTexture(imageNamed: "tiger-turret")
        }
    }

    func checkBounds() {
        let pos = tankHull.position
        let onScreen = pos.x >= 0 && pos.x <= size.width &&
                       pos.y >= 0 && pos.y <= size.height

        if onScreen {
            tankOnScreen = true
        } else if tankOnScreen {
            // Just exited — spawn next run
            spawnNextTank()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpateTime > 0 {
            dt = currentTime - lastUpateTime
        } else {
            dt = 0
        }
        lastUpateTime = currentTime

        moveSprite(sprite: tankHull, velocity: tankVelocity)
        checkBounds()
    }

    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                   y: velocity.y * CGFloat(dt))
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x,
                                  y: sprite.position.y + amountToMove.y)
        sprite.zRotation = atan2(velocity.y, velocity.x)
    }
}
