//
//  GameScene.swift
//  Hockey 13
//
//  Created by Admin on 7/24/19.
//  Copyright © 2019 Dropkick. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var paddle1: SKSpriteNode!
    var paddle2: SKSpriteNode!
    var puck: SKSpriteNode?
    
    var player1ScoreLabel: SKLabelNode!
    var player2ScoreLabel: SKLabelNode!
    
    var paddle1Touch: UITouch?
    var paddle2Touch: UITouch?
    
    var score1 = 0
    var score2 = 0
    
    override func didMove(to view: SKView) {
        
        scene?.physicsWorld.contactDelegate = self
        
        paddle1 = childNode(withName: "paddle1") as? SKSpriteNode
        paddle2 = childNode(withName: "paddle2") as? SKSpriteNode
        puck = childNode(withName: "puck") as? SKSpriteNode
        
        player1ScoreLabel = childNode(withName: "player1Score") as? SKLabelNode
        player2ScoreLabel = childNode(withName: "player2Score") as? SKLabelNode
        
    }
    
    func touchDown(atPoint pos : CGPoint, touch: UITouch) {
        if (paddle1!.frame.contains(pos)) {
            paddle1Touch = touch
        }
        if (paddle2!.frame.contains(pos)) {
            paddle2Touch = touch
        }
    }
    
    func touchMoved(toPoint pos : CGPoint, touch: UITouch) {
        if (paddle1Touch != nil && touch == paddle1Touch) {
            paddle1?.run(SKAction.applyForce(CGVector(dx: 2000*(pos.x - paddle1.position.x), dy: 2000*(pos.y - paddle1.position.y)), duration: 1/120))
        }
        if (paddle2Touch != nil && touch == paddle2Touch) {
            paddle2?.run(SKAction.applyForce(CGVector(dx: 2000*(pos.x - paddle2.position.x), dy: 2000*(pos.y - paddle2.position.y)), duration: 1/120))
        }
    }
    
    func touchUp(atPoint pos : CGPoint, touch: UITouch) {
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.node! as! SKSpriteNode
        let b = contact.bodyB.node! as! SKSpriteNode
        if (a.name == "puck" && b.name == "yellowWall") {
            a.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0))
            a.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            score2 += 1
            player2ScoreLabel.text = String(score2)
        }
        if (b.name == "puck" && a.name == "yellowWall") {
            b.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0))
            b.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            score2 += 1
            player2ScoreLabel.text = String(score2)
        }
        
        if (a.name == "puck" && b.name == "yellowWall2") {
            a.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0))
            a.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            score1 += 1
            player1ScoreLabel.text = String(score1)
        }
        if (b.name == "puck" && a.name == "yellowWall2") {
            b.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0))
            b.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            score1 += 1
            player1ScoreLabel.text = String(score1)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self), touch: t) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self), touch: t) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self), touch: t) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self), touch: t) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
