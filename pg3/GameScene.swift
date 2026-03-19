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

    let movePointsPerSec: CGFloat = 384.0
    var tankVelocity = CGPoint.zero
    var isSherman = true
    var tankOnScreen = false
    var turretTime: CGFloat = 0
    let turretSwingDegrees: CGFloat = 15 * .pi / 180  // 15° in radians
    let turretSwingSpeed: CGFloat = 0.5              // full cycles per second (sherman)
    var currentTurretSwingSpeed: CGFloat = 0.5
    var smokeEmitter: SKEmitterNode?

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

        tankTurret.position = CGPoint(x: -41, y: 0)
        tankTurret.anchorPoint = CGPoint(x: 0.39, y: 0.5)
        tankTurret.size = CGSize(width: 411, height: 144)
        tankTurret.zPosition = 2
        tankHull.addChild(tankTurret)

        if let emitter = SKEmitterNode(fileNamed: "smoke") {
            emitter.position = CGPoint(x: -200, y: 0)  // rear of hull in local space
            emitter.targetNode = self                   // particles linger in the scene
            tankHull.addChild(emitter)
            smokeEmitter = emitter
        }

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

    // Returns which screen edges a compass point sits on
    func sides(of point: CompassPoint) -> Set<String> {
        switch point {
        case .N:  return ["top"]
        case .S:  return ["bottom"]
        case .E:  return ["right"]
        case .W:  return ["left"]
        case .NE: return ["top", "right"]
        case .NW: return ["top", "left"]
        case .SE: return ["bottom", "right"]
        case .SW: return ["bottom", "left"]
        }
    }

    func spawnNextTank() {
        let all = CompassPoint.allCases
        let entry = all.randomElement()!
        // Only allow exits that share no edge with entry, guaranteeing the path crosses the screen
        let validExits = all.filter { $0 != entry && sides(of: $0).isDisjoint(with: sides(of: entry)) }
        let exit = validExits.randomElement()!

        let startPos = compassPosition(entry)
        let endPos   = compassPosition(exit)

        // Normalize direction vector and scale by speed
        let dx = endPos.x - startPos.x
        let dy = endPos.y - startPos.y
        let length = sqrt(dx*dx + dy*dy)

        tankHull.position = startPos
        tankOnScreen = false

        // Alternate between sherman and tiger
        isSherman = !isSherman
        let speed = isSherman ? movePointsPerSec : movePointsPerSec / 2
        tankVelocity = CGPoint(x: dx/length * speed,
                               y: dy/length * speed)
        currentTurretSwingSpeed = isSherman ? turretSwingSpeed : turretSwingSpeed / 2
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
        smokeEmitter?.emissionAngle = tankHull.zRotation + .pi
        checkBounds()

        turretTime += CGFloat(dt)
        tankTurret.zRotation = sin(turretTime * currentTurretSwingSpeed * 2 * .pi) * turretSwingDegrees
    }

    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                   y: velocity.y * CGFloat(dt))
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x,
                                  y: sprite.position.y + amountToMove.y)
        sprite.zRotation = atan2(velocity.y, velocity.x)
    }
}
