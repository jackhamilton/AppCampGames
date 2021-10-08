//
//  Note.swift
//  TileTerminator2
//
//  Created by Jack Hamilton on 7/19/18.
//  Copyright © 2018 Dropkick. All rights reserved.
//

import Foundation
import SpriteKit

class Note {
    public var time: TimeInterval!
    public var hitCircleIndex: Int!
    public var startPosition: CGPoint = CGPoint(x: 0, y: 0)
    public var endPosition: CGPoint = CGPoint(x: 0, y: 0)
    public var sprite: NoteSprite?
    
    public init(time: Double, hitCircleIndex: Int) {
        self.time = time
        self.hitCircleIndex = hitCircleIndex
    }
}
