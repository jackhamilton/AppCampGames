//
//  GameScene.swift
//  2049
//
//  Created by Jack Hamilton on 6/27/19.
//  Copyright © 2019 Dropkick. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Tile {
    var x, y: Int
    var value: Int
    var node: SKNode?
}

class GameScene: SKScene {
    
    var frameTile: SKNode!
    var sampleTile: SKNode!
    var activeTiles: [[Tile]] = [[]]
    
    let swipeLeftRecognizer = UISwipeGestureRecognizer()
    let swipeRightRecognizer = UISwipeGestureRecognizer()
    let swipeUpRecognizer = UISwipeGestureRecognizer()
    let swipeDownRecognizer = UISwipeGestureRecognizer()
    
    func isSpaceTaken(x: Int, y: Int) -> Bool {
        for tile in activeTiles {
            if (tile.x == x && tile.y == y) {
                return true
            }
        }
        return false
    }
    
    func getPosition(t: Tile) -> CGPoint {
        return CGPoint(x: t.x * 160, y: t.y * 160)
    }
    
    func tileExistsAtPosition(x: Int, y: Int) -> Int? {
        for i in 0...(activeTiles.count - 1) {
            if (activeTiles[i].x == x && activeTiles[i].y == y) {
                return i
            }
        }
        return nil
    }
    
    func makeTile() {
        var newTile = Tile(x: 0, y: 0, value: 1, node: nil)
        var newSpaceFound = false
        while (!newSpaceFound) {
            newTile.x = Int(arc4random_uniform(4))
            newTile.y = Int(arc4random_uniform(4))
            newSpaceFound = !isSpaceTaken(x: newTile.x, y: newTile.y)
        }
        let newTileNode = sampleTile.copy() as! SKNode
        newTileNode.alpha = 1
        newTileNode.position = getPosition(t: newTile)
        newTile.node = newTileNode
        (newTileNode.childNode(withName: "number") as! SKLabelNode).text = String(newTile.value)
        frameTile.addChild(newTileNode)
        activeTiles.append(newTile)
    }
    
    @objc func swipedLeft() {
        swiped(dx: -1, dy: 0)
    }
    
    @objc func swipedRight() {
        swiped(dx: 1, dy: 0)
    }
    
    @objc func swipedUp() {
        swiped(dx: 0, dy: 1)
    }
    
    @objc func swipedDown() {
        swiped(dx: 0, dy: -1)
    }
    
    func swiped(dx: Int, dy: Int) {
        var tileIndicesToRemove: [Int] = []
        for i in 0...(activeTiles.count - 1) {
            //If something exists in the direction you want to move, move all in the inverse direction over one in that direction.
            activeTiles[i].x += dx
            activeTiles[i].y += dy
            activeTiles[i].node!.position = getPosition(t: activeTiles[i])
        }
        for index in tileIndicesToRemove {
            activeTiles.remove(at: index)
        }
        for _ in 0...(arc4random_uniform(2)) {
            makeTile()
        }
    }
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        frameTile = self.childNode(withName: "frame")
        sampleTile = frameTile.childNode(withName: "sampleTile")
        for _ in 0...3 {
            makeTile()
        }
        swipeLeftRecognizer.addTarget(self, action: #selector(swipedLeft))
        swipeLeftRecognizer.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRecognizer)
        swipeRightRecognizer.addTarget(self, action: #selector(swipedRight))
        swipeRightRecognizer.direction = .right
        self.view!.addGestureRecognizer(swipeRightRecognizer)
        swipeUpRecognizer.addTarget(self, action: #selector(swipedUp))
        swipeUpRecognizer.direction = .up
        self.view!.addGestureRecognizer(swipeUpRecognizer)
        swipeDownRecognizer.addTarget(self, action: #selector(swipedDown))
        swipeDownRecognizer.direction = .down
        self.view!.addGestureRecognizer(swipeDownRecognizer)
    }
    
    func touchDown(atPoint pos : CGPoint) {
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
        // Called before each frame is rendered
    }
}
