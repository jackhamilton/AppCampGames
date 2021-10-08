//
//  NoteSprite.swift
//  TileTerminator2
//
//  Created by Jack Hamilton on 7/19/18.
//  Copyright © 2018 Dropkick. All rights reserved.
//

import Foundation
import SpriteKit

class NoteSprite: SKSpriteNode {
    public static let pink = SKTexture(imageNamed: "Pink")
    public static let yellow = SKTexture(imageNamed: "Yellow")
    public static let blue = SKTexture(imageNamed: "Blue")
    public static let green = SKTexture(imageNamed: "Green")
    public static let colors: [SKTexture] = [pink, yellow, blue, green]
    
    public init(note: Note) {
        super.init(texture: NoteSprite.colors[note.hitCircleIndex],
                   color: UIColor.clear,
                   size: NoteSprite.colors[note.hitCircleIndex].size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
