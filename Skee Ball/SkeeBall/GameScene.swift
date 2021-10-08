//
//  GameScene.swift
//  SkeeBall
//
//  Created by Jack Hamilton on 7/17/20.
//  Copyright © 2020 Dropkick. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var startPos: CGPoint!
    var lineDraw: SKShapeNode!
    var ball: SKNode!
    var ball2: SKNode!
    var ballCopy: SKNode!
    var ball2Copy: SKNode!
    var ball2StartHeight: CGFloat!
    var animate = false
    var big: SKNode!
    var medium: SKNode!
    var small: SKNode!
    var topleft: SKNode!
    var topright: SKNode!
    var scoreLabel: SKLabelNode!
    var score = 0
    var controlActive = true
    var countdown: Double = 60
    var timeLabel: SKLabelNode!
    var highscoreLabel: SKLabelNode!
    var highscore = 0
    
    override func didMove(to view: SKView) {
        ball = scene?.childNode(withName: "ball")
        ballCopy = ball.copy() as? SKNode
        ball2 = scene?.childNode(withName: "ball2")
        ball2Copy = ball2.copy() as? SKNode
        big = scene?.childNode(withName: "big")
        medium = scene?.childNode(withName: "medium")
        small = scene?.childNode(withName: "small")
        topleft = scene?.childNode(withName: "TopLeft")
        topright = scene?.childNode(withName: "TopRight")
        scoreLabel = scene?.childNode(withName: "score" ) as? SKLabelNode
        timeLabel = scene?.childNode(withName: "time" ) as? SKLabelNode
        highscoreLabel = scene?.childNode(withName: "highscore") as? SKLabelNode
    }
    
    func animateScoreAdd(score: Int) {
        let newscore = scoreLabel.copy() as! SKLabelNode
        newscore.position.y += 60
        newscore.text = "+" + String(score)
        scene?.addChild(newscore)
        newscore.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.group([
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.move(by: CGVector(dx: 0, dy: -60), duration: 1.0)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if (countdown == 0) {
            countdown = 60
            score = 0
            controlActive = true
        }
        if (controlActive) {
            startPos = pos
            if (lineDraw != nil) {
                lineDraw.removeFromParent()
            }
            let linePath: CGMutablePath = CGMutablePath()
            linePath.move(to: ball.position)
            linePath.addLine(to: CGPoint(x: ball.position.x + pos.x - startPos.x, y: ball.position.y + pos.y - startPos.y))

            let lineDraw1: SKShapeNode = SKShapeNode(path: linePath)
            lineDraw1.strokeColor = .black
            lineDraw1.lineWidth = 2.0
            lineDraw1.zPosition = 10
            lineDraw = lineDraw1
            scene?.addChild(lineDraw)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if (controlActive) {
            let linePath: CGMutablePath = CGMutablePath()
            linePath.move(to: ball.position)
            let destX = ball.position.x + pos.x - startPos.x
            let destY = ball.position.y + pos.y - startPos.y
            linePath.addLine(to: CGPoint(x: destX, y: destY))
            
            //Arrows
            let arrowAngle: CGFloat = CGFloat(Double.pi/8)
            let pointerLineLength: CGFloat = 30
            let startEndAngle = atan((destY - ball.position.y) / (destX - ball.position.x)) + ((destX - ball.position.x) < 0 ? CGFloat(Double.pi) : 0)
            let finx = destX + CGFloat(pointerLineLength) * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle)
            let finx2 = destX + CGFloat(pointerLineLength) * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle)
            let arrowLine1 = CGPoint(x: finx, y: destY - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
            let arrowLine2 = CGPoint(x: finx2, y: destY - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))
            linePath.addLine(to: arrowLine1)
            linePath.move(to: CGPoint(x: destX, y:  destY))
            linePath.addLine(to: arrowLine2)
            
            lineDraw.path = linePath
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if (controlActive) {
            lineDraw.removeFromParent()
            ball.physicsBody?.velocity = CGVector(dx: (pos.x - startPos.x) * 1.6, dy: (pos.y - startPos.y) * 1.6)
            ball.run(SKAction.sequence([
                SKAction.run {
                    self.animate = true
                },
                SKAction.wait(forDuration: 1.7),
                SKAction.run {
                    self.animate = false
                    if (self.topleft.frame.contains(self.ball.position)) {
                        self.score += 100
                        self.animateScoreAdd(score: 100)
                    } else if (self.topright.frame.contains(self.ball.position)) {
                        self.score += 100
                        self.animateScoreAdd(score: 100)
                    } else if (self.small.frame.contains(self.ball.position)) {
                        self.score += 50
                        self.animateScoreAdd(score: 50)
                    } else if (self.medium.frame.contains(self.ball.position)) {
                        self.score += 30
                        self.animateScoreAdd(score: 30)
                    } else if (self.big.frame.contains(self.ball.position)) {
                        self.score += 10
                        self.animateScoreAdd(score: 10)
                    }
                    self.ball.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                },
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.run {
                    self.ball = self.ballCopy
                    self.ballCopy = self.ball.copy() as? SKNode
                    self.scene?.addChild(self.ball)
                    self.controlActive = true
                },
                SKAction.removeFromParent()
                ]))
            controlActive = false
        }
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
        // Called before each frame is rendered
        if (countdown > 0) {
            countdown -= 1/60
        }
        if (countdown <= 0) {
            countdown = 0
            controlActive = false
            if (score > highscore) {
                highscore = score
                highscoreLabel.text = "Highscore: " + String(highscore)
            }
        }
        scoreLabel.text = String(score)
        timeLabel.text = String(Int(countdown))
        if (animate) {
            if (!ball2.physicsBody!.affectedByGravity) {
                ball2.physicsBody?.affectedByGravity = true
                ball2.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10000))
                ball2StartHeight = ball2.position.y
                
                ball2.run(SKAction.sequence([
                    SKAction.wait(forDuration: 1.7),
                    SKAction.run {
                        self.ball2.removeFromParent()
                        self.ball2 = self.ball2Copy
                        self.ball2Copy = self.ball2.copy() as? SKNode
                        self.scene!.addChild(self.ball2)
                    }
                ]))
            }
            ball.setScale(CGFloat(ball2Copy.xScale + ball2.position.y / 5000))
        }
    }
}
