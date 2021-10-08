//
//  GameScene.swift
//  BalloonPop
//
//  Created by Jack Hamilton on 7/20/20.
//  Copyright © 2020 Dropkick. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var dartBase: SKSpriteNode!
    var balloonBase: SKSpriteNode!
    var frequency: Int! = 60
    var labelNode: SKLabelNode!
    var score = 0

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        dartBase = scene?.childNode(withName: "dart") as? SKSpriteNode
        balloonBase = scene?.childNode(withName: "balloon") as? SKSpriteNode
        labelNode = scene?.childNode(withName: "score") as? SKLabelNode
        dartBase.physicsBody!.contactTestBitMask = balloonBase.physicsBody!.collisionBitMask
    }
    
    func touchDown(atPoint pos : CGPoint) {
        let copyDart = dartBase.copy() as! SKSpriteNode
        copyDart.zPosition = 0
        copyDart.position = pos
        copyDart.physicsBody?.affectedByGravity = true
        copyDart.physicsBody?.velocity = CGVector(dx: 0, dy: 2500)
        scene?.addChild(copyDart)
        copyDart.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node != nil && contact.bodyB.node != nil){
            var balloonNode: SKSpriteNode!
            if (contact.bodyA.node!.name == "dart") {
                balloonNode = contact.bodyB.node as? SKSpriteNode
            } else if (contact.bodyB.node!.name == "dart") {
                balloonNode = contact.bodyA.node as? SKSpriteNode
            }
            if (contact.bodyA.node!.name == "dart" || contact.bodyB.node!.name == "dart") {
                balloonNode.physicsBody = nil
                balloonNode.texture = SKTexture(imageNamed: "BalloonB2")
                balloonNode.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.1),
                    SKAction.run({
                        balloonNode.texture = SKTexture(imageNamed: "BalloonB3")
                    }),
                    SKAction.wait(forDuration: 0.1),
                    SKAction.removeFromParent()
                ]))
                score += 50
                labelNode.text = String(score)
            }
        }
    }
    
   func touchMoved(toPoint pos : CGPoint) {

   }
   
   func touchUp(atPoint pos : CGPoint) {
       
   }
   
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
       for t in touches { self.touchDown(atPoint: t.location(in: self)) }
   }
   
   override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
   }
   
   override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       for t in touches { self.touchUp(atPoint: t.location(in: self)) }
   }
   
   override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
       for t in touches { self.touchUp(atPoint: t.location(in: self)) }
   }
   
       
    override func update(_ currentTime: TimeInterval) {
        
        if (Int.random(in: 1...frequency) == 1) {
            let newBalloon = balloonBase.copy() as! SKSpriteNode
            let randomX = Int.random(in: -300...300)
            let randomY = Int.random(in: -300...300)
            newBalloon.position = CGPoint(x: randomX, y: randomY)
            newBalloon.run(SKAction.sequence([
                SKAction.wait(forDuration: 3.0),
                SKAction.removeFromParent()
            ]))
            scene?.addChild(newBalloon)
            
        }
        
        // Called before each frame is rendered
    }
}
