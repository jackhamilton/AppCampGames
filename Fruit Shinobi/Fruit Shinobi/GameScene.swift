//
//  GameScene.swift
//  Fruit Shinobi
//
//  Created by Jack Hamilton on 7/1/19.
//  Copyright © 2019 Dropkick. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var emitRegion: SKSpriteNode!
    var deleter: SKSpriteNode!
    var fruit: SKSpriteNode!
    var cursor: SKNode!
    
    var currentTouch: UITouch?
    var particleTrail: SKEmitterNode?
    
    let cursorMask: UInt32 = 0x1 << 0
    let fruitMask: UInt32 = 0x1 << 1
    let deleterMask: UInt32 = 0x1 << 2
    
    var tickTime: Double?
    
    override func didMove(to view: SKView) {
        emitRegion = childNode(withName: "emitRegion") as! SKSpriteNode
        fruit = childNode(withName: "fruit") as! SKSpriteNode
        deleter = childNode(withName: "deleter") as! SKSpriteNode
        cursor = childNode(withName: "cursor")
        scene?.physicsWorld.contactDelegate = self
        cursor.physicsBody?.categoryBitMask = cursorMask
        cursor.physicsBody?.collisionBitMask = fruitMask
        cursor.physicsBody?.contactTestBitMask = fruitMask
        cursor.physicsBody?.usesPreciseCollisionDetection = true
        deleter.physicsBody?.categoryBitMask = deleterMask
        deleter.physicsBody?.collisionBitMask = fruitMask
        deleter.physicsBody?.contactTestBitMask = fruitMask
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!touches.isEmpty && currentTouch == nil) {
            currentTouch = touches.first
            if (particleTrail == nil) {
                cursor.position = currentTouch!.location(in: self)
                cursor.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                tickTime = CACurrentMediaTime()
                if let trail = SKEmitterNode(fileNamed: "trailParticle.sks") {
                    particleTrail = trail
                    particleTrail?.targetNode = self.scene
                    cursor.addChild(particleTrail!)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if t.isEqual(currentTouch) {
                let timeDiff = CACurrentMediaTime() - tickTime!
                var movement = CGVector(dx: t.location(in: self).x - cursor.position.x,
                                        dy: t.location(in: self).y - cursor.position.y)
                movement.dx /= CGFloat(timeDiff)
                movement.dy /= CGFloat(timeDiff)
                tickTime = CACurrentMediaTime()
                cursor.physicsBody?.velocity = movement
                cursor.isHidden = false
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        clearTouch(touches: touches)
        if let trail = particleTrail {
            trail.particleBirthRate = 0
            trail.run(deleteAfter(time: 0.2))
        }
        particleTrail = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func clearTouch(touches: Set<UITouch>) {
        cursor.isHidden = true
        for t in touches {
            if t.isEqual(currentTouch) {
                currentTouch = nil
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if(contact.bodyB.categoryBitMask == fruitMask &&
            contact.bodyA.categoryBitMask == deleterMask) {
            contact.bodyB.node!.removeFromParent()
        }
        if(contact.bodyA.categoryBitMask == cursorMask &&
            contact.bodyB.categoryBitMask == fruitMask) {
            //let anim: SKNode = SKNode()
            //anim.addChild(SKEmitterNode(fileNamed: "destruction")!)
            //anim.position = contact.bodyB.node!.position
            //anim.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.removeFromParent()]))
            //addChild(anim)
            let images = ["top", "bot"]
            for image in images{
                let split: SKSpriteNode = contact.bodyB.node!.copy() as! SKSpriteNode
                split.physicsBody = SKPhysicsBody()
                split.physicsBody?.velocity = (CGVector(dx: random(bounds: 200),
                                                        dy: random(bounds: 200)))
                split.physicsBody?.angularVelocity = random(bounds: 10) - 5
                split.texture = SKTexture(imageNamed: (split.name! + image))
                split.run(deleteAfter(time: 3))
                addChild(split)
            }
            contact.bodyB.node!.removeFromParent()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        //sin function for variable gen probability
        if (arc4random_uniform(100) < 3) {
            let newFruit = fruit.copy() as! SKSpriteNode
            let fruitWidth = UInt32(emitRegion.size.width)
            let fruitHeight = UInt32(emitRegion.size.height)
            var posX = CGFloat(arc4random_uniform(fruitWidth))
            posX -= CGFloat(fruitWidth / 2)
            var posY = CGFloat(arc4random_uniform(fruitHeight))
            posY -= CGFloat(fruitHeight / 2)
            posY += emitRegion.position.y
            newFruit.position = CGPoint(x: posX, y: posY)
            //alpha mask
            newFruit.physicsBody = SKPhysicsBody(circleOfRadius: 20)
            newFruit.physicsBody?.categoryBitMask = fruitMask
            newFruit.physicsBody?.collisionBitMask = cursorMask
            let xVelocity = random(bounds: 1000) - 500
            let yVelocity = random(bounds: 300) + 1200
            newFruit.physicsBody?.velocity = CGVector(dx: xVelocity, dy: yVelocity)
            let fruitType = "fruit" + String(arc4random_uniform(4) + 1)
            newFruit.texture = SKTexture(imageNamed: fruitType)
            newFruit.name = fruitType
            addChild(newFruit)
        }
    }
    
    func random(bounds: UInt32) -> CGFloat {
        return CGFloat(arc4random_uniform(bounds))
    }
    
    func deleteAfter(time: Double) -> SKAction {
        return SKAction.sequence([SKAction.wait(forDuration: time),
                                  SKAction.removeFromParent()])
    }
    
}
