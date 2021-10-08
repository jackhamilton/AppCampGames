import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var foreground: SKNode!
    var player1Paddle: SKSpriteNode!
    var player2Paddle: SKSpriteNode!
    var puck: SKSpriteNode!
    var player1Score: Int = 0
    var player2Score: Int = 0
    var player1ScoreText: SKLabelNode!
    var player2ScoreText: SKLabelNode!
    var goal1: SKSpriteNode!
    var goal2: SKSpriteNode!
    var red: SKNode!
    var blue: SKNode!
    
    let redCategory : UInt32 = 1 << 0
    let blueCategory : UInt32 = 1 << 1
    let goal1Category : UInt32 = 1 << 2
    let goal2Category : UInt32 = 1 << 3
    let puckCategory : UInt32 = 1 << 4
    let paddleCategory : UInt32 = 1 << 5
    
    var player1PaddleStartPos = CGPoint(x: 0, y: 0)
    var player2PaddleStartPos = CGPoint(x: 0, y: 0)
    
    var paddle1Touches: [UITouch] = []
    var paddle2Touches: [UITouch] = []
    
    private  var time: Double = 0
    var timeSinceLastTouchUpdate: CGFloat {
        get {
            let tickTime = CACurrentMediaTime() - time
            return CGFloat(tickTime)
        }
    }
    
    override func didMove(to view: SKView) {
        scene?.physicsWorld.contactDelegate = self
        scene?.scaleMode = SKSceneScaleMode.aspectFit
        foreground = childNode(withName: "Foreground") as! SKNode
        player1Paddle = foreground.childNode(withName: "paddle1") as! SKSpriteNode
        player2Paddle = foreground.childNode(withName: "paddle2") as! SKSpriteNode
        puck = foreground.childNode(withName: "puck") as! SKSpriteNode
        player1ScoreText = foreground.childNode(withName: "player1Score") as! SKLabelNode
        player2ScoreText = foreground.childNode(withName: "player2Score") as! SKLabelNode
        red = childNode(withName: "Red") as! SKNode
        blue = childNode(withName: "Blue") as! SKNode
        goal1 = childNode(withName: "goalU") as! SKSpriteNode
        goal2 = childNode(withName: "goalD") as! SKSpriteNode
        for child in red.children {
            child.physicsBody?.categoryBitMask = redCategory
            child.physicsBody?.collisionBitMask = paddleCategory
        }
        for child in blue.children {
            child.physicsBody?.categoryBitMask = blueCategory
            child.physicsBody?.collisionBitMask = puckCategory | paddleCategory
        }
        puck.physicsBody?.categoryBitMask = puckCategory
        puck.physicsBody?.collisionBitMask = blueCategory | goal1Category | goal2Category
        puck.physicsBody?.contactTestBitMask = goal1Category | goal2Category
        goal1.physicsBody?.categoryBitMask = goal1Category
        goal1.physicsBody?.collisionBitMask = puckCategory
        goal2.physicsBody?.categoryBitMask = goal2Category
        goal2.physicsBody?.collisionBitMask = puckCategory
        puck.physicsBody?.usesPreciseCollisionDetection = true
        player1PaddleStartPos = player1Paddle.position
        player2PaddleStartPos = player2Paddle.position
    }
    
    func touchDown(atPoint pos : CGPoint, touch: UITouch) {
        if (player1Paddle.frame.contains(pos)) {
            paddle1Touches.append(touch)
        } else if (player2Paddle.frame.contains(pos)) {
            paddle2Touches.append(touch)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint, touch: UITouch) {
        if (paddle1Touches.contains(touch)) {
            let tickTime = timeSinceLastTouchUpdate
            let dx = pos.x - player1Paddle.position.x
            let dy = pos.y - player1Paddle.position.y
            player1Paddle.physicsBody?.velocity = CGVector(dx: dx/tickTime, dy: dy/tickTime)
        } else if (paddle2Touches.contains(touch)){
            let tickTime = timeSinceLastTouchUpdate
            let dx = pos.x - player2Paddle.position.x
            let dy = pos.y - player2Paddle.position.y
            player2Paddle.physicsBody?.velocity = CGVector(dx: dx/tickTime, dy: dy/tickTime)
        }
    }
    
    func touchUp(atPoint pos : CGPoint, touch: UITouch) {
        if let index = paddle1Touches.firstIndex(of: touch) {
            paddle1Touches.remove(at: index)
        }
        if let index = paddle2Touches.firstIndex(of: touch) {
            paddle2Touches.remove(at: index)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == puckCategory || contact.bodyB.categoryBitMask == puckCategory) {
            if (contact.bodyA.categoryBitMask == goal1Category || contact.bodyB.categoryBitMask == goal1Category) {
                let initialPositions: [CGPoint] = [CGPoint(x: 0, y: 0), player1PaddleStartPos, player2PaddleStartPos]
                var iterator = 0
                for node: SKSpriteNode? in [puck, player1Paddle, player2Paddle] {
                    node!.removeFromParent()
                    
                    node!.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    node!.position = initialPositions[iterator]
                    iterator += 1
                    scene?.addChild(node!)
                }
                player2Score += 1
                player2ScoreText.text = String(player2Score)
                paddle1Touches.removeAll()
                paddle2Touches.removeAll()
            }
            if (contact.bodyA.categoryBitMask == goal2Category || contact.bodyB.categoryBitMask == goal2Category) {
                let initialPositions: [CGPoint] = [CGPoint(x: 0, y: 0), player1PaddleStartPos, player2PaddleStartPos]
                var iterator = 0
                for node: SKSpriteNode? in [puck, player1Paddle, player2Paddle] {
                    node!.removeFromParent()
                    node!.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    node!.position = initialPositions[iterator]
                    iterator += 1
                    scene?.addChild(node!)
                }
                player1Score += 1
                player1ScoreText.text = String(player1Score)
                paddle1Touches.removeAll()
                paddle2Touches.removeAll()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self), touch: t) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self), touch: t) }
        time = CACurrentMediaTime()
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
