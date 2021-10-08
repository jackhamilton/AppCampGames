//
//  GameScene.swift
//  Bakery Ronin
//
//  Created by Admin on 7/26/19.
//  Copyright © 2019 dropkick. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background: SKSpriteNode!
    var sword: SKSpriteNode!
    var ƒruit: SKSpriteNode!
    var emit: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var highscoreLabel: SKLabelNode!
    
    let swordID: UInt32 = 0x1 << 1
    let fruitID: UInt32 = 0x1 << 2
    
    var score = 0
    var highscore = 0
    
    override func didMove(to view: SKView) {
        scene?.physicsWorld.contactDelegate = self
        
        background = childNode(withName: "background") as? SKSpriteNode
        sword = childNode(withName: "sword") as? SKSpriteNode
        ƒruit = childNode(withName: "fruit") as? SKSpriteNode
        emit = childNode(withName: "emit") as? SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        highscoreLabel = childNode(withName: "highscoreLabel") as? SKLabelNode
        
        sword.physicsBody?.categoryBitMask = swordID
        sword.physicsBody?.collisionBitMask = fruitID
        sword.physicsBody?.contactTestBitMask = fruitID
        
        let defaults = UserDefaults.standard
        if let currentHighscore = defaults.string(forKey: "highscore") {
            highscore = Int(currentHighscore)!
            highscoreLabel.text = "Highscore: " + String(currentHighscore)
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        sword.position = pos
        if let trail = SKEmitterNode(fileNamed: "sword.sks") {
            trail.targetNode = self.scene
            sword.addChild(trail)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        sword.position = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        sword.removeAllChildren()
        sword.position = CGPoint(x: 50000, y: 50000)
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == swordID
            && contact.bodyB.categoryBitMask == fruitID) {
            for add in ["1", "2"] {
                let split: SKSpriteNode = contact.bodyB.node!.copy() as! SKSpriteNode
                split.physicsBody = SKPhysicsBody()
                split.physicsBody?.velocity = CGVector(dx: Int.random(in: 1...200),
                                                       dy: Int.random(in: 1...200))
                split.physicsBody?.angularVelocity = CGFloat(Int.random(in: 5...10))
                
                split.texture = SKTexture(imageNamed: split.name! + add)
                
                split.run(SKAction.sequence( [SKAction.wait(forDuration: 3),
                                                 SKAction.removeFromParent()]    ))
                addChild(split)
            }
            score += 1
            scoreLabel.text = String(score)
            
            if (score > highscore) {
                highscore = score
                highscoreLabel.text = "Highscore: " + String(highscore)
                let defaults = UserDefaults.standard
                defaults.set(String(highscore), forKey: "highscore")
            }
            
            contact.bodyB.node?.removeFromParent()
            
            if (contact.bodyB.node!.name == "apple") {
                score = 0
                scoreLabel.text = "0"
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if (Int.random(in: 1...30) == 1) {
            let newFruit = ƒruit.copy() as! SKSpriteNode
            
            let yPosition = Int.random(in: Int(emit.frame.minY)...Int(emit.frame.maxY))
            let xPosition = Int.random(in: Int(emit.frame.minX)...Int(emit.frame.maxX))
            
            newFruit.position = CGPoint(x: xPosition, y: yPosition)
            
            newFruit.physicsBody = SKPhysicsBody(circleOfRadius: 100)
            
            newFruit.physicsBody?.categoryBitMask = fruitID
            newFruit.physicsBody?.collisionBitMask = swordID
            
            let fruitNames = ["donut", "cupcake", "icecream", "cookie", "apple"]
            let name = fruitNames[Int.random(in: 0...(fruitNames.count - 1))]
            newFruit.texture = SKTexture(imageNamed: name)
            newFruit.name = name
            
            let xVelocity = Int.random(in: -800...800)
            let yVelocity = Int.random(in: 1300...1700)
            newFruit.physicsBody?.velocity = CGVector(dx: xVelocity, dy: yVelocity)
            
            newFruit.run(SKAction.sequence( [SKAction.wait(forDuration: 3),
                                             SKAction.removeFromParent()]    ))
            
            addChild(newFruit)
        }
    }
}
